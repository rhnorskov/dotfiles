# ============================================================================
# Shell Prompt Configuration
# ============================================================================
# This configures the command prompt appearance and behavior.

# ----------------------------------------------------------------------------
# Starship Prompt
# ----------------------------------------------------------------------------
# Starship is a minimal, fast, and customizable prompt for any shell.
# It shows useful context like:
#   - Current directory
#   - Git branch and status
#   - Programming language versions (Node, Python, etc.)
#   - Command execution time
#   - Exit codes of failed commands
#
# Configuration file: ~/.config/starship.toml
# Documentation: https://starship.rs
#
# IMPORTANT: This must be loaded AFTER all plugins are loaded
# to avoid conflicts with completion systems

eval "$(starship init zsh)"
