#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
seed="$tmp/seed"
home="$tmp/home"

for file in \
	"$repo_root/.bash_profile" \
	"$repo_root/.bashrc" \
	"$repo_root/.config/bash/aliases.bash" \
	"$repo_root/.config/bash/exports.bash" \
	"$repo_root/.config/bash/functions.bash" \
	"$repo_root/.config/bash/path.bash" \
	"$repo_root/.config/bash/prompt.bash" \
	"$repo_root/.local/bin/dotfiles-bootstrap" \
	"$repo_root/tests/smoke.sh"
do
	bash -n "$file"
done

mkdir -p "$seed"
cp -a "$repo_root/." "$seed/"
rm -rf "$seed/.git"
git -C "$seed" init -q
git -C "$seed" config user.name 'Dotfiles Test'
git -C "$seed" config user.email 'dotfiles-test@example.invalid'
git -C "$seed" add .
git -C "$seed" commit -qm 'Test fixture'
git clone --bare -q "$seed" "$home/.dotfiles"

printf 'original bashrc\n' > "$home/.bashrc"
HOME="$home" git --git-dir="$home/.dotfiles" show HEAD:.local/bin/dotfiles-bootstrap |
	HOME="$home" bash

backup=$(find "$home" -maxdepth 1 -type d -name '.dotfiles-backup-*' -print -quit)
[[ -n "$backup" ]]
grep -qx 'original bashrc' "$backup/.bashrc"
[[ -f "$home/.config/bash/aliases.bash" ]]
[[ $(git --git-dir="$home/.dotfiles" config status.showUntrackedFiles) == no ]]

cat > "$home/.config/bash/local.bash" <<'EOF'
export DOTFILES_TEST_LOCAL=loaded
EOF
result=$(HOME="$home" bash --noprofile --rcfile "$home/.bashrc" -ic \
	'type mkcd >/dev/null; alias ll >/dev/null; alias dotfiles >/dev/null; path >/dev/null; printf "%s" "$DOTFILES_TEST_LOCAL"' 2>/dev/null)
[[ "$result" == loaded ]]

printf 'Smoke test passed\n'
