---
name: vgv-flutter-upgrade
description: Upgrades Flutter and Dart SDK versions across all pubspec.yaml files and GitHub workflows. Formats code, runs linting, applies fixes, and checks release notes for breaking changes. Use when upgrading Flutter versions or when the user asks to upgrade Flutter/Dart.
metadata:
  author: very-good-ventures
  version: "1.0"
---

# Flutter Version Upgrade

This skill is **tool-agnostic**: different AI coding environments (Cursor, Claude Code, Gemini CLI, etc.) expose different tools (e.g. file search, run command, MCP, HTTP fetch). Follow the workflow using whatever capabilities your environment provides; the intent of each step is described below.

## Overview

This skill automates upgrading Flutter and Dart SDK versions across a project. It updates all pubspec.yaml files, GitHub Actions workflows, runs formatting/linting/fixes, and checks release notes for breaking changes.

## Workflow

### Step 1: Detect Current Version

1. **Get Flutter version:**
   - If your environment has a Dart MCP server, use its tools to get the Flutter version when available.
   - Otherwise run `flutter --version` (using your environment’s command execution) to get the installed Flutter version.
2. Find all pubspec.yaml files (e.g. search for `**/pubspec.yaml` using your environment’s file search or glob).
3. Check for a `.fvmrc` file in the project root (e.g. search for `.fvmrc` or list the root directory).
4. Read each pubspec.yaml and extract current version constraints:
   - Look for `environment.flutter:` constraint (e.g., `^3.38.0`)
   - Look for `environment.sdk:` constraint (e.g., `^3.10.0`)
5. If `.fvmrc` exists, read it and extract the `flutter` field (e.g., `"flutter": "3.19.0"`).
6. Report the current versions found across all files.

### Step 2: Get Target Version

- If the user provided a target version, use it.
- Otherwise, prompt the user: "What Flutter version do you want to upgrade to?" (using your environment’s way to ask the user).
- Validate version format (should be semver: X.Y.Z or X.Y.Z-pre.N).

### Step 3: Determine Dart SDK Version

Fetch the Dart SDK version that corresponds to the target Flutter version from https://docs.flutter.dev/install/archive (using your environment’s HTTP fetch or web capability).

### Step 4: Update pubspec.yaml Files

For each pubspec.yaml file found:

1. **Update Flutter constraint:**
   - Find the `environment:` section
   - Locate `flutter:` field
   - Preserve the constraint operator (^, >=, etc.) if present
   - Update to target version: `flutter: ^{targetVersion}` (or preserve existing operator)
   - Example: `flutter: ^3.38.0` → `flutter: ^3.41.0`

2. **Update Dart SDK constraint:**
   - Locate `sdk:` field under `environment:`
   - Update to the Dart SDK version determined in Step 3
   - Preserve constraint operator: `sdk: ^{dartVersion}`
   - Example: `sdk: ^3.10.0` → `sdk: ^3.11.0`

3. Update each file (using your environment’s text edit or search-and-replace), ensuring exact string matching.

### Step 4b: Update .fvmrc File (if present)

If a `.fvmrc` file exists in the project root:

1. Read the file to get its current contents.
2. Parse the JSON structure.
3. Update the `flutter` field to the target version:
   - Find `"flutter": "{oldVersion}"` and replace with `"flutter": "{targetVersion}"`
   - Example: `"flutter": "3.19.0"` → `"flutter": "3.41.0"`
   - Preserve all other fields and formatting.
4. Write the updated content back (using your environment’s edit or search-and-replace), ensuring exact JSON string matching.
5. If the file doesn’t have a `flutter` field, add it: `"flutter": "{targetVersion}"`.

### Step 5: Update GitHub Workflows

1. Find all workflow files (e.g. search for `.github/workflows/*.yaml` or list that directory).
2. For each workflow file:
   - Check whether it contains `flutter-version:`.
   - If found, update the line so that `flutter-version: {oldVersion}` becomes `flutter-version: {targetVersion}` (e.g. `flutter-version: 3.38.2` → `flutter-version: 3.41.0`), using your environment’s edit or search-and-replace.
3. If `.github/workflows_config.json` exists:
   - Read the file, find the `flutterVersion` field, and update `"flutterVersion": "{oldVersion}"` to `"flutterVersion": "{targetVersion}"`.

