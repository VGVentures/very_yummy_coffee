---
name: fix-failing-github-actions
description: Finds failing GitHub Actions for the current branch/PR, fixes them, commits and pushes, then re-checks after a short wait. Repeats until all checks pass. Use when the user asks to fix failing CI, fix status checks, fix GitHub Actions, or get the branch green.
metadata:
  version: "1.0"
---

# Fix Failing GitHub Actions

Run this workflow when the user wants failing GitHub Actions (status checks) on the current branch to be fixed and to keep iterating until they pass.

## Prerequisites

- Current branch has a PR open, or push target is known (e.g. `origin/<branch>`).
- GitHub CLI (`gh`) installed and authenticated (needed for run list/view and push).
- Repository owner and name known (from `git remote get-url origin` or PR context).

## Workflow (loop until all checks pass)

### 1. Resolve PR and repo context

- Get current branch: `git branch --show-current`.
- Get PR for this branch: `gh pr view` (no args in repo) or GitHub MCP `pull_request_read` with method `get` after resolving PR number (e.g. via `gh pr list --head <branch>`).
- Derive `owner` and `repo` from `git remote get-url origin` (e.g. `github.com:owner/repo.git` or `github.com/owner/repo`).

### 2. Look up failing actions

- **Check status (GitHub MCP):** Call `pull_request_read` with `method: "get_status"`, plus `owner`, `repo`, and `pullNumber`. Use this to see overall state of checks (success / failure / pending).
- **Which jobs failed and why (gh CLI):**  
  `gh run list --branch <branch> --limit 10`  
  Then for any run with status `failure`:  
  `gh run view <run_id>`  
  Use the run view output (job names, annotations, failed step names) to decide what to fix. For detailed logs:  
  `gh run view <run_id> --log-failed`

If there is no PR yet, use `gh run list --branch <branch>` and `gh run view <run_id>` only.

### 3. Fix the failures

Apply fixes based on the failing job/step and annotations, for example:

- **Spell Check** (e.g. cspell): Add unknown words to `cspell.json` (or project spell config). Fix any real typos in the reported files.
- **Format / Analyze:** Run project formatter and analyzer (e.g. `dart format`, `flutter analyze`) and fix issues.
- **Lint (e.g. bloc lint):** Address reported lint violations.
- **Build / test failures:** Fix compilation or test errors from the logs.
- **Semantic PR / other:** Adjust PR title or body to match required rules (e.g. conventional commit in title).

Prefer fixing root cause; only add words to the spell dictionary when the term is intentional (e.g. LTRB, mcps, product names).

### 4. Commit and push

- Stage only the changes that fix CI: `git add <paths>` (or `git add -p` if selective).
- Commit with a conventional message, e.g. `fix(ci): add allowed words to cspell` or `fix(ci): resolve format/analyze issues`.
- Push: `git push origin <branch>`.

### 5. Wait and re-check

- Wait 1 minute: `sleep 60` (or equivalent).
- **Re-check status:**  
  - GitHub MCP: `pull_request_read` with `method: "get_status"` again.  
  - Or: `gh run list --branch <branch> --limit 5` and inspect latest runs.

### 6. Decide and loop

- **All checks passed:** Exit successfully.
- **Any check still failed:** Go back to step 2 (look up failing actions), then 3 (fix), 4 (commit and push), 5 (wait), 6 (decide). Use the latest run IDs and annotations.
- **Checks still running (pending):** Wait another minute and re-check (repeat step 5 then 6). Optionally cap total wait (e.g. 10–15 minutes) and then re-evaluate.

Continue looping until all status checks pass.

## Conventions

- Use conventional commit messages for fix commits (e.g. `fix(ci): ...`, `style: ...`).
- Prefer small, focused commits that clearly address one kind of failure (spell check vs format vs tests).
- When calling GitHub MCP `pull_request_read`, always pass `method`, `owner`, `repo`, and `pullNumber`; get PR number from `gh pr list --head <branch> --json number -q '.[0].number'` if needed.

## Summary

1. Resolve branch, PR number, owner, repo.  
2. Get check status (MCP `pull_request_read` get_status) and failure details (`gh run list`, `gh run view`).  
3. Fix failures.  
4. Commit and push.  
5. Wait 1 minute, then re-check status.  
6. If passed → exit. If failed → loop from step 2. If pending → wait 1 min and re-check.
