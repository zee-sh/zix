/*
  The neovim wrapper spec (nix-wrapper-modules).

  This directory is `_`-prefixed so import-tree skips it: these files are inputs to
  the wrapper, not flake-parts modules. `modules/homeManager/neovim.nix` imports this
  via `lib.modules.importApply`.

  Plugins and language servers come from nix — there is no Mason and no lazy.nvim
  fetching at runtime. `init.lua` beside this file stays real Lua; add a plugin to a
  spec below, then configure it there with `lze`.
*/
inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  options,
  ...
}:
let
  # Colorscheme name -> the plugin providing it. Keys are what
  # `vim.cmd.colorscheme` receives, so they must match the plugin's own scheme
  # names exactly; `settings.colorscheme` is an enum over these keys, so a typo
  # is caught at eval instead of throwing at VimEnter.
  colorschemes = with pkgs.vimPlugins; {
    "tokyonight" = tokyonight-nvim;
    "tokyonight-night" = tokyonight-nvim;
    "tokyonight-storm" = tokyonight-nvim;
    "tokyonight-moon" = tokyonight-nvim;
    "tokyonight-day" = tokyonight-nvim;
    "onedark_dark" = onedarkpro-nvim;
    "onedark_vivid" = onedarkpro-nvim;
    "onedark" = onedarkpro-nvim;
    "onelight" = onedarkpro-nvim;
    "moonfly" = vim-moonfly-colors;
  };
in
{
  imports = [ wlib.wrapperModules.neovim ];

  # Plugins fetched from flake inputs named `plugins-*`, reachable in specs as
  # `config.nvim-lib.neovimPlugins.<name-without-prefix>`.
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  # Lua config is provisioned by nix from this directory.
  # To iterate without rebuilding, swap this for the impure path instead:
  #   config.settings.config_directory = lib.generators.mkLuaInline "vim.fn.stdpath('config')";
  config.settings.config_directory = ./.;

  # lze (lazy-loading library) + its extras, loaded before everything else.
  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  # Colorscheme. init.lua runs `vim.cmd.colorscheme(nixInfo("tokyonight-night",
  # "settings", "colorscheme"))` at VimEnter, so this option and the spec below have
  # to agree — dropping either makes every startup throw "colorscheme not found".
  # init.lua also needs an lze spec listing the scheme name as a `colorscheme`
  # trigger, or the plugin never loads and the same error appears.
  options.settings.colorscheme = lib.mkOption {
    type = lib.types.enum (builtins.attrNames colorschemes);
    default = "tokyonight-night";
    description = "Colorscheme to apply; must be a key of the set in specs.colorscheme.";
  };
  config.specs.colorscheme = {
    lazy = true;
    data = colorschemes.${config.settings.colorscheme};
  };

  # ── Editor core ────────────────────────────────────────────────────────────
  config.specs.general = {
    after = [ "lze" ];
    lazy = true;
    runtimePkgs = with pkgs; [
      lazygit
      tree-sitter
      ripgrep
      fd
    ];
    data = with pkgs.vimPlugins; [
      {
        data = vim-sleuth; # detect tabstop/shiftwidth
        lazy = false;
      }
      snacks-nvim
      nvim-lspconfig
      nvim-surround
      vim-startuptime
      blink-cmp
      blink-compat
      cmp-cmdline
      colorful-menu-nvim
      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      nvim-lint
      conform-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
    ];
  };

  # ── Languages ──────────────────────────────────────────────────────────────
  # One spec per language: `runtimePkgs` puts the server/formatter on nvim's PATH,
  # `data` carries any plugins that language needs.

  config.specs.nix = {
    data = null;
    runtimePkgs = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [ lazydev-nvim ];
    runtimePkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.go = {
    data = null;
    runtimePkgs = with pkgs; [
      gopls
      gotools # goimports
      delve # debugger
    ];
  };

  config.specs.python = {
    data = null;
    runtimePkgs = with pkgs; [
      pyright
      ruff
    ];
  };

  config.specs.web = {
    data = null;
    runtimePkgs = with pkgs; [
      typescript-language-server
      vscode-langservers-extracted # html/css/json/eslint
      nodejs
    ];
  };

  config.specs.iac = {
    data = null;
    runtimePkgs = with pkgs; [
      terraform-ls
      yaml-language-server
      dockerfile-language-server
    ];
  };

  config.specs.shell = {
    data = null;
    runtimePkgs = with pkgs; [
      bash-language-server
      shellcheck
      shfmt
    ];
  };

  config.specs.markdown = {
    data = null;
    runtimePkgs = with pkgs; [ marksman ];
  };

  # ── Wiring (from the wrapper's tips-and-tricks) ────────────────────────────
  # Adds a `runtimePkgs` field to every spec, collected onto nvim's PATH. Packages
  # belonging to a disabled spec are left out of the derivation.
  config.specMods =
    {
      parentSpec ? null,
      parentOpts ? null,
      parentName ? null,
      config,
      ...
    }:
    {
      options.runtimePkgs = options.runtimePkgs // {
        description = ''
          Packages to put on neovim's PATH when this spec is enabled.
        '';
      };
    };
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

  # Lets init.lua ask which specs are enabled, e.g.
  #   require(vim.g.nix_info_plugin_name)(nil, "settings", "cats", "go")
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
