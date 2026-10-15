{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "wikitext-lsp";
  version = "1.8.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/wikitext-lsp/-/wikitext-lsp-${version}.tgz";
    hash = "sha256-iqiUvkr9lcdQ6B0GqUQK9+Op1jyRfyviQHNRyHCTB4E=";
  };

  # The npm tarball ships no lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-71H92EJnysRNUrVLXCnyccT9morxRPmLWfCBvO5Xtnk=";

  dontNpmBuild = true;

  meta = {
    description = "Language server for MediaWiki wikitext, with WikiLint diagnostics";
    homepage = "https://github.com/bhsd-harry/vscode-extension-wikiparser";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "wikitext-lsp";
    platforms = lib.platforms.all;
  };
}
