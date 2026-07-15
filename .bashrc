# Stop here when Bash is not interactive.
[[ $- == *i* ]] || return

for file in \
	"$HOME/.config/bash/path.bash" \
	"$HOME/.config/bash/exports.bash" \
	"$HOME/.config/bash/aliases.bash" \
	"$HOME/.config/bash/functions.bash" \
	"$HOME/.config/bash/prompt.bash" \
	"$HOME/.config/bash/local.bash"
do
	[[ -r "$file" ]] && . "$file"
done
unset file

shopt -s histappend checkwinsize
shopt -s globstar 2>/dev/null || true

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
	. /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
	. /etc/bash_completion
fi
