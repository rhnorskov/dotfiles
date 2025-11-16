# ============================================================================
# Zinit Plugin Manager Configuration
# ============================================================================
# Zinit is a flexible and fast Zsh plugin manager that allows us to load
# plugins on-demand and manage dependencies between them.

# ----------------------------------------------------------------------------
# Install Zinit if not already installed
# ----------------------------------------------------------------------------
# This auto-installs Zinit on first run if it's missing
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# ----------------------------------------------------------------------------
# Load Zinit
# ----------------------------------------------------------------------------
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# ----------------------------------------------------------------------------
# Initialize Zsh Completion System
# ----------------------------------------------------------------------------
# Must be called before using any completions
autoload -Uz compinit
compinit

# ----------------------------------------------------------------------------
# Additional Completions
# ----------------------------------------------------------------------------
# Generate chezmoi completions
if command -v chezmoi &>/dev/null; then
    eval "$(chezmoi completion zsh)"
fi

# Enable Zinit completion support
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ----------------------------------------------------------------------------
# Load Zinit Annexes (extensions)
# ----------------------------------------------------------------------------
# These annexes provide additional functionality to Zinit:
# - as-monitor: Monitors command outputs
# - bin-gem-node: Handles binaries, gems, and node modules
# - patch-dl: Allows patching and downloading of files
# - rust: Rust program support
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ----------------------------------------------------------------------------
# Load Plugins
# ----------------------------------------------------------------------------
# IMPORTANT: Load order matters!
# 1. zsh-completions must be loaded early to add completions to fpath
# 2. fzf-tab must be loaded after fzf (handled in fzf.zsh)
# 3. zsh-autosuggestions provides inline command suggestions
# 4. fast-syntax-highlighting MUST be loaded last for proper highlighting

# Additional completion definitions for Zsh
zinit light zsh-users/zsh-completions

# Provides inline suggestions based on your command history
# Press → (right arrow) to accept suggestions
zinit light zsh-users/zsh-autosuggestions

# Provides syntax highlighting as you type
# MUST be loaded last among completion plugins for proper functionality
zinit light zdharma-continuum/fast-syntax-highlighting
