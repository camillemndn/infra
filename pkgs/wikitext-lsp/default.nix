{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  dontNpmBuild = true;

  meta = {
    description = "Language server for MediaWiki wikitext, with WikiLint diagnostics";
    homepage = "https://github.com/bhsd-harry/vscode-extension-wikiparser";
    license = lib.licenses.gpl3Plus;
    mainProgram = "wikitext-lsp";
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };

  npmDepsHash = "sha256-71H92EJnysRNUrVLXCnyccT9morxRPmLWfCBvO5Xtnk=";
  pname = "wikitext-lsp";

  # The npm tarball ships no lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  src = fetchurl {
    hash = "sha256-iqiUvkr9lcdQ6B0GqUQK9+Op1jyRfyviQHNRyHCTB4E=";
    url = "https://registry.npmjs.org/wikitext-lsp/-/wikitext-lsp-${version}.tgz";
  };

  version = "1.8.0";
}
