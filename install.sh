#!/usr/bin/env bash
# Bootstrap shell preferences on a Debian/Ubuntu VM (built for sandbar guests).
# Safe to re-run: every step checks before it acts.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"

log() { printf '==> %s\n' "$*"; }

# Link $1 (inside the repo) to $2, moving any real file already there to $2.bak.
link() {
  local src="$DOTFILES_DIR/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return
  fi
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    log "backing up $dest to $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
  log "linked $dest"
}

# Packages
missing=()
for pkg in zsh fzf ripgrep; do
  dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
if [ "${#missing[@]}" -gt 0 ]; then
  log "installing ${missing[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
fi

# oh-my-zsh
if [ ! -d "$ZSH_DIR" ]; then
  log "installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Symlinks
link zsh/zshrc "$HOME/.zshrc"
link zsh/aliases.zsh "$ZSH_DIR/custom/aliases.zsh"
link zsh/env.zsh "$ZSH_DIR/custom/env.zsh"
link zsh/sandbar.zsh "$ZSH_DIR/custom/sandbar.zsh"
link vim/vimrc "$HOME/.vimrc"
link git/config "$HOME/.config/git/config"
mkdir -p "$HOME/.vim/undo"

# Default shell
zsh_path="$(command -v zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]; then
  log "setting login shell to $zsh_path"
  sudo chsh -s "$zsh_path" "$USER"
fi

log "done. Run 'exec zsh' now, or detach and re-attach with 'sand shell'."
log "If tmux still opens bash, run 'tmux kill-server' and re-attach."
