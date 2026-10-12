{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.vscodium.enable {
  # Stylix sets VSCodium font sizes to 4/3 of the terminal size: 10.5 pt gives 14 px.
  stylix.targets.vscodium.fonts.override.sizes.terminal = 10.5;

  programs.vscodium = {
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions =
        with pkgs.vscode-extensions;
        [
          charliermarsh.ruff
          detachhead.basedpyright
          james-yu.latex-workshop
          jnoortheen.nix-ide
          mkhl.direnv
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-python-envs
          ms-toolsai.jupyter
          myriad-dreamin.tinymist
          reditorsupport.r
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "quarto";
            name = "quarto";
            version = "1.138.0";
            sha256 = "07wrx4hqwd98r1ckybc71n5bnwf20rj8rjskxvj8k0d1r3dsq2n7";
          }
        ];

      userSettings = {
        "direnv.restart.automatic" = true;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = lib.getExe pkgs.nixd;
        "nix.serverSettings".nixd.formatting.command = [ (lib.getExe pkgs.nixfmt) ];

        # basedpyright provides completion and type checking.
        "python.languageServer" = "None";
        "[python]"."editor.defaultFormatter" = "charliermarsh.ruff";

        "r.plot.useHttpgd" = true;

        # Redrawing animations while a cell runs takes CPU from the kernel.
        "workbench.reduceMotion" = "on";
      };
    };
  };
}
