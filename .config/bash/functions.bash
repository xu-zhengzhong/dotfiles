mkcd() {
	[[ $# -eq 1 ]] || {
		printf 'usage: mkcd DIRECTORY\n' >&2
		return 2
	}
	mkdir -p -- "$1" && cd -- "$1"
}

o() {
	command -v xdg-open >/dev/null 2>&1 || {
		printf 'o: xdg-open is not installed\n' >&2
		return 127
	}
	xdg-open "${1:-.}" >/dev/null 2>&1 &
}

server() {
	local port="${1:-8000}"
	command -v python3 >/dev/null 2>&1 || {
		printf 'server: python3 is not installed\n' >&2
		return 127
	}
	python3 -m http.server "$port"
}

extract() {
	[[ -f "$1" ]] || {
		printf 'extract: file not found: %s\n' "${1:-}" >&2
		return 2
	}
	case "$1" in
		*.tar.bz2|*.tbz2) tar xjf "$1" ;;
		*.tar.gz|*.tgz) tar xzf "$1" ;;
		*.tar.xz|*.txz) tar xJf "$1" ;;
		*.tar) tar xf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.gz) gunzip "$1" ;;
		*.xz) unxz "$1" ;;
		*.zip) unzip "$1" ;;
		*) printf 'extract: unsupported archive: %s\n' "$1" >&2; return 2 ;;
	esac
}
