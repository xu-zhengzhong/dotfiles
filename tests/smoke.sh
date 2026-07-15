#!/usr/bin/env bash
set -euo pipefail

# This test copies its repository fixture, so it must run from the compact
# authoring checkout rather than from the bare repository's $HOME work tree.
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if ! checkout_root=$(git -C "$repo_root" rev-parse --show-toplevel 2>/dev/null) ||
	[[ "$checkout_root" != "$repo_root" ]]; then
	printf 'smoke.sh: run this test from the normal authoring checkout, not the installed bare work tree\n' >&2
	exit 2
fi

# Isolate every install, repository, and shell-startup side effect under /tmp.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
seed="$tmp/seed"
home="$tmp/home"

# Reject syntax errors in every Bash file before building the Git fixture.
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

# Create a self-contained source repository and clone it in bare-install form.
mkdir -p "$seed"
cp -a "$repo_root/." "$seed/"
rm -rf "$seed/.git"
git -C "$seed" init -q
git -C "$seed" config user.name 'Dotfiles Test'
git -C "$seed" config user.email 'dotfiles-test@example.invalid'
git -C "$seed" add .
git -C "$seed" commit -qm 'Test fixture'
git clone --bare -q "$seed" "$home/.dotfiles"

# Confirm an initial install backs up a conflicting home file and configures Git.
printf 'original bashrc\n' > "$home/.bashrc"
HOME="$home" git --git-dir="$home/.dotfiles" show HEAD:.local/bin/dotfiles-bootstrap |
	HOME="$home" bash

backup=$(find "$home" -maxdepth 1 -type d -name '.dotfiles-backup-*' -print -quit)
[[ -n "$backup" ]]
grep -qx 'original bashrc' "$backup/.bashrc"
[[ -f "$home/.config/bash/aliases.bash" ]]
[[ $(git --git-dir="$home/.dotfiles" config status.showUntrackedFiles) == no ]]

# Exercise the installed-repository update path, including a removed file.
printf '\n# updated fixture\n' >> "$seed/.bashrc"
git -C "$seed" rm -q .inputrc
printf 'updated\n' > "$seed/.update-marker"
git -C "$seed" add .bashrc .update-marker
git -C "$seed" commit -qm 'Update fixture'
git -C "$seed" push -q "$home/.dotfiles" main

printf 'locally modified bashrc\n' > "$home/.bashrc"
HOME="$home" git --git-dir="$home/.dotfiles" show HEAD:.local/bin/dotfiles-bootstrap |
	HOME="$home" bash

update_backup=$(find "$home" -maxdepth 1 -type d -name '.dotfiles-backup-*' -print |
	sort | tail -n 1)
grep -qx 'locally modified bashrc' "$update_backup/.bashrc"
[[ -f "$update_backup/.inputrc" ]]
grep -q '^# updated fixture$' "$home/.bashrc"
[[ -f "$home/.update-marker" && ! -e "$home/.inputrc" ]]
[[ -z $(git -C "$home" --git-dir="$home/.dotfiles" --work-tree="$home" status --short) ]]

# Verify that the optional local Bash file loads after the tracked modules and
# that the public aliases, functions, PATH helper, and prompt are available.
cat > "$home/.config/bash/local.bash" <<'EOF'
export DOTFILES_TEST_LOCAL=loaded
EOF
result=$(HOME="$home" bash --noprofile --rcfile "$home/.bashrc" -ic \
	'type mkcd >/dev/null; alias ll >/dev/null; alias dotfiles >/dev/null; path >/dev/null; [[ $PS1 == *" at "* && $PS1 == *" in "* && $PS1 == *prompt_git* ]]; printf "%s" "$DOTFILES_TEST_LOCAL"' 2>/dev/null)
[[ "$result" == loaded ]]

# Build a small repository for deterministic prompt status tests.
prompt_repo="$tmp/prompt-repo"
git -C "$tmp" init -q prompt-repo
git -C "$prompt_repo" config user.name 'Dotfiles Test'
git -C "$prompt_repo" config user.email 'dotfiles-test@example.invalid'
printf 'tracked\n' > "$prompt_repo/tracked"
git -C "$prompt_repo" add tracked
git -C "$prompt_repo" commit -qm 'Initial prompt fixture'

clean=$(cd "$prompt_repo" && TERM=dumb USER=tester bash -c \
	'. "$1"; prompt_git "" ""' bash "$home/.config/bash/prompt.bash")
[[ "$clean" == main ]]

# A repository can report staged, unstaged, and untracked changes together.
printf 'staged\n' >> "$prompt_repo/tracked"
git -C "$prompt_repo" add tracked
printf 'unstaged\n' >> "$prompt_repo/tracked"
printf 'untracked\n' > "$prompt_repo/untracked"
dirty=$(cd "$prompt_repo" && TERM=dumb USER=tester bash -c \
	'. "$1"; prompt_git "" ""' bash "$home/.config/bash/prompt.bash")
[[ "$dirty" == 'main [+!?]' ]]

# Stashed work receives its own marker even when the work tree is clean.
git -C "$prompt_repo" stash push -qu
stashed=$(cd "$prompt_repo" && TERM=dumb USER=tester bash -c \
	'. "$1"; prompt_git "" ""' bash "$home/.config/bash/prompt.bash")
[[ "$stashed" == 'main [$]' ]]

# Detached HEAD falls back to an exact ref description or abbreviated commit.
git -C "$prompt_repo" checkout --detach -q
detached=$(cd "$prompt_repo" && TERM=dumb USER=tester bash -c \
	'. "$1"; prompt_git "" ""' bash "$home/.config/bash/prompt.bash")
[[ -n "$detached" && "$detached" != main* && "$detached" == *'[$]' ]]

# Root and SSH sessions use the alert colors selected by the prompt module.
styles=$(TERM=dumb USER=root SSH_TTY=/dev/pts/test bash -c \
	'. "$1"; [[ $user_style == "$red" && $host_style == "${bold}${red}" ]] && printf ok' \
	bash "$home/.config/bash/prompt.bash")
[[ "$styles" == ok ]]

# Vim must recreate state directories and load the bundled Solarized theme.
rm -rf "$home/.vim/backups" "$home/.vim/swaps" "$home/.vim/undo"
HOME="$home" vim --cmd "set runtimepath^=$home/.vim" -Nu "$home/.vimrc" \
	-n -es -i NONE \
	-c 'if !exists("g:colors_name") || g:colors_name !=# "solarized" | cquit | endif' \
	-c 'qall'
[[ -d "$home/.vim/backups" && -d "$home/.vim/swaps" && -d "$home/.vim/undo" ]]

# When tmux is installed, parse the configuration in an isolated server and
# confirm that Ctrl+A replaced the default prefix.
if command -v tmux >/dev/null 2>&1; then
	tmux_socket="dotfiles-test-$$"
	tmux -L "$tmux_socket" -f "$home/.tmux.conf" new-session -d
	[[ $(tmux -L "$tmux_socket" show-options -gv prefix) == C-a ]]
	tmux -L "$tmux_socket" kill-server
fi

printf 'Smoke test passed\n'
