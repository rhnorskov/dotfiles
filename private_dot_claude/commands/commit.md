Create a git commit with a one-liner message, following conventional commit conventions.

First, analyze the staged files:

1. Run `git diff --cached --name-only` to see staged files
2. Run `git diff --cached --stat` to understand the scope of changes
3. Based on the files and changes, suggest:
   - An appropriate type (feat, fix, docs, style, refactor, test, chore, etc.)
   - A concise one-liner commit message

Then ask the user for:

1. The type (provide your suggested type as the default/recommendation)
2. A brief commit message (provide your suggestion as the default/recommendation)

Finally:

1. Create the commit with the provided message
2. Show the commit status

Keep the message concise and descriptive.
