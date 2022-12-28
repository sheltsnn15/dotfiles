alias ls="exa"
alias ll="exa -alh"
alias tree="exa --tree"

if command -v bat >/dev/null; then
    alias cat="bat"
elif command -v batcat >/dev/null; then
    alias cat="batcat"
fi

eval "$(zoxide init bash)"
alias cd="z"

