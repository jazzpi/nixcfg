---
name: manuals
description: Looks up facts in local copies of hardware reference manuals, datasheets and errata sheets (MCUs such as NXP S32K1xx and STM32L4, plus peripheral ICs). Use for register and bit-field layouts, peripheral behaviour, clocking, memory maps, electrical and timing specs, pinouts/alternate functions, and silicon errata, instead of answering from memory.
when_to_use: Runs in a separate agent that cannot see the conversation, so the argument must be a complete, self-contained question naming the exact part (e.g. "S32K116: which FlexCAN CTRL1 fields set the bit timing, with bit positions and reset values?").
argument-hint: <self-contained question naming the part>
context: fork
agent: general-purpose
model: sonnet
background: false
---

# Manual lookup

Answer this question from the vendor documentation:

> $ARGUMENTS

The manuals are in `~/GDrive/Manuals/`, their search index in `~/GDrive/Manuals/index/`. If
`~/GDrive/Manuals/index/catalog.md` does not exist, stop and report that the manuals are not
synced on this machine. Do not answer from memory instead.

## Workflow

1. **Pick the document(s).** Read `index/catalog.md`. It lists every indexed document, which
   parts it covers, and document-specific notes. Registers and functional behaviour are in
   the reference manual, electrical/timing specs and pinouts in the datasheet, known silicon
   bugs in the errata. If the right PDF exists in `~/GDrive/Manuals/` but is not in the
   catalog, say so and tell the user to run `manual-index <pdf>`.
2. **Find the pages.** Every line of `index/<id>.txt` is prefixed with `pNNNN:`, its 1-based
   PDF page.
   - For exact identifiers (register names, bit fields, errata IDs), Grep `index/<id>.txt`.
     Use specific patterns and a `head_limit`; generic words match thousands of lines.
   - For a topic or section, Grep `index/<id>.toc.txt` (the PDF bookmarks, indented by
     level, as `pNNNN  title`). A section ends where the next entry at the same or a
     shallower level starts.
3. **Read the PDF pages** with Read and `pages` (at most 20 per call). The text index is only
   for locating pages: it scrambles multi-column tables and register diagrams, so take
   bit positions, reset values and table contents from the PDF itself.
4. **Embedded spreadsheets.** Some PDFs carry tables as embedded Excel files (pin muxing,
   memory maps, interrupt/DMA mappings). The catalog lists them; each visible sheet is in
   `index/<id>/<attachment>/<sheet>.txt`, one line per row as `rNNNN: A=value | C=value`
   (Excel row number, column letter; empty cells omitted). Unlike the PDF text, these are
   complete and exact, so answer from them directly without going back to the PDF.
   - Read the first ~15 lines of a sheet before interpreting it: the header row is not
     always row 1, headers can span two rows, and some sheets have section-title rows.
   - Map each value to its header by column letter, never by position in the line.
   - A blank cell can mean "same as the row above" (continuation rows, e.g. several
     signals under one port) or "not applicable" (e.g. a pin absent from a package),
     depending on the sheet. Read the rows above a hit to tell which.
5. **Check the errata** when the question is about behaviour that might be a silicon bug, or
   when the reference manual's description looks inconsistent.

Page numbers are always PDF page indices (what `pNNNN` and the `pages` parameter use), not
the page numbers printed in the document.

## Answer format

- The direct answer first, then supporting detail.
- Exact values: bit positions, widths, reset values, access types, units, conditions,
  min/typ/max. Copy register field tables verbatim rather than paraphrasing them.
- Note chip-specific differences within a family (e.g. a peripheral or field only present
  on some family members) and any relevant errata.
- Cite every fact as `<id> p.<page>, §<section>`.
- If the documents do not answer the question, say so plainly. Do not fill gaps with
  general knowledge.
