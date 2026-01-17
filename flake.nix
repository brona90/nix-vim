{
  description = "LazyVim configuration with Nix (immutable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        isDarwin = pkgs.stdenv.isDarwin;
        isLinux = pkgs.stdenv.isLinux;

        # VictorMono Nerd Font
        victorMonoNerdFont = pkgs.nerd-fonts.victor-mono;

        # Nvim config from repo (immutable)
        nvimConfig = pkgs.stdenv.mkDerivation {
          name = "nvim-config";
          src = ./nvim-config;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out
            cp -r $src/. $out/
          '';
        };

        # Pre-fetch lazy.nvim (plugin manager)
        lazyNvim = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "lazy.nvim";
          rev = "v11.16.2";
          sha256 = "sha256-48i6Z6cwccjd5rRRuIyuuFS68J0lAIAEEiSBJ4Vq5vY=";
        };

        # Pre-fetch LazyVim distribution
        lazyVimDistro = pkgs.fetchFromGitHub {
          owner = "LazyVim";
          repo = "LazyVim";
          rev = "v15.13.0";
          sha256 = "sha256-pm1B4tdHqSV8n+hM78asqw5WNdMfC5fUSiZcjg8ZtAg=";
        };

        # Use vimPlugins from nixpkgs where available (already has correct hashes)
        vp = pkgs.vimPlugins;

        # Build the plugins directory using nixpkgs vimPlugins
        pluginsDir = pkgs.linkFarm "lazy-plugins" [
          {
            name = "lazy.nvim";
            path = lazyNvim;
          }
          {
            name = "LazyVim";
            path = lazyVimDistro;
          }
          # UI
          {
            name = "tokyonight.nvim";
            path = vp.tokyonight-nvim;
          }
          {
            name = "catppuccin";
            path = vp.catppuccin-nvim;
          }
          {
            name = "which-key.nvim";
            path = vp.which-key-nvim;
          }
          {
            name = "noice.nvim";
            path = vp.noice-nvim;
          }
          {
            name = "nui.nvim";
            path = vp.nui-nvim;
          }
          {
            name = "nvim-notify";
            path = vp.nvim-notify;
          }
          {
            name = "mini.icons";
            path = vp.mini-icons;
          }
          {
            name = "dressing.nvim";
            path = vp.dressing-nvim;
          }
          {
            name = "bufferline.nvim";
            path = vp.bufferline-nvim;
          }
          {
            name = "lualine.nvim";
            path = vp.lualine-nvim;
          }
          {
            name = "indent-blankline.nvim";
            path = vp.indent-blankline-nvim;
          }
          {
            name = "mini.indentscope";
            path = vp.mini-indentscope;
          }
          {
            name = "dashboard-nvim";
            path = vp.dashboard-nvim;
          }
          # Editor
          {
            name = "neo-tree.nvim";
            path = vp.neo-tree-nvim;
          }
          {
            name = "nvim-spectre";
            path = vp.nvim-spectre;
          }
          {
            name = "telescope.nvim";
            path = vp.telescope-nvim;
          }
          {
            name = "telescope-fzf-native.nvim";
            path = vp.telescope-fzf-native-nvim;
          }
          {
            name = "flash.nvim";
            path = vp.flash-nvim;
          }
          {
            name = "gitsigns.nvim";
            path = vp.gitsigns-nvim;
          }
          {
            name = "vim-illuminate";
            path = vp.vim-illuminate;
          }
          {
            name = "mini.bufremove";
            path = vp.mini-bufremove;
          }
          {
            name = "trouble.nvim";
            path = vp.trouble-nvim;
          }
          {
            name = "todo-comments.nvim";
            path = vp.todo-comments-nvim;
          }
          # Treesitter
          {
            name = "nvim-treesitter";
            path = vp.nvim-treesitter.withAllGrammars;
          }
          {
            name = "nvim-treesitter-textobjects";
            path = vp.nvim-treesitter-textobjects;
          }
          {
            name = "nvim-ts-autotag";
            path = vp.nvim-ts-autotag;
          }
          # LSP
          {
            name = "nvim-lspconfig";
            path = vp.nvim-lspconfig;
          }
          {
            name = "mason.nvim";
            path = vp.mason-nvim;
          }
          {
            name = "mason-lspconfig.nvim";
            path = vp.mason-lspconfig-nvim;
          }
          {
            name = "neoconf.nvim";
            path = vp.neoconf-nvim;
          }
          {
            name = "lazydev.nvim";
            path = vp.lazydev-nvim;
          }
          # Completion
          {
            name = "nvim-cmp";
            path = vp.nvim-cmp;
          }
          {
            name = "cmp-nvim-lsp";
            path = vp.cmp-nvim-lsp;
          }
          {
            name = "cmp-buffer";
            path = vp.cmp-buffer;
          }
          {
            name = "cmp-path";
            path = vp.cmp-path;
          }
          {
            name = "LuaSnip";
            path = vp.luasnip;
          }
          {
            name = "friendly-snippets";
            path = vp.friendly-snippets;
          }
          # Formatting & Linting
          {
            name = "conform.nvim";
            path = vp.conform-nvim;
          }
          {
            name = "nvim-lint";
            path = vp.nvim-lint;
          }
          # Utilities
          {
            name = "plenary.nvim";
            path = vp.plenary-nvim;
          }
          {
            name = "nvim-web-devicons";
            path = vp.nvim-web-devicons;
          }
          {
            name = "persistence.nvim";
            path = vp.persistence-nvim;
          }
          {
            name = "mini.pairs";
            path = vp.mini-pairs;
          }
          {
            name = "mini.ai";
            path = vp.mini-ai;
          }
          {
            name = "mini.surround";
            path = vp.mini-surround;
          }
          {
            name = "mini.comment";
            path = vp.mini-comment;
          }
          {
            name = "vim-startuptime";
            path = vp.vim-startuptime;
          }
          {
            name = "snacks.nvim";
            path = vp.snacks-nvim;
          }
          {
            name = "ts-comments.nvim";
            path = vp.ts-comments-nvim;
          }
          {
            name = "blink.cmp";
            path = vp.blink-cmp;
          }
          {
            name = "sqlite.lua";
            path = vp.sqlite-lua;
          }
        ];

        # Core dependencies for LazyVim
        coreDeps =
          with pkgs;
          [
            git
            curl
            wget
            unzip
            gnutar
            gzip
            ripgrep
            fd
            fzf
            gnumake
            cmake
            pkg-config
            # Additional tools for clean health check
            sqlite # for Snacks.picker frecency
            ast-grep # for grug-far extended capabilities
          ]
          ++ (
            if isLinux then
              [
                xclip
                wl-clipboard
                gcc
              ]
            else
              [ ]
          );

        # Language servers
        lspServers = with pkgs; [
          lua-language-server
          nil # lighter than nixd
          pyright
          ruff
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted
          gopls
          delve
          rust-analyzer
          nodePackages.bash-language-server
          yaml-language-server
          taplo
          marksman
          dockerfile-language-server
          terraform-ls
        ];

        # Formatters
        formatters = with pkgs; [
          stylua
          nixfmt
          alejandra
          black
          isort
          nodePackages.prettier
          gofumpt
          shfmt
          taplo
        ];

        # Linters
        linters = with pkgs; [
          ruff
          pylint
          nodePackages.eslint
          shellcheck
          markdownlint-cli
          yamllint
        ];

        # Debuggers
        debuggers = with pkgs; [
          python3Packages.debugpy
          delve
        ];

        # Additional tools
        additionalTools = with pkgs; [
          lazygit
          delta
          tree
          nodejs_22
          python3
        ];

        treesitterCLI = pkgs.tree-sitter;

        allDeps =
          coreDeps
          ++ lspServers
          ++ formatters
          ++ linters
          ++ debuggers
          ++ additionalTools
          ++ [ treesitterCLI ];

        neovimPackage = pkgs.neovim.override {
          withNodeJs = true;
          withPython3 = true;
          withRuby = false;
        };

        # Wrapper that uses immutable config and pre-fetched plugins
        lazyVimWrapper = pkgs.writeShellScriptBin "lvim" ''
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
          export FONTCONFIG_PATH=${victorMonoNerdFont}/share/fonts

          # Set SSL certificate path for git
          export GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

          # Use XDG directories for mutable data
          export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
          export XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}
          export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}

          # Ensure directories exist
          mkdir -p "$XDG_DATA_HOME/nvim/lazy"
          mkdir -p "$XDG_STATE_HOME/nvim"
          mkdir -p "$XDG_CACHE_HOME/nvim"

          # Add path to dependencies
          export PATH="${pkgs.lib.makeBinPath allDeps}:$PATH"

          # Set sqlite library path for sqlite.lua
          export LIBSQLITE="${pkgs.sqlite.out}/lib/libsqlite3.so"

          # Symlink pre-fetched plugins if not already done
          for plugin in ${pluginsDir}/*; do
            name=$(basename "$plugin")
            target="$XDG_DATA_HOME/nvim/lazy/$name"
            if [ ! -e "$target" ]; then
              ln -sf "$plugin" "$target"
            fi
          done

          # Run neovim with immutable config from Nix store
          exec ${neovimPackage}/bin/nvim -u "${nvimConfig}/init.lua" "$@"
        '';

        lazyVimPackage = pkgs.buildEnv {
          name = "lazyvim-with-tools";
          paths = [ lazyVimWrapper ] ++ allDeps ++ [ victorMonoNerdFont ];
        };

      in
      {
        packages = {
          default = lazyVimPackage;
          lvim = lazyVimWrapper;
          neovim = neovimPackage;
        };

        apps.default = {
          type = "app";
          program = "${lazyVimWrapper}/bin/lvim";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ lazyVimPackage ];

          shellHook = ''
            echo "LazyVim environment (immutable config + pre-fetched plugins)"
            echo ""
            echo "Config is managed by Nix. To change config:"
            echo "  1. Edit nvim-config/"
            echo "  2. nix build && commit && push"
            echo "  3. nfu && hms on target machine"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}
