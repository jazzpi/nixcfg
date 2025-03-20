# Adapted from https://pablo.tools/blog/computers/nix-mustache-templates/
{ pkgs, ... }:
{
  name,
  template,
  data,
  asBin ? false,
}:
pkgs.stdenv.mkDerivation {
  name = "${name}";
  nativeBuildInputs = [ pkgs.mustache-go ];

  jsonData = builtins.toJSON data;
  passAsFile = [ "jsonData" ];

  phases = [
    "buildPhase"
    "installPhase"
  ];

  buildPhase = ''
    ${pkgs.mustache-go}/bin/mustache $jsonDataPath ${template} > rendered_file
    chmod --reference=${template} rendered_file
  '';

  installPhase =
    if asBin then
      ''
        mkdir -p $out/bin
        cp rendered_file $out/bin/${name}
      ''
    else
      ''
        cp rendered_file $out
      '';
}
