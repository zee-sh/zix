# zix

Dendritic [nix-darwin](https://github.com/nix-darwin/nix-darwin) config for my Macs (and a NixOS box
later), built with [flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree).

Hosts are composed by **flipping toggles** (`zix.*`), not by curating import lists or maintaining branches.

> **Setting up a fresh machine?** Follow **[BOOTSTRAP.md](./BOOTSTRAP.md)** — the step-by-step runbook
> (SSH key, clone, Determinate Nix, first activation).

## Layout

- `flake.nix` — inputs only; `outputs = mkFlake (import-tree ./modules)`.
- `modules/toggles.nix` — the `zix.*` toggle surface (declared once, system-level).
- `modules/base.nix` — the darwin + home-manager feature catalogs.
- `modules/configurations/darwin.nix` — turns `configurations.darwin.<host>` into `darwinConfigurations`.
- `modules/profile/` — identity + `personal`/`work` presets.
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
