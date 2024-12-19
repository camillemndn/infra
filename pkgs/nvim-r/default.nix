{
  lib,
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin rec {
  pname = "nvim-r";
  version = "0.9.20";

  src = fetchFromGitHub {
    owner = "jalvesaq";
    repo = "Nvim-R";
    rev = "v${version}";
    hash = "sha256-YD0Vg1/N7jdoAfu7oytb47vcZqBtExDFka9kCP4/Vlc=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vim plugin to work with R";
    homepage = "https://github.com/jalvesaq/Nvim-R";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };
}
