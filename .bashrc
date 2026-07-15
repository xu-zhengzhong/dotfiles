# Configure interactive Bash shells. Login shells reach this file through
# ~/.bash_profile, while scripts return immediately.

# Stop here when Bash is not interactive.
[[ $- == *i* ]] || return

# Load each concern from a separate module. The untracked local file is loaded
# last so a machine can override repository defaults without committing them.
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

# Preserve history across concurrent shells and refresh terminal dimensions
# after a window resize. Recursive globbing is available in Bash 4 and newer.
shopt -s histappend checkwinsize
shopt -s globstar 2>/dev/null || true

# Prefer Ubuntu's standard bash-completion path, with the traditional location
# as a fallback for other Debian-family installations.
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
	. /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
	. /etc/bash_completion
fi
