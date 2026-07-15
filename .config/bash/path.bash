# Build PATH without adding missing directories or duplicate entries.

# Prepend one directory when it exists and is not already present in PATH.
path_prepend() {
	[[ -d "$1" ]] || return 0
	case ":$PATH:" in
		*":$1:"*) ;;
		*) PATH="$1${PATH:+:$PATH}" ;;
	esac
}

# Give user-installed programs priority over system-wide programs.
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# Keep the temporary setup helper out of the interactive shell namespace.
unset -f path_prepend
