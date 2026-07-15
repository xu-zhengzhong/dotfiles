# Define portable interactive defaults while preserving values supplied by the
# login environment or a machine-local configuration.

# Use Vim for terminal editing and less for paging unless already overridden.
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# C.UTF-8 is available on Ubuntu even when language-specific locales are not.
export LANG="${LANG:-C.UTF-8}"

# Keep a large deduplicated command history across shell sessions.
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:erasedups

# Preserve color, quit on short output, and avoid clearing the terminal.
export LESS='-FRX'

# Let GnuPG find the controlling terminal for prompts such as PIN entry.
if [[ -t 0 ]] && command -v tty >/dev/null 2>&1; then
	export GPG_TTY
	GPG_TTY=$(tty)
fi
