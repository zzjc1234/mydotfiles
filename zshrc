# INFO: ZSH PLUGIN

# Fix omz
autoload -U +X compinit && compinit
source <(kubectl completion zsh)
compinit

# Set up antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

compinit

autoload -Uz promptinit && promptinit

eval "$(zoxide init zsh)"




# INFO: DECORATION

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Color for man page
source ~/.manclr




# INFO: Alias

# alias python3=/usr/local/bin/python3.10
# alias pip=/usr/local/bin/pip3.11
alias python=/usr/local/anaconda3/bin/python
alias pip=/usr/local/anaconda3/bin/pip
alias lg=lazygit
alias rt=trash
alias ra=ranger
alias gcc=gcc-13
alias g++=g++-13
alias n=nvim
alias ls='lsd --group-dirs first'
alias tree='lsd --tree'
alias gls=/bin/ls
alias gtree=/usr/local/bin/tree
alias bat='bat --theme=ansi'
alias less="bat"
alias t="taskwarrior-tui"
alias tk="task"
alias s="sioyek"

# thefuck
eval $(thefuck --alias)

# homebrew
export HOMEBREW_NO_AUTO_UPDATE=1




# INFO: Conda

export PATH="/usr/local/anaconda3/bin:$PATH"  # commented out by conda initialize
export PATH="/usr/local/bin:$PATH"
#>>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/anaconda3/bin:$PATH"
				export PATH="/usr/local/anaconda3/env/bin:$PATH"
    fi
fi
unset __conda_setup
#<<< conda initialize <<<


# INFO: Pyenv

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source ~/.tools/scripts/proxy
source ~/.tools/scripts/pyenv
source ~/.tools/scripts/switch

~/.tools/scripts/bg.sh &
export PATH="/usr/local/opt/ruby/bin:$PATH"
