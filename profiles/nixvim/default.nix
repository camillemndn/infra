{ pkgs, ... }:

{
  programs.nixvim = {
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    defaultEditor = true;

    extraPackages = with pkgs; [
      black
      nil
      nixfmt-rfc-style
      ormolu
      ripgrep
      rustywind
      (rWrapper.override { packages = with rPackages; [ styler ]; })
      shfmt
      stylelint
      superhtml
    ];

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
    };

    plugins = {
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
            quarto = [
              "injected"
              "styler"
            ];
            R = [ "air" ];
          };
        };
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
          pyright.enable = true;
          superhtml.enable = true;
          tailwindcss.enable = true;
        };
      };

      molten.enable = true;
      quarto.enable = true;
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
