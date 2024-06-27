{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.code;
in
with lib;

{
  options.profiles.code = {
    enable = mkEnableOption "Code program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (quarto.override {
        extraRPackages = [ rPackages.plotly ];
        extraPythonPackages = ps: with ps; [ plotly ];
      })
      R
      rPackages.languageserver
    ];
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions =
        with pkgs.vscode-extensions;
        [
          vscodevim.vim
          ms-python.python
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "quarto";
            publisher = "quarto";
            version = "1.85.0";
            sha256 = "sha256-VnEqqS/2eQxdvq1DzOylNpb3fo2lmAcBJ8BxDj1JArs=";
          }
          {
            name = "R";
            publisher = "REditorSupport";
            version = "2.8.0";
            sha256 = "sha256-vapZKVBoDln12aBTUG9ipW425FXTWBqhjX2mQf+BAZw=";
          }
        ];
    };
  };
}
