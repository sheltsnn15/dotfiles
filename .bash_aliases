alias ls="exa --icons --group-directories-first"
alias ll="exa --icons --group-directories-first -alh"
alias tree="exa --tree"

if command -v bat >/dev/null; then
    alias cat="bat"
elif command -v batcat >/dev/null; then
    alias cat="batcat"
fi

eval "$(zoxide init bash)"
alias cd="z"

alias lzd='lazydocker'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
