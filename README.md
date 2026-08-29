# zix

Dendritic [nix-darwin](https://github.com/nix-darwin/nix-darwin) config for macOS (and a NixOS box
later), built with [flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree).

Hosts are composed by **flipping toggles** (`zix.*`), not by curating import lists or maintaining branches.

> **This is an opinionated personal setup**, not a framework. It picks zsh, starship, neovim, ghostty,
> atuin, a particular set of macOS defaults, and a specific Homebrew cask list. It is structured so you
> can fork it and disagree cheaply — every feature sits behind a toggle you can flip off.

> **Setting up a fresh machine?** Follow **[BOOTSTRAP.md](./BOOTSTRAP.md)** — the step-by-step runbook
> (SSH key, clone, Determinate Nix, first activation).

## Using this yourself

1. Fork, then clone.
2. Edit **`modules/profile/identity.nix`** — username, name, email, checkout path. Hosts and features
   read from it, so it is the one file you always have to change.
3. Copy `modules/hosts/m2air.nix` to `modules/hosts/<your-host>.nix`, rename the `configurations.darwin`
   key inside to match, and delete the hosts you do not need. Then `git add` it — flakes ignore untracked
   files, so an unstaged host file is invisible to Nix. The filename is free; only the key matters.
4. Turn things off you do not want: `zix.<feature>.enable = false;` in your host, or drop the feature
   from the preset in `modules/profile/personal.nix`. `modules/toggles.nix` is the full list.

Things you will likely want to change: the Homebrew casks in `modules/darwin/homebrew.nix`, the macOS
defaults in `modules/darwin/system-preferences.nix`, the Claude Code permissions in
`modules/homeManager/_claude/settings.json` (they encode my tooling), and the `agent-sync` workspace in
`modules/homeManager/herdr.nix`.

## Layout

- `flake.nix` — inputs only; `outputs = mkFlake (import-tree ./modules)`.
- `modules/toggles.nix` — the `zix.*` toggle surface (declared once, system-level).
- `modules/base.nix` — the darwin + home-manager feature catalogs.
- `modules/configurations/darwin.nix` — turns `configurations.darwin.<host>` into `darwinConfigurations`.
- `modules/profile/` — `identity.nix` (edit this) + `personal`/`work` presets.
- `modules/darwin/`, `modules/homeManager/` — feature modules, each gated by a `zix.*` toggle.
- `modules/hosts/` — one file per machine: pick a preset, flip overrides.

## Toggles

Hosts are built by flipping `zix.*` switches, not by curating imports.

- **Declared once** (system-level) in `modules/toggles.nix` as `mkEnableOption`s (default off).
- **Catalog:** `base.nix` imports *every* feature; each feature gates its own `config` (never `imports`)
  behind its toggle — so all features are present but off until enabled.
- **Read:** darwin features use `config.zix.<f>.enable`; home-manager features use
  `osConfig.zix.<f>.enable` (HM runs as a nix-darwin module, so it sees the system toggle). One toggle
  surface drives both classes.
- **Set:** a preset (`profile/personal.nix`, `work.nix`) flips a batch with `lib.mkDefault true`; a host
  (`hosts/<name>.nix`) enables a preset and overrides individually (a host `= false` beats the preset).

```nix
# hosts/m2air.nix
zix.profiles.personal.enable = true;   # preset turns on a batch
# zix.docker.enable = false;           # per-host override

# a feature (home-manager), gated on the system toggle via osConfig
config = lib.mkIf osConfig.zix.git.enable { programs.git.enable = true; };
```

**Add a feature:** declare `zix.<f>.enable` in `toggles.nix` → create the feature module gating `config`
on it → import it in `base.nix` → enable it in a preset/host.

## Usage

```sh
just build   # build current host, no activation
just switch  # build + activate current host
just ci      # run the CI checks locally (fmt + eval both hosts)
just hooks   # one-time: enable the pre-commit formatting gate
just update  # update flake inputs
just check   # nix flake check
just fmt     # format nix files
```

First activation on a fresh machine is a manual bootstrap (before `just` exists) — see
[BOOTSTRAP.md](./BOOTSTRAP.md).

## Maintenance: garbage collection

There's no nix-darwin GC timer (it wouldn't work with `nix.enable = false`). Determinate handles it:
`determinate-nixd` runs **automatic, battery-aware** garbage collection out of the box
(`garbageCollector.strategy = "automatic"` by default in `/etc/determinate/config.json`).

```sh
nix store gc                                  # delete unreferenced paths now
nix-collect-garbage --delete-older-than 15d   # also drop generations older than 15 days
```

Inspect/change via `/etc/determinate/config.json` → `garbageCollector.strategy` (`automatic` | `disabled`);
can be pinned declaratively later via Determinate's nix-darwin module.
