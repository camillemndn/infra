{ stdenv
, lib
, pandoc
, esbuild
, deno
, fetchurl
, dart-sass
, rWrapper
, rPackages
, extraRPackages ? [ ]
, makeWrapper
, python3
, extraPythonPackages ? ps: with ps; [ ]
}:

stdenv.mkDerivation rec {
  pname = "quarto";
  version = "1.4.449";
  src = fetchurl {
    url = "https://github.com/quarto-dev/quarto-cli/releases/download/v${version}/quarto-${version}-linux-amd64.tar.gz";
    sha256 = "sha256-7RoWAtQ4EcaSiXU0hOmu8MBZjYr52IW2yWXLmi6jLUM=";
  };


  nativeBuildInputs = [ makeWrapper ];

  dontStrip = true;

  preFixup = ''
    wrapProgram $out/bin/quarto \
      --prefix QUARTO_PANDOC : ${pandoc}/bin/pandoc \
      --prefix QUARTO_ESBUILD : ${esbuild}/bin/esbuild \
      --prefix QUARTO_DENO : ${deno}/bin/deno \
      --prefix QUARTO_DART_SASS : ${dart-sass}/bin/dart-sass \
      --prefix QUARTO_R : ${rWrapper.override { packages = [ rPackages.rmarkdown ] ++ extraRPackages; }}/bin/R \
      --prefix QUARTO_PYTHON : ${python3.withPackages (ps: with ps; [ jupyter ipython ] ++ (extraPythonPackages ps))}/bin/python3
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    rm -r bin/tools

    mv bin/* $out/bin
    mv share/* $out/share

    runHook preInstall
  '';

  meta = with lib; {
    description = "Open-source scientific and technical publishing system built on Pandoc";
    longDescription = ''
      Quarto is an open-source scientific and technical publishing system built on Pandoc.
      Quarto documents are authored using markdown, an easy to write plain text format.
    '';
    homepage = "https://quarto.org/";
    changelog = "https://github.com/quarto-dev/quarto-cli/releases/tag/v${version}";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ mrtarantoga ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode binaryBytecode ];
  };
}
