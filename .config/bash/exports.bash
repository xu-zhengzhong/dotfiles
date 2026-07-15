export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-C.UTF-8}"

export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:erasedups
export LESS='-FRX'

if [[ -t 0 ]] && command -v tty >/dev/null 2>&1; then
	export GPG_TTY
	GPG_TTY=$(tty)
fi
