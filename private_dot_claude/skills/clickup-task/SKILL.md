---
name: clickup-task
description: Create a git worktree for a ClickUp task and plan the work (no implementation). Takes a ClickUp task URL or ID.
disable-model-invocation: true
argument-hint: <clickup-task-url-or-id> [extra instructions]
---

Set up an isolated worktree for the ClickUp task in `$ARGUMENTS` and plan the work.

## 1. Read the task

The task ID is the last path segment of the URL (`https://app.clickup.com/t/<team>/<task-id>` or `.../t/<task-id>`). Anything after the URL in the arguments is extra instructions from the user; follow it.

Fetch with `clickup_get_task` (load via ToolSearch if deferred), plus `clickup_get_task_comments` for clarifications and decisions. Read the description, checklists, subtasks, linked docs and attachments that matter. If the task is ambiguous or under-specified, ask via AskUserQuestion before building anything.

## 2. Create the worktree

1. `git fetch origin` and find the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`).
2. Branch name: `{type}/{task-id}-{kebab-description}`, type from the conventional commit set (feat, fix, refactor, chore, ...), description at most ~5 words from the task title. Example: `fix/86cbbyhd9-login-redirect-loop`.
3. Run `git wt <branch> origin/<default-branch>` from the repo root. Worktrees land in `wt.basedir` (`../{gitroot}.worktrees`). If the branch or worktree already exists, reuse it and say so.
4. Switch the session into it with EnterWorktree (load via ToolSearch) using the worktree path. If that is unavailable, use absolute worktree paths for every command and edit.

Never create the worktree from a dirty or feature-branch HEAD; always start from `origin/<default-branch>`.

## 3. Plan

Do not implement. Explore the codebase in the worktree, then enter plan mode (EnterPlanMode) and present a plan: your understanding of the task, the files and areas affected, the approach, open questions, and how it will be verified. Follow the repo's own CLAUDE.md and conventions. Wait for approval before writing any code.

## 4. Wrap up

Report the worktree path and branch name alongside the plan. Do not commit, push or open a PR unless asked. When linking the task, use a markdown link with the task name as anchor text.