### Step 6: Run pub get

Before formatting and linting, ensure dependencies are up to date:

1. If your environment has a Dart MCP server and it can run pub get, prefer that for each package root.
2. Otherwise, run these commands (using your environment’s command execution) in each directory that contains a pubspec.yaml:
   - Flutter packages: `flutter pub get`
   - Dart-only packages: `dart pub get`
   Start from the project root and process all packages.

### Step 7: Format and Lint

Run these in order for **every package** (each directory that has a pubspec.yaml). Prefer Dart MCP format/analyze/fix tools when available; otherwise run the following commands in each package directory:

1. **Format code:** `dart format .`
2. **Analyze:** For Flutter packages use `flutter analyze`; for Dart-only use `dart analyze --fatal-infos --fatal-warnings lib test`.
3. **Apply automatic fixes:** `dart fix --apply`

If your environment has a Dart MCP server, use its format, analyze, and fix tools (e.g. `dart_format`, `analyze_files`, `dart_fix`) for each package root, passing the root as a file URI if required. Otherwise run the commands above from each package directory.

**Error handling:** If any step fails, report the errors and document what needs manual intervention. Do not abort the whole upgrade; continue and summarize issues at the end.

### Step 8: Fetch and Review Release Notes

1. **Fetch release notes:** Retrieve the page at `https://docs.flutter.dev/release/release-notes/release-notes-{targetVersion}` (replace `{targetVersion}` with the target Flutter version, e.g. `3.41.0`). Use your environment’s HTTP fetch or web capability. If that URL fails, try variations like `3.41` or the current Flutter docs structure.

2. **Parse breaking changes:** In the release notes, look for sections titled "Breaking changes", "Deprecations", or "Migration guide". Extract specific API changes, removed features, or behavior changes.

3. **Search the codebase for affected code:** For each breaking change, search the project for usages of deprecated or removed APIs (using your environment’s search). Note files and patterns that need updating.

4. **Apply automatic fixes:** Where the release notes describe straightforward replacements (e.g. deprecated method replacements), update the code accordingly using your environment’s edit or search-and-replace. Only change what is explicitly documented.

5. **Document manual steps:** List any breaking changes that need human review, with file locations and code patterns. Include links to migration guides when available.

### Step 9: Summary Report

Provide a comprehensive summary:

1. **Files updated:**
   - List all pubspec.yaml files that were modified
   - List `.fvmrc` file if updated
   - List all GitHub workflow files that were updated
   - List workflows_config.json if updated

2. **Version changes:**
   - Old Flutter version → New Flutter version
   - Old Dart SDK version → New Dart SDK version

3. **Issues found:**
   - Any formatting/analysis errors
   - Any breaking changes that need manual attention
   - Any files that couldn't be updated (with reasons)

4. **Next steps:**
   - Review and test the application
   - Address any manual migration steps documented
   - Note: `pub get` has already been run in Step 6

## Important Notes

- **Preserve constraint operators:** When updating versions, maintain existing operators (^, >=, etc.) unless the user specifies otherwise
- **Handle missing fields:** If a pubspec.yaml doesn't have `environment:` section, add it. If it has `environment:` but missing `flutter:` or `sdk:`, add the missing field
- **Version format:** Always use caret constraints (^) for Flutter and SDK versions unless the file already uses a different operator
- **GitHub workflows:** Some workflows may use exact versions (3.38.2) while pubspec.yaml uses constraints (^3.38.0). Update both appropriately
- **FVM .fvmrc files:** The `.fvmrc` file uses exact version strings (e.g., `"flutter": "3.19.0"`), not constraints. Update the `flutter` field to the exact target version. Preserve all other JSON fields and formatting.
- **Dart MCP:** If your environment has a Dart MCP server, prefer its tools for Flutter version detection, pub get, format, analyze, and fix. Otherwise use the CLI commands described in each step.
- **Release notes:** If release notes are unavailable for the target version, continue with the upgrade but note that manual review of breaking changes is recommended

## Example Usage

When a user says:

- "Upgrade Flutter to 3.41.0"
- "Update Flutter version"
- "Upgrade to the latest Flutter version"

Follow the complete workflow above, starting with version detection and proceeding through all steps.
