set -g fish_greeting
fish_config theme choose "Dracula Official"

# Local binaries
fish_add_path ~/.local/bin

# Homebrew
eval (/opt/homebrew/bin/brew shellenv)

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init2.fish 2>/dev/null; or true

# Mise
mise activate fish | source

# fzf: Ctrl+T (files), Ctrl+R (history), Alt+C (cd)
fzf --fish | source

# Starship prompt
starship init fish | source
