{
  home-manager.sharedModules = [
    (
      {
        config,
        lib,
        options,
        pkgs,
        ...
      }:

      lib.mkIf config.programs.vscodium.enable (
        # Only machines with Stylix have its options.
        lib.optionalAttrs (options ? stylix) {
          # Stylix scales by 4/3: 10.5 pt gives 14 px.
          stylix.targets.vscodium.fonts.override.sizes.terminal = 10.5;
        }
        // {
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
                  # Jupyter's extension pack, which it cannot install read-only; renderers for cell outputs.
                  ms-toolsai.jupyter-keymap
                  ms-toolsai.jupyter-renderers
                  ms-toolsai.vscode-jupyter-cell-tags
                  ms-toolsai.vscode-jupyter-slideshow
                  myriad-dreamin.tinymist
                  reditorsupport.r
                  # POST: servers reject GET queries past ~8 KB.
                  (RoweWilsonFrederiskHolme.wikitext.overrideAttrs (old: {
                    postInstall = (old.postInstall or "") + ''
                      substituteInPlace $out/share/vscode/extensions/RoweWilsonFrederiskHolme.wikitext/dist/extension-node.js \
                        --replace-fail 'i.request(r,{method:"GET"}),g=o.View' 'i.request(r,{method:"POST"}),g=o.View'
                    '';
                  }))
                ]
                ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                  {
                    publisher = "Bhsd";
                    name = "vscode-extension-wikiparser";
                    version = "1.8.0";
                    sha256 = "1f9a7fypzzjiqgi80icdx33gzhsks0p4gccyc1j4wl89pvjzy0v3";
                  }
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
                # The Wikitext extension starts the WikiParser language server.
                "wikitext.wikiparser.enable" = true;
                "wikiparser.linter.severity" = "errors and warnings";
                # Previews work anonymously; logging in is only needed to save pages.
                "wikitext.autoLogin" = "Never";
                # Redrawing animations while a cell runs takes CPU from the kernel.
                "workbench.reduceMotion" = "on";
              };
            };
          };
        }
      )
    )
  ];
}
