# m2air Fresh Bootstrap Runbook

Bring a freshly-wiped m2air up on the `zix` config. Do the steps in order.

Repo is **private** and there is **no SSH key** on this machine yet — handled in Step 1.

---

## 0. macOS first-boot (manual, unavoidable)

1. Finish Setup Assistant, connect Wi-Fi, sign into your Apple ID (optional).
2. You do **not** need to change System Settings by hand — the config makes them declarative
   (natural scrolling off, Finder/Dock/text tweaks; see `modules/darwin/system-preferences.nix`).
   They apply on the first `switch` in Step 4.
3. Install the Xcode Command Line Tools (needed for `git`):
   ```sh
   xcode-select --install
   ```
   Accept the GUI prompt and wait for it to finish. Verify:
   ```sh
   git --version
   ```

---

## 1. GitHub access — generate an SSH key, add it in the browser

You're signed into GitHub in the browser, so add a new key there:

```sh
ssh-keygen -t ed25519 -C "m2air" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub          # public key is now on the clipboard
```

Open <https://github.com/settings/ssh/new>, give it a title (e.g. `m2air`), paste, **Add SSH key**.

Test:
```sh
ssh -T git@github.com                    # type "yes" the first time
```
You should see: `Hi zee-sh! You've successfully authenticated...`

> Alternative if you'd rather not use SSH: create a Personal Access Token and clone over HTTPS
> (`git clone https://github.com/zee-sh/zix.git`, username = `zee-sh`, password = the token).
> SSH is recommended — it also gives you push access for free.

---

## 2. Directory structure + clone

```sh
mkdir -p ~/projects/personal
cd ~/projects/personal
git clone git@github.com:zee-sh/zix.git
cd zix
```

---

## 3. Install Nix (Determinate)

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

Accept the prompts. When it finishes, **open a new terminal** (or `exec $SHELL -l`) so `nix` is on PATH.
Verify:
```sh
nix --version                            # should mention Determinate Nix
```

> The config sets `nix.enable = false`, so nix-darwin will **not** fight Determinate over `/etc/nix/nix.conf`.

---

## 4. First activation (bootstrap nix-darwin)

There's no `darwin-rebuild` yet on a fresh box, so build the system from the flake, then activate it.
Run from inside the repo:

```sh
cd ~/projects/personal/zix
nix build .#darwinConfigurations.m2air.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#m2air
```

- This is the first real build — it downloads/compiles the closure (a few minutes).
- **If it aborts on `/etc/zshrc` or `/etc/bashrc` "in the way"**, back them up and re-run the `switch`:
  ```sh
  sudo mv /etc/zshrc  /etc/zshrc.before-nix   2>/dev/null || true
  sudo mv /etc/bashrc /etc/bashrc.before-nix  2>/dev/null || true
  sudo ./result/sw/bin/darwin-rebuild switch --flake .#m2air
  ```
- **If `sudo` can't find nix** (`sudo: nix: command not found`), use the full path:
  ```sh
  sudo /nix/var/nix/profiles/default/bin/darwin-rebuild switch --flake .#m2air
  ```

When it completes, **open a new terminal**.

---

## 5. Verify

```sh
darwin-rebuild --version
scutil --get LocalHostName               # → m2air
hostname -s                              # → m2air
git config --get user.name               # → Zeeshan Sanaullah  (from the HM git feature)
# natural scrolling off, Finder column view, etc. now in effect
```

Subsequent rebuilds (from the repo dir):
```sh
sudo darwin-rebuild switch --flake .#m2air
```
> The first activation installs `just`, so afterward you can use `just switch` instead of `darwin-rebuild`.

---

## 6. What's declarative

- **In the config:** base system, primary user, Touch-ID sudo, Nerd Fonts, git identity, macOS system
  preferences (natural scrolling off, Finder/Dock/text defaults), `nix.enable = false`, a core set of nix
  CLI packages, and Homebrew apps (casks/brews) via `nix-homebrew`.
- **Not yet:** shells (zsh/fish/nushell), starship, tmux/zellij, richer git (delta/lazygit), terminals
  (wezterm/ghostty/cmux) — added incrementally.

This is a working base you can live on while features are pulled in.

---

## 7. Post-activation apps (manual for now)

These aren't declarative yet. Install after Step 4:

- **Tailscale** — download the macOS app: <https://tailscale.com/download/mac>, then sign in.
  (Can later be managed via the `tailscale` Homebrew cask.)
- **Claude Code** — native install (recommended):
  ```sh
  curl -fsSL https://claude.ai/install.sh | bash
  ```
  Docs: <https://code.claude.com/docs/en/quickstart#native-install-recommended>

---

## Manual settings → nix (how to capture more)

Anything you'd otherwise set in System Settings goes in `modules/darwin/system-preferences.nix`
(`system.defaults.*`). Already captured: natural scrolling off, Finder (extensions/column view/pathbar),
Dock hot corner, login window, screenshots → Downloads, text-substitution off.

**When you change something by hand and want it permanent:** tell me what you changed (or the
`defaults write ...` command), and I'll fold it into that module so the next machine gets it for free.
