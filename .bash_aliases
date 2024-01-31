alias ls="exa  --group-directories-first"
alias ll="exa  --group-directories-first -alh"
alias tree="exa --tree"

if command -v bat >/dev/null; then
    alias cat="bat"
elif command -v batcat >/dev/null; then
    alias cat="batcat"
fi

eval "$(zoxide init bash)"
alias cd="z"

alias nano="micro"
alias tmux="tmux -u"
alias lzd='lazydocker'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias kubectl="minikube kubectl --"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# ============================================================
# SECTION: Glow, .md file viewer
# ============================================================

viewmd() {
  if [[ -z "$1" ]]; then
    echo "Usage: viewmd <filename.md>"
  else
    glow -s dark "$1" | less -r
  fi
}

export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --info=inline --border --margin=1 --padding=1"

source ~/.local/share/fzf/fzf-tab-completion/bash/fzf-bash-completion.sh
bind -x '"\t": fzf_bash_completion'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export PATH="/home/shelton/.local/share/fzf/git-fuzzy/bin:$PATH"
