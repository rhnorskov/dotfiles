# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **chezmoi** dotfiles repository that manages system configuration for macOS machines. It supports two machine types (work/private) with conditional configurations and uses 1Password for secret management.

## Key Commands

### Chezmoi Operations
```bash
# Apply all changes from source to home directory
chezmoi apply

# Apply with verbose output
chezmoi apply -v

# Preview what would change (dry run)
chezmoi diff

# Edit a file in the source directory
chezmoi edit ~/.zshrc

# Execute a template to see the rendered output
chezmoi execute-template < Brewfile.tmpl

# Check repository status
chezmoi status

# Update from git and apply changes
chezmoi update
```

### Testing Changes
```bash
# Validate templates render correctly
chezmoi execute-template < Brewfile.tmpl > /tmp/test-brewfile

# Test a specific script without applying
chezmoi execute-template < run_once_10-setup-homebrew.sh.tmpl > /tmp/test-script.sh
bash -n /tmp/test-script.sh  # Syntax check
```

## Architecture

### Machine Type System
The repository uses `.chezmoi.toml.tmpl` to prompt for machine type on first run (work/private). This variable (`{{ .machine.type }}`) is available in all templates and controls:
- Brewfile package selection
- Application-specific configurations
- Script execution logic

### File Naming Conventions
Chezmoi uses special prefixes to determine file handling:
- `dot_` → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` → file excluded from git (e.g., `private_dot_claude/settings.json`)
- `run_once_` → script runs once
- `run_onchange_` → script runs when template content changes (tracked via SHA256 comment)
- `run_<N>-` → scripts run in numeric order (e.g., `run_20-`, `run_30-`)
- `.tmpl` → file is templated (processed by chezmoi's template engine)

### Bootstrap Sequence
1. **run_once_10-setup-homebrew.sh.tmpl** - Installs Homebrew (macOS only)
2. **run_onchange_brew-bundle.sh.tmpl** - Generates Brewfile from template and installs packages
3. **run_20-setup-1password.sh.tmpl** - Validates 1Password CLI is configured
4. **run_30-setup-claude.sh.tmpl** - Configures Claude Code with Context7 MCP server
5. **run_once_after_configure-macos.sh.tmpl** - Sets macOS system preferences

### Dependency Management
- **Brewfile.tmpl**: Central package definition with conditional work/private sections
- **run_onchange_brew-bundle.sh.tmpl**: Automatically reruns when Brewfile.tmpl changes (SHA256 tracking)
- Scripts use `set -euo pipefail` for strict error handling
- Scripts check for command availability before use (`command -v`)

### Secret Management
The repository integrates with 1Password:
- Uses `{{ onepasswordRead "op://..." }}` in templates
- Requires 1Password CLI (`op`) and configured account
- Example: Claude Code Context7 API key in `run_30-setup-claude.sh.tmpl`

### Template Variables
Available in all `.tmpl` files:
- `{{ .machine.type }}` - "work" or "private"
- `{{ .chezmoi.os }}` - Operating system (darwin, linux, etc.)
- `{{ .chezmoi.sourceDir }}` - Path to this repository
- `{{ .chezmoi.homeDir }}` - User's home directory

## Configuration Files

### Shell Configuration
- `dot_zshrc` - Main zsh configuration
- `dot_zshenv` - Environment variables (PATH, etc.)
- `dot_zprofile` - Login shell configuration
- `dot_fzf.zsh` - FZF fuzzy finder configuration

### Application Configurations
- `dot_config/starship.toml` - Starship prompt
- `dot_config/mise/config.toml` - Mise version manager
- `dot_config/ghostty/config` - Ghostty terminal emulator
- `dot_config/private_karabiner/private_karabiner.json` - Karabiner keyboard customization
- `private_dot_claude/settings.json` - Claude Code settings

### Git Configuration
- `dot_gitconfig` - Git user configuration and aliases

## Development Workflow

When modifying this repository:

1. **Edit source files directly** in the chezmoi source directory (`~/.local/share/chezmoi`)
2. **Use conditional logic** for machine-specific configurations:
   ```
   {{- if eq .machine.type "work" }}
   # work-specific config
   {{- end }}
   ```
3. **Test templates** with `chezmoi execute-template` before applying
4. **Preview changes** with `chezmoi diff` before applying
5. **Apply incrementally** with `chezmoi apply -v` to see what changes

### Adding New Packages
Add to `Brewfile.tmpl`:
- Common packages in the top section
- Machine-specific in the conditional blocks
- Use `brew` for CLI tools, `cask` for GUI apps

The `run_onchange_brew-bundle.sh.tmpl` will automatically detect changes and install new packages.

### Adding New Dotfiles
```bash
# Add an existing file to chezmoi
chezmoi add ~/.newfile

