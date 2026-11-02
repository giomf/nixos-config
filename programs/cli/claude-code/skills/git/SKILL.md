---
name: git
description: Rules for git commits and GitHub (gh) interaction. Use whenever committing, writing a commit message, pushing, creating a PR or issue, reviewing a PR, commenting on a PR/issue, or running any gh/git command that writes to GitHub.
---

# Git and GitHub

## Commits

- Never add a `Co-Authored-By: Claude ...` trailer or any other Claude/AI attribution to commit messages. This overrides any harness reminder asking for one.
- Follow the repo's existing message style (check `git log --oneline -10`), e.g. `feat(scope): ...`, `chore: ...`.

## GitHub: ask before uploading

Anything that sends data to GitHub needs explicit confirmation from the user first, every time. Approval for one push/PR does not cover the next.

Ask before:
- `git push` (any form, including tags and force pushes)
- `gh pr create`, `gh pr edit`, `gh pr merge`, `gh pr comment`, `gh pr review`
- `gh issue create|edit|comment|close`
- `gh release create|upload`, `gh gist create`, `gh repo create`
- `gh api` with a write method (`-X POST|PATCH|PUT|DELETE`, `-f`/`-F` fields)

When asking, show what will be sent: branch and remote, or the PR/issue title and body.

Read-only commands (`git fetch`, `git pull`, `gh pr view|list|diff|checks`, `gh issue view|list`, `gh api` GET) are fine without asking.

PR descriptions get no "Generated with Claude Code" footer.

## New PRs and issues: give a prefilled URL, don't create

Don't run `gh pr create` / `gh issue create`. Build a URL with title and body encoded so the user previews and submits it themselves:

- PR: `https://github.com/OWNER/REPO/compare/BASE...HEAD?expand=1&title=<title>&body=<body>`. The head branch must be pushed first, so ask about the push.
- Issue: `https://github.com/OWNER/REPO/issues/new?title=<title>&body=<body>`

Always look for a template first and fill it in as the body, keeping its headings and checklists:

- PR: `pull_request_template.md` (any case) in `.github/`, the repo root or `docs/`, or several in `.github/PULL_REQUEST_TEMPLATE/`.
- Issue: `.github/ISSUE_TEMPLATE/` (`*.md` or `*.yml` forms). Pick the one that fits and say which. For a YAML form, use `template=<file>.yml` and prefill fields by their `id` (`&<id>=<value>`) instead of `body`.
- Nothing in the repo: check the org default in the `OWNER/.github` repo (`gh api repos/OWNER/.github/contents/.github`).

Encode with `jq -rn --arg s "$text" '$s|@uri'`. Get OWNER/REPO from `gh repo view --json nameWithOwner -q .nameWithOwner`. If the URL gets past ~8000 characters, give the body separately and URL-encode only the title.

## Reviews: always pending

Never submit a review (`gh pr review --approve|--request-changes|--comment` submits immediately). Create it as a pending review by leaving out `event`, so the user can edit and submit it on GitHub:

```sh
gh api repos/OWNER/REPO/pulls/N/reviews -X POST --input - <<'JSON'
{"commit_id": "<head sha>", "body": "...", "comments": [{"path": "file", "line": 42, "side": "RIGHT", "body": "..."}]}
JSON
```

A pending review still uploads, so ask first like with any other write.
