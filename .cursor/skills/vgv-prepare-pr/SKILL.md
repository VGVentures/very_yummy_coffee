---
name: vgv-prepare-pr
description: Prepares code changes for a Pull Request by formatting Dart code, running linters, creating git branches, committing with conventional commits, and opening PRs via GitHub CLI. Use when the user asks to prepare changes for a PR, create a pull request, or push changes.
metadata:
  author: very-good-ventures
  version: "1.0"
---

# Prepare Pull Request

This skill is **tool-agnostic**: different AI coding environments (Cursor, Claude Code, Gemini CLI, etc.) expose different tools (e.g. file search, run command, MCP). Follow the workflow using whatever capabilities your environment provides; the intent of each step is described below.

## Format and analyze: MCP vs CLI

- **Dart MCP** (when available) is the preferred way to format and lint. It usually exposes tools such as `dart_format`, `analyze_files`, and `dart_fix`. If your environment supports MCP, invoke these tools for the Dart MCP server, passing each package root. Where the tool expects a root path, use a file URI (e.g. `file:///absolute/path/to/package`).
- **Very Good CLI MCP** does not provide format/analyze; it offers test running and package getting only. Do not use it for format or analyze steps.
- **CLI fallback:** If Dart MCP is not available, run the shell commands given in each step from the project (or package) directory using your environment’s command execution capability.

## Workflow

When preparing changes for a Pull Request:

1. **Find all Dart/Flutter packages**
   - Discover every directory that contains a `pubspec.yaml` (e.g. search for `**/pubspec.yaml` using your environment’s file search or glob).
   - Include the project root if it has a `pubspec.yaml`. You will format and analyze each of these package roots (including subpackages).

2. **Format Dart code** (for every package found)
   - **If Dart MCP is available:** Use its format tool (e.g. `dart_format`) for each package root, passing the root (as a file URI if the tool requires it). You may be able to pass multiple roots in one call.
   - **Otherwise:** In each package directory, run: `dart format .`

3. **Run the linter and collect errors** (for every package)
   - **If Dart MCP is available:** Use its analyze tool (e.g. `analyze_files`) for each package root, passing the root (as a file URI if required). You may be able to pass multiple roots in one call.
   - **Otherwise:** In each package directory run:
     - Flutter packages (pubspec contains `flutter:`): `flutter analyze`
     - Dart-only packages: `dart analyze`
   - Report all errors from all packages before continuing.

4. **Apply automatic fixes** (optional, only if there were errors)
   - **If Dart MCP is available:** Use its fix tool (e.g. `dart_fix`) for each package root as above.
   - **Otherwise:** In each package directory run: `dart fix --apply`
   - Then repeat format and analyze (steps 2 and 3).

5. **If there are no errors,** run the git workflow (using your environment’s ability to run commands):
   - Inspect changes (e.g. `git diff`, `git status`)
   - Create a branch: `git checkout -b <branch-name>`
   - Commit with a conventional commit message
   - Push: `git push -u origin <branch-name>`
   - Open a PR using GitHub CLI (see “Creating the PR” below)

6. **If there are errors:**
   - Fix them (by hand or using the Dart MCP fix tool if available), then repeat format and analyze (steps 2 and 3).
   - Proceed to git and PR only when all packages pass format and analyze.

## Conventional Commit Messages

Use conventional commit format:

- `feat: add new feature`
- `fix: fix a bug`
- `chore: update dependencies`
- `docs: update documentation`
- `refactor: refactor code`
- `test: add tests`
- `style: update styles`
- `perf: improve performance`

## Creating the PR

Create the PR by running GitHub CLI (e.g. `gh pr create`) from the project directory:

1. If the repo has `.github/pull_request_template.md`, use it:  
   `gh pr create --title "<title>" --body-file .github/pull_request_template.md`
2. Otherwise:  
   `gh pr create --title "<title>" --body "<description>"`

## Error Handling

If format or analyze reports errors: fix them, re-run format and analyze for all packages, and only run the git workflow and create the PR when everything passes.
