# Linux dotfiles

Personal Bash, Git, and Readline configuration for Ubuntu. This repository is
authored like a normal Git repository and installed as a bare repository whose
work tree is the home directory.

It borrows the modular shell layout from
[Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), but
excludes the macOS defaults, Homebrew provisioning, personal identity, and
macOS-only commands.

## Publish your repository

This directory is already initialized with an initial commit. Review and
customize every file, commit any changes, then create an empty remote repository
and publish it:

```bash
git remote add origin git@github.com:YOUR_USER/dotfiles.git
git push -u origin main
```

Do not commit credentials, tokens, private keys, or machine-specific identity.

## Install on a new machine

Git is the only prerequisite. Replace the remote URL, then clone the repository
without a working copy:

```bash
git clone --bare git@github.com:YOUR_USER/dotfiles.git "$HOME/.dotfiles"
git --git-dir="$HOME/.dotfiles" show HEAD:.local/bin/dotfiles-bootstrap | bash
exec bash -l
```

The bootstrap backs up existing tracked paths to a timestamped
`~/.dotfiles-backup-*` directory before checking out. It does not overwrite
conflicting files silently.

The shell configuration defines this command:

```bash
dotfiles status
dotfiles add .bashrc .config/bash/aliases.bash
dotfiles commit -m "Update shell configuration"
dotfiles pull
dotfiles push
```

Only add explicit paths. The bare repository is configured to hide unrelated
untracked files in the home directory.

## Private and machine-local settings

The following optional files are loaded but intentionally not tracked:

- `~/.config/bash/local.bash`
- `~/.config/git/local.gitconfig`

Example Bash overrides:

```bash
export WORKSPACE="$HOME/work"
alias work='cd "$WORKSPACE"'
```

Example Git identity:

```gitconfig
[user]
	name = Your Name
	email = you@example.com
```

Restrict their permissions with `chmod 600` when they contain private values.

## Customize safely

Start with the existing modules under `.config/bash/` and keep each concern in
its corresponding file. Guard optional programs with `command -v`, and keep
distro- or host-specific values in `local.bash`.

Validate changes before pushing:

```bash
./tests/smoke.sh
```

This repository intentionally does not install packages or manage Vim, tmux,
desktop applications, or operating-system preferences.
