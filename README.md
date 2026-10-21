# linux-dotfiles

My shell setup for Linux VMs: zsh with oh-my-zsh, aliases, environment variables, vim and git defaults. It targets Debian guests created by [sandbar](https://github.com/Lullabot/sandbar), and works on any Debian/Ubuntu box with passwordless sudo.

## Install

Inside the VM (`sand shell <vm>`):

```sh
git clone https://github.com/m4olivei/linux-dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
```

Or from the Mac:

```sh
limactl shell <vm> bash -lc 'git clone https://github.com/m4olivei/linux-dotfiles ~/.dotfiles && ~/.dotfiles/install.sh'
```

Then run `exec zsh`, or detach and re-attach. If tmux still opens bash, run `tmux kill-server` and re-attach.

`install.sh` is idempotent. It:

1. Installs `zsh`, `fzf` and `ripgrep` with apt if they're missing.
2. Installs oh-my-zsh if `~/.oh-my-zsh` is missing.
3. Symlinks the files below. Any existing real file is moved to `*.bak` first.
4. Sets zsh as the login shell.

| Repo file         | Linked to                          |
| ----------------- | ---------------------------------- |
| `zsh/zshrc`       | `~/.zshrc`                         |
| `zsh/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh`  |
| `zsh/env.zsh`     | `~/.oh-my-zsh/custom/env.zsh`      |
| `zsh/sandbar.zsh` | `~/.oh-my-zsh/custom/sandbar.zsh`  |
| `vim/vimrc`       | `~/.vimrc`                         |
| `git/config`      | `~/.config/git/config`             |

## Bake it into a sandbar template

Install once, then snapshot the VM so later VMs start with everything in place:

```sh
sand template snapshot <vm> dev-base
sand create --template dev-base --name <new-vm>
```

A template goes stale when a sandbar upgrade changes its playbook. When that happens, create a plain VM, run the install command again, and take a new snapshot.

## Why the files are split this way

sandbar re-renders `~/.gitconfig`, `~/.tmux.conf` and a managed block in `~/.bashrc` every time it creates a VM. This repo leaves those files alone:

- **git:** settings go in `~/.config/git/config`, which git reads alongside `~/.gitconfig`. Name, email and the credential helper still come from sandbar. Commit signing is off because the VM has no GPG key.
- **zsh:** zsh doesn't read `~/.bashrc`. `zsh/sandbar.zsh` repeats what the managed block sets: `PATH`, `IS_SANDBOX`, `EDITOR`, the direnv hook, `~/.config/sandbar/secrets.env` and the `claude` wrapper (`~/.config/sandbar/claude-shell-wrapper.sh`).
- **prompt:** `zsh/zshrc` prefixes the prompt with `[sandbar:<hostname>]` when `IS_SANDBOX` is set, so a VM shell doesn't look like a host shell. It's set after oh-my-zsh loads, because the theme overwrites `PROMPT`.

## Local overrides and secrets

- **Per-VM tweaks:** put them in `~/.zshrc.local`. It is sourced last and isn't tracked.
- **Secrets:** never commit them, since this repo is public. Use sandbar's secrets store (press `e` on a VM tile).

## Updating

```sh
cd ~/.dotfiles && git pull
```

The symlinks pick up the changes. Open a new shell to load them.
