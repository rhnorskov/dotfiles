Create a new feature branch following conventional commit conventions.

First, analyze the staged files:

1. Run `git diff --cached --name-only` to see staged files
2. Run `git diff --cached --stat` to understand the scope of changes
3. Based on the files and changes, suggest:
   - An appropriate type (feat, fix, docs, style, refactor, test, chore, etc.)
   - A brief description in kebab-case

Then ask the user for:

1. The type (provide your suggested type as the default/recommendation)
2. A brief description (provide your suggested description as the default/recommendation)

Finally, create and checkout the branch with format: `{type}/{description}`

Examples: `feat/add-user-authentication` or `fix/resolve-login-bug`