# Add and make it a template
chezmoi add --template ~/.newfile
```

### Run Scripts Execution Order
Scripts run based on their prefix:
- `run_once_10-*` → 10
- `run_20-*` → 20
- `run_30-*` → 30
- `run_once_after_*` → runs after all other scripts

Number your scripts to control execution order.

## Script Output Standard

All run scripts follow this standard:

### Silent on Success
No output when everything works as expected.

### Skip (Graceful Exit)
When a prerequisite isn't met but it's not an error:
```bash
⏭️  Brief reason - skipping <script-name>
exit 0
```

### Error (Requires Action)
When user intervention is required:
```bash
❌ Brief error description

Action needed:
  command-to-run

exit 1
```

### Examples
```bash
# Skip gracefully
if ! command -v tool &> /dev/null; then
  echo "⏭️  Tool not found - skipping setup"
  exit 0
fi

# Error with action
if grep -q "No accounts configured"; then
  echo "❌ No 1Password accounts configured"
  echo ""
  echo "Action needed:"
  echo "  op account add --address YOUR.1password.com --email YOUR_EMAIL"
  echo ""
  exit 1
fi

# Success - silent
exit 0
```

## Template-Level Conditionals (Best Practice)

**IMPORTANT:** Move conditional checks to template-level whenever possible to avoid unnecessary script execution and prevent premature evaluation of expensive operations (like `onepasswordRead`).

### Why Use Template-Level Conditionals

1. **Prevents unnecessary script execution** - Scripts don't run at all if conditions aren't met
2. **Avoids premature evaluation** - Template functions like `onepasswordRead` are only evaluated when needed
3. **Cleaner output** - No script execution means no potential for error messages
4. **More efficient** - Skips script execution overhead entirely

### Pattern

Use chezmoi's `lookPath` and `output` functions to check conditions during template rendering:

```bash
#!/usr/bin/env bash

{{- $toolExists := lookPath "tool" }}
{{- if not $toolExists }}
# Tool not found - skip setup
exit 0
{{- else }}

# Your script logic here
# This only gets rendered if the tool exists
{{- end }}
```

### Checking Command Output

For more complex checks, use the `output` function:

```bash
#!/usr/bin/env bash

{{- $toolExists := lookPath "tool" }}
{{- if not $toolExists }}
# Tool not found - skip setup
exit 0
{{- else }}
{{- $status := output "tool" "status" | default "" }}
{{- if contains "already configured" $status }}
# Already configured - skip setup
exit 0
{{- else }}

# Your setup logic here
# This only gets rendered if tool exists AND isn't configured yet
{{- end }}
{{- end }}
```

### When to Use Template-Level Conditionals

- **Command availability checks** - Use `lookPath` instead of runtime `command -v`
- **State checks that prevent expensive operations** - Especially when using `onepasswordRead` or other secret management
- **OS checks** - Already done via `{{ if eq .chezmoi.os "darwin" }}`
- **Configuration checks** - Use `output` to check if setup is already complete

### When to Use Runtime Conditionals

- **Checks requiring complex logic** - When template functions aren't sufficient
- **Error conditions requiring user action** - When you need to provide actionable error messages
- **Dynamic checks** - When the condition depends on runtime state that can't be determined during template rendering
