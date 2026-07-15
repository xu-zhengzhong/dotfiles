__dotfiles_git_branch() {
	local branch
	branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
	if ! git diff --quiet --ignore-submodules -- 2>/dev/null ||
		! git diff --quiet --ignore-submodules --cached 2>/dev/null; then
		branch="$branch*"
	fi
	printf ' (%s)' "$branch"
}

case "${TERM:-}" in
	dumb) PS1='\u@\h:\w\$ ' ;;
	*) PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[35m\]$(__dotfiles_git_branch)\[\e[0m\]\$ ' ;;
esac
export PS1
