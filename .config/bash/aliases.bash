# Short interactive commands for navigation, inspection, Git, and shell
# management. These aliases assume GNU userland as provided by Ubuntu.

# Move upward through the directory tree with progressively more dots.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Use color and human-readable sizes for common directory listings.
alias ls='ls --color=auto'
alias l='ls -lhF'
alias la='ls -AlhF'
alias ll='ls -alhF'

# Color matching text when grep writes to a terminal.
alias grep='grep --color=auto'

# Keep frequent Git and bare-dotfiles commands short.
alias g='git'
alias dotfiles='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'

# Restart Bash as a login shell so every module is sourced again.
alias reload='exec bash -l'

# Display one PATH component per line for easier inspection.
alias path='printf "%s\n" "$PATH" | tr ":" "\n"'
