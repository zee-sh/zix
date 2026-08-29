# zix

Dendritic nix-darwin config for zeeshans' Macs. Two hosts: `m2air` (personal),
`m4max` (personal + work).

## Layout

Every `.nix` under `modules/` is auto-imported by `import-tree`. There is no
central import list — adding a file wires it in.

| Path | Purpose |
|---|---|
| `modules/toggles.nix` | declares every `zix.<feature>.enable` option |
| `modules/base.nix` | catalogue of modules a host receives |
| `modules/profile/` | `personal.nix`, `work.nix` — set toggle defaults |
| `modules/hosts/` | per-machine config; picks profiles, overrides toggles |
| `modules/homeManager/` | one file per feature, gated on its toggle |
| `modules/darwin/` | system-level: homebrew, macOS defaults, users |

**A `_`-prefixed directory is skipped by import-tree** (`_claude/`, `_neovim/`).
Those hold non-flake-parts inputs — wrapper specs, lua, JSON — pulled in
explicitly by the module beside them.

## Adding a feature

1. `modules/toggles.nix` — add `<name>.enable = lib.mkEnableOption "…";`
2. `modules/homeManager/<name>.nix` — `flake.modules.homeManager.<name>`, body
   wrapped in `lib.mkIf osConfig.zix.<name>.enable`
3. `modules/base.nix` — add `homeManager.<name>` to the catalogue
4. `modules/profile/personal.nix` (or `work.nix`) — `<name>.enable = lib.mkDefault true;`

Miss step 3 or 4 and the module is silently inert.

## Dotfiles

`config.dotfiles.make "<key>" "<repo-relative-path>"` returns either an in-store
path or an out-of-store symlink into the checkout, per
`zix.dotfiles.mutable.<key>` / `mutableByDefault`. m2air is mutable by default,
so edits to managed dotfiles apply without a rebuild.

**Mutable and `executable = true` are incompatible** — home-manager copies files
needing an exec bit and cannot read an out-of-store source. Invoke via `bash …`
instead.

## Conventions

- Comments: **3 lines maximum**. Explain *why*, not what.
- Pin every fetch. `fetchgit` without a `rev` tracks a moving `HEAD` and breaks
  builds when upstream commits.
- Annotate packages/casks with a URL and one-line description.
- Prefer nixpkgs; use homebrew for GUI casks and where the nixpkgs build is
  broken (see `rtk`).

## Workflow

```sh
just ci                      # fmt + eval — run before pushing
just build                   # build without activating
just switch                  # build and activate (sudo)
just hooks                   # one-time: enable the pre-commit formatting gate
```

`darwin-rebuild switch` needs interactive sudo, so it cannot run from a tool
call — hand that command to the user.

Work lands via PR off a `feat/` branch; CI runs `fmt` and `eval` for both hosts.
This repo is **private**, so Actions minutes are billed — macOS runners cost 10×
Linux, which is why both jobs run on `ubuntu-latest`.

## Working here

**Verify claims before making them.** This config's failure modes are invisible
to evaluation: a flake can evaluate and still fail on activation, and a
formatting change can look safe but alter the closure. Check the exit code, diff
the store path, resolve the symlink. Most of the real bugs found here — an
unpinned `fetchgit`, a mutable dotfile that could not be executable, a
pre-commit hook that read the working tree instead of the index — passed every
check that was not the specific one that mattered.

**Keep diffs surgical.** Pre-existing drift — unformatted files, stale docs —
stays out of a feature PR unless asked. Mixing it in makes the real change
unreviewable.

**Say when something looks wrong.** A derivation named for the wrong version, a
warning that survives its fix, a check that passes suspiciously fast: surface it
and confirm, rather than assuming either way.
