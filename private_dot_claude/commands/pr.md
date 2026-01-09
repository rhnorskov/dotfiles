Create a pull request using the gh CLI, following conventional commit conventions.

First, analyze the current branch and changes:

1. Run `git branch --show-current` to get the current branch name
2. Run `git log main..HEAD --oneline` to see all commits on this branch
3. Run `git diff main...HEAD --stat` to understand the scope of changes
4. Read the PR template at `.github/pull_request_template.md`

Based on the analysis, prepare the PR:

1. Suggest a PR title following conventional commit format (e.g., "feat: add user authentication")
2. Fill in the PR template:
   - Write a brief description of what the PR accomplishes
   - Check the appropriate "Type of Change" based on the branch prefix/commits
   - Check appropriate "Testing" boxes based on changes (e.g., if test files changed)
   - Check "No database changes" unless migration files are present
   - Check "No breaking changes" unless obvious breaking changes exist
   - Check "No special steps required" unless deployment notes are needed
   - Leave ClickUp task unchecked for user to fill in

Then ask the user for:

1. The PR title (provide your suggested title as the default/recommendation)
2. Whether to mark as draft (default: no)
3. Any modifications to the pre-filled template body

Finally:

1. Push the current branch to origin if not already pushed: `git push -u origin HEAD`
2. Create the PR using: `gh pr create --title "..." --body "..." [--draft]`
3. Show the PR URL

Keep the title concise and the body properly formatted with the template structure.
