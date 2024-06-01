if command -v bat >/dev/null; then
	alias cat="bat"
elif command -v batcat >/dev/null; then
	alias cat="batcat"
fi

alias tmux="tmux -u"

# Enable color support for grep
if [ -x /usr/bin/dircolors ]; then
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# FZF Configuration
_fzf_comprun() {
	local command=$1
	shift
	case "$command" in
	cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
	*) fzf "$@" ;;
	esac
}
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --info=inline --border --margin=1 --padding=1"
source ~/.local/share/fzf/fzf-tab-completion/bash/fzf-bash-completion.sh
bind -x '"\t": fzf_bash_completion'

# Other Custom Aliases
alias viewxlsx="xlsx2csv \$1 | lynx --stdin"
alias viewdocx="pandoc \$1 -t plain | lynx --stdin"
alias viewtext="cat \$1 | lynx --stdin"
alias k=kubectl
complete -o default -F __start_kubectl k

# Other configurations
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export PATH="/home/shelton/.local/share/fzf/git-fuzzy/bin:$PATH"
