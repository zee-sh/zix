# Fresh Machine Bootstrap Runbook

Bring a freshly-wiped Mac up on this config. Do the steps in order.

> **This is an opinionated personal setup.** It installs a specific set of tools,
> shells and macOS defaults. Fork it and change what you disagree with — the
> toggle surface in `modules/toggles.nix` makes that cheap.

Throughout, replace:

| Placeholder | With |
|---|---|
| `<you>` | your GitHub username |
| `<repo>` | your fork (e.g. `<you>/zix`) |
| `<host>` | the hostname for this machine (e.g. `m2air`) |
| `<user>` | your macOS account name (`whoami`) |

---

## 0. macOS first-boot (manual, unavoidable)

1. Finish Setup Assistant, connect Wi-Fi, sign into your Apple ID (optional).
2. You do **not** need to change System Settings by hand — the config makes them
   declarative (see `modules/darwin/system-preferences.nix`). They apply in Step 5.
3. Install the Xcode Command Line Tools (needed for `git`):
   ```sh
   xcode-select --install
   ```
   Accept the GUI prompt and wait. Verify with `git --version`.

---

## 1. GitHub access — SSH key

```sh
ssh-keygen -t ed25519 -C "<host>" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub          # public key now on the clipboard
```

Open <https://github.com/settings/ssh/new>, title it `<host>`, paste, **Add SSH key**.

```sh
ssh -T git@github.com                    # type "yes" the first time
```

Expect: `Hi <you>! You've successfully authenticated...`

> Prefer HTTPS? Create a Personal Access Token and clone over HTTPS instead.
> SSH is recommended — it gives push access for free.

---

## 2. Clone

```sh
mkdir -p ~/projects/personal
cd ~/projects/personal
git clone git@github.com:<repo>.git zix
cd zix
```

Where you clone matters — Step 4 records the path.

---

## 3. Install Nix (Determinate)

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

Accept the prompts, then **open a new terminal** (or `exec $SHELL -l`) so `nix`
is on PATH. Verify with `nix --version`.

> The config sets `nix.enable = false`, so nix-darwin will not fight Determinate
> over `/etc/nix/nix.conf`.

---

## 4. Make it yours

**Edit `modules/profile/identity.nix`** — the only file you must change:

```nix
config.profile = {
  username = "<user>";
  fullName = "Your Name";
  email = "you@example.com";
  checkoutPath = "/Users/<user>/projects/personal/zix";   # where you cloned in Step 2
};
```

`checkoutPath` must be the absolute path to this checkout. Mutable dotfiles
symlink into it, and a wrong value gives dangling symlinks rather than a build
error.

**Then add a host.** Copy `modules/hosts/m2air.nix` to `modules/hosts/<host>.nix`
and change the `configurations.darwin."<host>"` key to match. `<host>` must equal
`scutil --get LocalHostName`, because `just switch` resolves the host from
`hostname -s`.

```nix
configurations.darwin."<host>".module =
  { config, ... }:
  {
    imports = [ darwin.base ];
    primaryUser = config.profile.username;
    system.stateVersion = 7;             # current baseline for a NEW machine

    zix.profiles.personal.enable = true;
    # zix.profiles.work.enable = true;   # adds cloud/k8s tooling

    zix.dotfiles.mutableByDefault = true;
    zix.dotfiles.path = config.profile.checkoutPath;
  };
```

Delete the host files you do not need. Turn individual features off with
`zix.<feature>.enable = false;` — `modules/toggles.nix` lists them all.

---

## 5. First activation

There is no `darwin-rebuild` yet on a fresh box, so build from the flake, then
activate:

```sh
cd ~/projects/personal/zix
nix build .#darwinConfigurations.<host>.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#<host>
```

- This is the first real build; it downloads/compiles the closure (several minutes).
- **If it aborts on `/etc/zshrc` or `/etc/bashrc` "in the way"**, move them aside
  and re-run the switch:
  ```sh
  sudo mv /etc/zshrc  /etc/zshrc.before-nix   2>/dev/null || true
  sudo mv /etc/bashrc /etc/bashrc.before-nix  2>/dev/null || true
  ```
- **If activation aborts on an existing dotfile** ("would be clobbered"), back it
  up and re-run — home-manager refuses to overwrite files it does not own.
- **If `sudo` cannot find nix**, use the full path:
  ```sh
  sudo /nix/var/nix/profiles/default/bin/darwin-rebuild switch --flake .#<host>
  ```

When it completes, **open a new terminal**.

---

## 6. Verify

```sh
darwin-rebuild --version
scutil --get LocalHostName               # → <host>
git config --get user.name               # → the name set in Step 4
```

Subsequent rebuilds (the first activation installs `just`):

```sh
just switch                              # or: sudo darwin-rebuild switch --flake .#<host>
just hooks                               # one-time: enable the pre-commit format gate
```

---

## 7. Not declarative yet

Install after Step 5:

- **Tailscale** — <https://tailscale.com/download/mac>, then sign in.
- **Claude Code** — `curl -fsSL https://claude.ai/install.sh | bash`
  (the config puts `~/.local/bin` on PATH for it).

---

## Capturing more settings

Anything you would otherwise set in System Settings belongs in
`modules/darwin/system-preferences.nix` (`system.defaults.*`). Run `defaults read`
before and after a manual change to find the key.
