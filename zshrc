# alias
alias ls='lsd --group-dirs first'
alias tree='lsd --tree'
alias bat='bat --theme=ansi'
alias less='bat'
alias lg='lazygit'
alias codex="https_proxy=http://127.0.0.1:10870 codex"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
s() { nohup sioyek "$1" > /dev/null 2>&1 & }


# antidote
if [[ -r /usr/share/zsh-antidote/antidote.zsh ]]; then
  source /usr/share/zsh-antidote/antidote.zsh
elif [[ -r "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
elif [[ -r "${ZDOTDIR:-$HOME}/antidote/antidote.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/antidote/antidote.zsh"
fi

if (( $+functions[antidote] )); then
  antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
fi

(( $+functions[__zzjc_zsh_autocomplete_rebind] )) && __zzjc_zsh_autocomplete_rebind

source ~/.p10k.zsh

if [[ -f "$HOME/.config/fzf/settings" ]]; then
  source "$HOME/.config/fzf/settings"
fi

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

### PATH

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell bash)"
fi

export PATH="$HOME/.local/bin:$PATH"

if (( $+commands[herdr] )); then
  source <(herdr completion zsh)
fi

# >>> Codex installer >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< Codex installer <<<
