# sandbar writes these into an ANSIBLE MANAGED BLOCK in ~/.bashrc, which zsh
# never reads. Mirror them here so zsh gets the same environment.

export PATH="$HOME/.local/bin:$PATH"
export IS_SANDBOX=1
export VISUAL=vim
export EDITOR=vim

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if [ -f "$HOME/.config/sandbar/secrets.env" ]; then
  . "$HOME/.config/sandbar/secrets.env"
fi

# The managed block also wraps `claude` (sign-in on first run, then
# --dangerously-skip-permissions). Source sandbar's own copy rather than
# duplicating it, so a sandbar update to the wrapper reaches zsh too.
if [ -f "$HOME/.config/sandbar/claude-shell-wrapper.sh" ]; then
  . "$HOME/.config/sandbar/claude-shell-wrapper.sh"
fi
