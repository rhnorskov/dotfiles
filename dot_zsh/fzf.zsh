# ============================================================================
# FZF (Fuzzy Finder) Configuration
# ============================================================================
# fzf is a command-line fuzzy finder that provides interactive searching
# and filtering capabilities throughout your shell.

# ----------------------------------------------------------------------------
# Load fzf shell integration
# ----------------------------------------------------------------------------
# This file is created by running: $(brew --prefix)/opt/fzf/install
# It sets up key bindings and completion for fzf:
#   - Ctrl+T: Search files and directories, insert path at cursor
#   - Ctrl+R: Search command history with fuzzy matching
#   - Alt+C:  Change directory using fuzzy search
#   - **<TAB>: Trigger fuzzy completion (e.g., vim **<TAB>)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ----------------------------------------------------------------------------
# FZF Color Theme (Dracula)
# ----------------------------------------------------------------------------
# Customize the appearance of fzf using Dracula color scheme
# This affects all fzf commands (Ctrl+T, Ctrl+R, Alt+C)
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# ----------------------------------------------------------------------------
# fzf-tab Plugin
# ----------------------------------------------------------------------------
# Replaces zsh's default TAB completion with fzf's fuzzy finder interface
# This makes all TAB completions searchable with fuzzy matching
# Example:
#   node <TAB>  → shows fuzzy searchable list of files
#   git checkout <TAB>  → shows fuzzy searchable list of branches
zinit light Aloxaf/fzf-tab

# Configure fzf-tab to use the same color scheme as fzf
# This ensures consistent appearance across all fuzzy search interfaces
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)
