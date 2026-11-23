"""Build the grep-able text index and TOC for PDF manuals used by the `manuals` skill.

For each PDF, writes into <pdf dir>/index/:
  <id>.txt      full text, every line prefixed with "pNNNN: " (1-based PDF page)
  <id>.toc.txt  PDF bookmarks, one per line as "pNNNN  <indented title>"
  <id>/<attachment>/<sheet>.txt
                each visible sheet of each spreadsheet embedded in the PDF, one line per
                non-empty row as "rNNNN: A=value | C=value" (Excel row number, column letter)
and appends an entry for the document to index/catalog.md unless it already has one.
"""

import argparse
import datetime
import io
import os
import re
import shutil
import subprocess
import sys
import warnings
from pathlib import Path

import openpyxl
from openpyxl.utils import get_column_letter
from pypdf import PdfReader

SPREADSHEET_SUFFIXES = {".xlsx", ".xlsm"}

# Zero-width spaces, NBSPs and stray CRs show up in vendor bookmark titles and break grep.
JUNK = re.compile(r"[​‌‍﻿\r]")


def clean(s):
    return JUNK.sub("", s).replace("\xa0", " ").strip()


def write_atomic(path, text):
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


def page_text(pdf):
    out = subprocess.run(
        ["pdftotext", "-layout", "-enc", "UTF-8", str(pdf), "-"],
        check=True,
        capture_output=True,
    ).stdout.decode("utf-8", errors="replace")
    pages = out.split("\f")
    # pdftotext terminates every page with \f, so the last split element is empty.
    if pages and not pages[-1].strip():
        pages.pop()
    lines = []
    for no, page in enumerate(pages, 1):
        for line in page.splitlines():
            line = clean(line.rstrip())
            if line:
                lines.append(f"p{no:04d}: {line}")
    return len(pages), "\n".join(lines) + "\n"


def outline(reader):
    entries = []

    def walk(items, level):
        for item in items:
            if isinstance(item, list):
                walk(item, level + 1)
                continue
            try:
                page = reader.get_destination_page_number(item) + 1
            except Exception:
                continue
            title = clean(item.title or "")
            if title:
                entries.append((level, page, title))

    walk(reader.outline, 0)
    if not entries:
        return ""
    base = min(level for level, _, _ in entries)
    return "".join(f"p{page:04d}  {'  ' * (level - base)}{title}\n" for level, page, title in entries)


def cell_text(value):
    if value is None:
        return ""
    if isinstance(value, float) and value.is_integer():
        value = int(value)
    elif isinstance(value, datetime.datetime) and value.time() == datetime.time():
        value = value.date()
    if isinstance(value, (datetime.date, datetime.time)):
        value = value.isoformat()
    # Multi-line cells would otherwise split a row across lines and break grep.
    return " ".join(clean(str(value)).split())


def sheet_text(ws, title):
    rows = {}
    for row in ws.iter_rows():
        for cell in row:
            text = cell_text(cell.value)
            if text:
                rows.setdefault(cell.row, {})[cell.column] = text
    # Only fill merged ranges downwards, in their first column: vertical merges group
    # rows under one value, while horizontal ones are mostly section titles that would
    # just repeat across every column.
    for rng in ws.merged_cells.ranges:
        top = rows.get(rng.min_row, {}).get(rng.min_col)
        if top:
            for r in range(rng.min_row + 1, rng.max_row + 1):
                rows.setdefault(r, {})[rng.min_col] = top
    if not rows:
        return None
    width = max(4, len(str(max(rows))))
    lines = [f"# {title}"]
    for r in sorted(rows):
        cells = sorted(rows[r].items())
        lines.append(f"r{r:0{width}d}: " + " | ".join(f"{get_column_letter(c)}={v}" for c, v in cells))
    return "\n".join(lines) + "\n"


def safe_name(name):
    return re.sub(r"[^A-Za-z0-9._-]+", "_", name).strip("_") or "unnamed"


def index_attachments(reader, out_dir):
    """Returns the number of sheets written."""
    if out_dir.is_dir():
        shutil.rmtree(out_dir)
    sheets = 0
    for name, blobs in reader.attachments.items():
        if Path(name).suffix.lower() not in SPREADSHEET_SUFFIXES:
            print(f"  skipping attachment {name}: not a spreadsheet")
            continue
        for n, blob in enumerate(blobs):
            stem = safe_name(Path(name).stem) + (f"_{n}" if n else "")
            with warnings.catch_warnings():
                # openpyxl warns about Excel extensions (e.g. data validation) it drops,
                # none of which affect cell values.
                warnings.simplefilter("ignore", UserWarning)
                wb = openpyxl.load_workbook(io.BytesIO(blob), data_only=True)
            for ws in wb.worksheets:
                # Hidden sheets in vendor workbooks are revision logs and raw lookup data.
                if ws.sheet_state != "visible":
                    continue
                text = sheet_text(ws, f"{name} / {ws.title}")
                if text is None:
                    continue
                path = out_dir / stem / f"{safe_name(ws.title)}.txt"
                path.parent.mkdir(parents=True, exist_ok=True)
                write_atomic(path, text)
                sheets += 1
    return sheets


def catalog_entry(doc_id, pdf, pages, reader, has_toc, sheets):
    meta_title = clean((reader.metadata or {}).get("/Title", "") or "")
    lines = [
        f"## {doc_id}",
        "",
        f"- PDF: `{pdf.name}` ({pages} pages)",
        f"- Text: `index/{doc_id}.txt`",
        f"- TOC: `index/{doc_id}.toc.txt`" if has_toc else "- TOC: none (PDF has no bookmarks)",
    ]
    if sheets:
        lines.append(f"- Embedded spreadsheets: `index/{doc_id}/<attachment>/<sheet>.txt` ({sheets} sheets)")
    if meta_title:
        lines.append(f"- PDF title: {meta_title}")
    lines += ["- Covers: TODO", ""]
    return "\n".join(lines) + "\n"


def index(pdf):
    pdf = pdf.resolve()
    doc_id = pdf.stem
    out_dir = pdf.parent / "index"
    out_dir.mkdir(exist_ok=True)

    reader = PdfReader(pdf)
    pages, text = page_text(pdf)
    if pages != len(reader.pages):
        sys.exit(f"{pdf.name}: pdftotext saw {pages} pages, pypdf {len(reader.pages)}; page numbers would be off")
    write_atomic(out_dir / f"{doc_id}.txt", text)

    toc = outline(reader)
    toc_path = out_dir / f"{doc_id}.toc.txt"
    if toc:
        write_atomic(toc_path, toc)
    elif toc_path.exists():
        toc_path.unlink()

    sheets = index_attachments(reader, out_dir / doc_id)

    catalog = out_dir / "catalog.md"
    existing = catalog.read_text(encoding="utf-8") if catalog.exists() else "# Manuals catalog\n\n"
    if re.search(rf"^## {re.escape(doc_id)}$", existing, re.M):
        status = "catalog entry kept"
    else:
        if not existing.endswith("\n\n"):
            existing = existing.rstrip("\n") + "\n\n"
        write_atomic(catalog, existing + catalog_entry(doc_id, pdf, pages, reader, bool(toc), sheets))
        status = "catalog entry added, fill in 'Covers'"
    print(f"{pdf.name}: {pages} pages, {toc.count(chr(10))} TOC entries, {sheets} embedded sheets; {status}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("pdfs", nargs="+", type=Path)
    for pdf in parser.parse_args().pdfs:
        index(pdf)


if __name__ == "__main__":
    main()
