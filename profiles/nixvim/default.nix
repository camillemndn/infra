{ pkgs, ... }:

let
  # jupyter_client swaps a bare `python` in a kernelspec for its own interpreter
  # (molten's host); going through `env` resolves `python` from the PATH nvim was
  # started with, i.e. the current project's environment.
  jupyterKernels = pkgs.writeTextDir "share/jupyter/kernels/python3/kernel.json" (
    builtins.toJSON {
      argv = [
        "${pkgs.coreutils}/bin/env"
        "python"
        "-m"
        "ipykernel_launcher"
        "-f"
        "{connection_file}"
      ];
      display_name = "Python 3 (from PATH)";
      language = "python";
    }
  );
in
{
  programs.nixvim = {
    autoCmd = [
      {
        # Notebooks are edited as markdown, converted by the jupytext CLI.
        event = "BufReadCmd";
        pattern = "*.ipynb";
        callback.__raw = builtins.readFile ./ipynb_read.lua;
      }
      {
        event = "BufWriteCmd";
        pattern = "*.ipynb";
        callback.__raw = builtins.readFile ./ipynb_write.lua;
      }
      {
        # quarto runs the code cells of markdown buffers, notebooks included.
        event = "FileType";
        pattern = "markdown";
        callback.__raw = ''function() require("quarto").activate() end'';
      }
      {
        # Start the notebook's kernel and load its stored outputs.
        event = "FileType";
        pattern = "markdown";
        callback.__raw = builtins.readFile ./molten_init_notebook.lua;
      }
      {
        event = "BufWritePost";
        pattern = "*.ipynb";
        callback.__raw = builtins.readFile ./molten_export_on_save.lua;
      }
    ];

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    defaultEditor = true;

    # A project's own JUPYTER_PATH comes first and takes precedence.
    extraConfigLuaPre = ''
      vim.env.JUPYTER_PATH = (vim.env.JUPYTER_PATH and vim.env.JUPYTER_PATH .. ":" or "")
        .. "${jupyterKernels}/share/jupyter"
    '';

    extraPackages = with pkgs; [
      black
      nil
      nixfmt
      ormolu
      ripgrep
      rustywind
      (rWrapper.override { packages = with rPackages; [ styler ]; })
      shfmt
      stylelint
      superhtml
      python3Packages.jupytext
    ];

    keymaps = [
      {
        mode = "n";
        key = "<localleader>mi";
        action = "<cmd>MoltenInit<CR>";
        options.desc = "Molten: start kernel";
      }
      {
        mode = "n";
        key = "<localleader>mo";
        action = "<cmd>noautocmd MoltenEnterOutput<CR>";
        options.desc = "Molten: enter output window";
      }
      {
        mode = "n";
        key = "<localleader>rc";
        action.__raw = ''function() require("quarto.runner").run_cell() end'';
        options.desc = "Run cell";
      }
      {
        mode = "n";
        key = "<localleader>ra";
        action.__raw = ''function() require("quarto.runner").run_above() end'';
        options.desc = "Run cell and all above";
      }
      {
        mode = "n";
        key = "<localleader>rA";
        action.__raw = ''function() require("quarto.runner").run_all() end'';
        options.desc = "Run all cells";
      }
      {
        mode = "n";
        key = "<localleader>rl";
        action.__raw = ''function() require("quarto.runner").run_line() end'';
        options.desc = "Run line";
      }
      {
        mode = "v";
        key = "<localleader>r";
        action.__raw = ''function() require("quarto.runner").run_range() end'';
        options.desc = "Run selection";
      }
    ];

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
    };

    plugins = {
      aerial = {
        enable = true;
        settings.on_attach.__raw = builtins.readFile ./aerial_on_attach.lua;
      };

      bufferline.enable = true;

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      colorizer.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = builtins.readFile ./format_on_save.lua;
          formatters_by_ft = {
            bash = [ "shfmt" ];
            css = [ "stylelint" ];
            haskell = [ "ormolu" ];
            html = [
              "superhtml"
              "rustywind"
            ];
            nix = [ "nixfmt" ];
            python = [ "black" ];
            R = [ "air" ];
          };
        };
      };

      image = {
        enable = true;
        settings.backend = "kitty";
      };

      iron.enable = true;

      lilypond-suite.enable = true;

      lsp = {
        enable = true;

        servers = {
          air.enable = true;
          hls = {
            enable = true;
            installGhc = false;
            package = null;
          };
          nil_ls.enable = true;
          panache = {
            enable = true;
            package = pkgs.panache;
          };
          pyright.enable = true;
          superhtml.enable = true;
          tailwindcss.enable = true;
        };
      };

      molten = {
        enable = true;
        # wezterm.nvim, an optional image provider, is only a check input and is unfree.
        package = pkgs.vimPlugins.molten-nvim.overrideAttrs {
          checkInputs = with pkgs.vimPlugins; [
            image-nvim
            snacks-nvim
          ];
          nvimSkipModules = [ "load_wezterm_nvim" ];
        };
        settings = {
          image_provider = "image.nvim";
          output_win_max_height = 20;
          virt_text_output = true;
        };
      };

      quarto = {
        enable = true;
        settings.codeRunner = {
          enabled = true;
          default_method = "molten";
        };
      };
      otter.enable = true;

      telescope = {
        enable = true;
        keymaps = {
          "fb" = "buffers";
          "ff" = "find_files";
          "fg" = "live_grep";
          "fh" = "help_tags";
        };
      };

      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      vim-slime = {
        enable = true;
        settings.target = "neovim";
      };

      web-devicons.enable = true;

      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<localleader>m";
            group = "Molten";
          }
          {
            __unkeyed-1 = "<localleader>r";
            group = "Run";
          }
        ];
      };
    };

    userCommands = {
      FormatDisable = {
        bang = true;
        command.__raw = builtins.readFile ./FormatDisable.lua;
        desc = "Disable autoformat-on-save";
      };
      FormatEnable = {
        bang = true;
        command.__raw = builtins.readFile ./FormatEnable.lua;
        desc = "Enable autoformat-on-save";
      };
    };

    viAlias = true;
    vimAlias = true;
    withRuby = false;
  };
}
