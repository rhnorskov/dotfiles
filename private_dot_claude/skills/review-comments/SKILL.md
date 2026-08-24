---
name: review-comments
description: Fetch unresolved review comments on the current branch PR and walk through them one at a time, proposing fixes.
disable-model-invocation: true
---

Fetch unresolved review comments on the current branch's PR and walk through them, proposing fixes for each.

## 1. Locate the PR

1. Run `gh pr view --json number,headRefName,url,baseRefName` to identify the PR for the current branch.
2. If there is no PR, abort and tell the user there's nothing to review.

## 2. Fetch unresolved review threads

Use the GraphQL API so resolved threads can be filtered out (REST does not expose `isResolved`):

```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          comments(first:50) {
            nodes {
              author { login }
              body
              path
              line
              originalLine
              diffHunk
              url
              createdAt
            }
          }
        }
      }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F number=<number>
```

Filter to threads where `isResolved == false`. Drop bot authors unless they are the only author on the thread (e.g. CodeRabbit) — surface those too since they often contain real findings.

## 3. Present the queue

Show a short summary first: how many unresolved threads, grouped by file. Do NOT dump every comment body up front — just the count and file list.

## 4. Walk through one comment at a time

For each unresolved thread, in order:

1. Show: file:line, author, the comment body (and any replies in the thread), and the relevant diff hunk for context.
2. Read the actual file at that location to verify the code is still there and the line still applies (threads can be outdated).
3. Propose a concrete fix or response. If the comment is a question, draft a reply; if it's actionable, draft the code change.
4. Use `AskUserQuestion` to ask how to proceed for this thread:
   - **Apply fix** — make the code change.
   - **Reply only** — post a reply explaining (use `gh api` to post to the thread).
   - **Skip** — leave it for the user.
   - **Resolve** — mark the thread resolved without changes (only if user confirms it's already addressed).
5. After acting, move to the next thread.

Do not batch fixes across multiple threads in one go — handle them one at a time so the user can steer.

## 5. Replies and resolution

To post a reply on a review thread:

```bash
gh api -X POST repos/<owner>/<repo>/pulls/<number>/comments/<comment_id>/replies -f body='...'
```

To resolve a thread (GraphQL):

```bash
gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread { isResolved } } }' -F id=<thread_id>
```

The thread `id` comes from the GraphQL query in step 2 — re-fetch with `id` selected on `reviewThreads.nodes` if needed.

## 6. Wrap-up

When all threads are processed:

1. Show a summary: how many fixed, replied, skipped, resolved.
2. If code changed, remind the user to commit + push (do not auto-commit unless they ask).
3. Do not push or mark the PR ready — leave that to the user.

## Notes

- This command does not pull general PR conversation (issue comments) or CI failures — it's scoped to inline review threads.
- If the current branch has multiple PRs (rare), use the most recently updated one and tell the user.
