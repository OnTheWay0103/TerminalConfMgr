# Zsh Configuration
export LANG=en_US.UTF-8
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

autoload -Uz compinit
compinit

PS1='%F{green}%n@%m%f:%F{blue}%~%f$ '

alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi
