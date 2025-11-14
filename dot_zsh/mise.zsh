# ============================================================================
# Mise Configuration
# ============================================================================
# Mise is a polyglot tool version manager (replacement for asdf, nvm, pyenv, etc.)
# It manages development tool versions per project using .mise.toml or .tool-versions
#
# Documentation: https://mise.jdx.dev

# ----------------------------------------------------------------------------
# Activate Mise
# ----------------------------------------------------------------------------
# This sets up mise's shims and environment for managing tool versions
eval "$(mise activate zsh)"

# ----------------------------------------------------------------------------
# Bun Global Binaries
# ----------------------------------------------------------------------------
# Add Bun's global bin directory to PATH for globally installed packages
export PATH="$HOME/.bun/bin:$PATH"