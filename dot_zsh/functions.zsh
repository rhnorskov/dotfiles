# ============================================================================
# Custom Functions
# ============================================================================
# User-defined shell functions for common tasks.

# ----------------------------------------------------------------------------
# mkcd - Create directory and cd into it
# ----------------------------------------------------------------------------
# Usage: mkcd <directory>
# Creates a directory (including parent directories) and immediately changes into it
function mkcd() {
  if [ -z "$1" ]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}
