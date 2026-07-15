# Two-line Solarized prompt based on the original Mathias Bynens dotfiles.

prompt_git() {
	local status=''
	local branch_name=''
	local repo_url=''

	# Do not run Git status commands outside a work tree.
	command -v git >/dev/null 2>&1 || return
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

	# Prefer a branch name. For detached HEAD, show an exact ref or short SHA.
	branch_name=$(git symbolic-ref --quiet --short HEAD 2>/dev/null ||
		git describe --all --exact-match HEAD 2>/dev/null ||
		git rev-parse --short HEAD 2>/dev/null ||
		printf '(unknown)')

	# Detailed dirty checks are prohibitively slow in Chromium-sized repositories.
	repo_url=$(git config --get remote.origin.url 2>/dev/null || true)
	if [[ $repo_url == *chromium/src.git* ]]; then
		status='*'
	else
		# `+` means staged changes; `!` means unstaged changes.
		git diff --quiet --ignore-submodules --cached 2>/dev/null || status+='+'
		git diff-files --quiet --ignore-submodules -- 2>/dev/null || status+='!'

		# `?` means untracked files; `$` means the repository has a stash.
		[[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] && status+='?'
		git rev-parse --verify refs/stash >/dev/null 2>&1 && status+='$'
	fi

	[[ -n $status ]] && status=" [$status]"
	printf '%s%s%s%s' "$1" "$branch_name" "$2" "$status"
}

# Build the Solarized palette from terminfo when colors are available. Do not
# rewrite TERM: the terminal emulator should provide the correct value.
if [[ ${TERM:-} != dumb ]] && command -v tput >/dev/null 2>&1 &&
	tput setaf 1 >/dev/null 2>&1; then
	bold=$(tput bold)
	reset=$(tput sgr0)
	black=$(tput setaf 0)
	blue=$(tput setaf 33)
	cyan=$(tput setaf 37)
	green=$(tput setaf 64)
	orange=$(tput setaf 166)
	purple=$(tput setaf 125)
	red=$(tput setaf 124)
	violet=$(tput setaf 61)
	white=$(tput setaf 15)
	yellow=$(tput setaf 136)
else
	# Keep the prompt readable on terminals without usable terminfo.
	bold=''
	reset='\e[0m'
	black='\e[1;30m'
	blue='\e[1;34m'
	cyan='\e[1;36m'
	green='\e[1;32m'
	orange='\e[1;33m'
	purple='\e[1;35m'
	red='\e[1;31m'
	violet='\e[1;35m'
	white='\e[1;37m'
	yellow='\e[1;33m'
fi

# Highlight the user name when logged in as root.
if [[ ${USER:-} == root ]]; then
	user_style=$red
else
	user_style=$orange
fi

# Highlight the hostname when connected through SSH.
if [[ -n ${SSH_TTY:-} ]]; then
	host_style="${bold}${red}"
else
	host_style=$yellow
fi

# Set the terminal title and construct the original two-line prompt.
PS1='\[\033]0;\W\007\]'
PS1+="\[${bold}\]\n"
PS1+="\[${user_style}\]\u"
PS1+="\[${white}\] at "
PS1+="\[${host_style}\]\h"
PS1+="\[${white}\] in "
PS1+="\[${green}\]\w"
PS1+="\$(prompt_git \"\[${white}\] on \[${violet}\]\" \"\[${blue}\]\")"
PS1+='\n'
PS1+="\[${white}\]\\$ \[${reset}\]"
export PS1

# Use a visible continuation prompt for multi-line commands.
PS2="\[${yellow}\]→ \[${reset}\]"
export PS2
