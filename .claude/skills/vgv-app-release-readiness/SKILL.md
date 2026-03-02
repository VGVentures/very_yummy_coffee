---
name: vgv-app-release-readiness
description: Audits a Flutter app for release readiness across all detected platforms (Android, iOS, web, macOS, Linux, Windows). Launches platform-specific audits in parallel, then synthesizes a unified actionable release todo list. Use when the user wants to prepare their Flutter app for release or store submission.
argument-hint: "[path-to-flutter-project]"
metadata:
  author: very-good-ventures
  version: "1.0"
---

# Flutter App Release Readiness

You are the orchestrator for VGV's Flutter app release readiness pipeline. You detect which platforms a Flutter project supports, audit each one in parallel, and synthesize a single actionable release todo list that a developer or agent can work through.

## Setup

1. **Determine project path:**
   - If `$ARGUMENTS` contains a path, use it as the project root.
   - Otherwise use the current working directory.

2. **Confirm this is a Flutter project** — find `pubspec.yaml` at the project root. Read it to extract the `name:` and `version:` fields. If no `pubspec.yaml` exists, stop and tell the user this does not appear to be a Flutter project.

3. **Create output directory:** `app-release-readiness-report/` at the project root.

Store these values for use in all phases:

- `PROJECT_ROOT`: the Flutter project root directory
- `APP_NAME`: the `name:` field from pubspec.yaml
- `APP_VERSION`: the `version:` field from pubspec.yaml
- `OUTPUT_DIR`: `app-release-readiness-report/`

## Phase 1 — Detect Platforms

Check for the existence of these platform directories at the project root:

| Platform | Directory  |
| -------- | ---------- |
| Android  | `android/` |
| iOS      | `ios/`     |
| Web      | `web/`     |
| macOS    | `macos/`   |
| Linux    | `linux/`   |
| Windows  | `windows/` |

Build a list of detected platforms. If none are found, stop and tell the user no platform directories were found — they should run `flutter create --platforms=<platform> .` to add support.

Tell the user which platforms were detected before proceeding to Phase 2.

## Phase 2 — Parallel Platform Audits

Launch one audit agent per detected platform **concurrently** using the Task tool. Only launch agents for platforms that were actually detected.

**Locate the agent definitions** by searching for them in the following order:

1. `.claude/agents/app-readiness/` (Claude Code installation)
2. `.cursor/agents/app-readiness/` (Cursor installation)
3. `.gemini/agents/app-readiness/` (Gemini CLI installation)
4. `.codex/agents/app-readiness/` (OpenAI Codex installation)

Use the first directory that exists and contains the agent files.

| Platform | Agent Filename                       | Output Report                               |
| -------- | ------------------------------------ | ------------------------------------------- |
| Android  | `android-release-readiness-agent.md` | `{OUTPUT_DIR}/android-release-readiness.md` |
| iOS      | `ios-release-readiness-agent.md`     | `{OUTPUT_DIR}/ios-release-readiness.md`     |
| Web      | `web-release-readiness-agent.md`     | `{OUTPUT_DIR}/web-release-readiness.md`     |
| macOS    | `macos-release-readiness-agent.md`   | `{OUTPUT_DIR}/macos-release-readiness.md`   |
| Linux    | `linux-release-readiness-agent.md`   | `{OUTPUT_DIR}/linux-release-readiness.md`   |
| Windows  | `windows-release-readiness-agent.md` | `{OUTPUT_DIR}/windows-release-readiness.md` |

Prompt for each agent: "Audit the Flutter project at `{PROJECT_ROOT}`. Write your platform readiness report to `{OUTPUT_DIR}/<platform>-release-readiness.md`."

**Wait for all platform agents to complete before proceeding.**

## Phase 3 — Synthesize Release Todo List

After all platform agents finish, read every report written to `{OUTPUT_DIR}/`. Synthesize a master `{OUTPUT_DIR}/RELEASE_TODO.md` following these rules.

### Consolidation Rules

1. **Identify cross-platform items** — any action required (❌ or ⚠️) that appears across multiple platforms should be listed once with a note of which platforms are affected. Do not repeat the same fix multiple times.

2. **App icons** — if any platform has an app icon action required:
   - Consolidate ALL platform icon tasks into a single cross-platform item.
   - Recommend using [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) to generate icons for all platforms at once.
   - Include the setup snippet below.

3. **Version number** — if `pubspec.yaml` version is still at the Flutter default `1.0.0+1`, list this once as a cross-platform item.

4. **Platform-specific items** — items that only affect one platform go under that platform's own section.

5. **Priority ordering within each section:**
   - ❌ Blockers first (required for store/deployment submission)
   - ⚠️ Warnings second (recommended but not hard blockers)
   - Cross-platform items before platform-specific items

### `flutter_launcher_icons` Snippet

Whenever app icons need to be set up on any platform, include this as the action:

````
1. Add to `pubspec.yaml` under `dev_dependencies`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.14.2
````

2. Add launcher icon configuration to `pubspec.yaml`:

   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/icon.png" # 1024×1024 PNG with no transparency
     web:
       generate: true
       image_path: "assets/icon/icon.png"
     macos:
       generate: true
       image_path: "assets/icon/icon.png"
     windows:
       generate: true
       image_path: "assets/icon/icon.png"
     linux:
       generate: true
       image_path: "assets/icon/icon.png"
   ```

   Remove any platform blocks for platforms your app does not support.

3. Place your icon at `assets/icon/icon.png` (1024×1024 PNG, no rounded corners — each platform applies its own mask).

4. Run: `flutter pub run flutter_launcher_icons`

Reference: https://pub.dev/packages/flutter_launcher_icons

````

### Output: `{OUTPUT_DIR}/RELEASE_TODO.md`

Write the consolidated todo list using this exact structure. Use `- [ ]` checkboxes throughout so the file can be tracked as a checklist by a human or agent.

```markdown
# Flutter App Release Todo List

**App:** {APP_NAME}
**Version:** {APP_VERSION}
**Date:** {today's date}
**Platforms audited:** {comma-separated list of platforms}

---

## Status Summary

| Platform | Overall | Blockers | Warnings |
|----------|---------|----------|---------|
| Android  | READY / NOT READY | X | X |
| iOS      | READY / NOT READY | X | X |
| Web      | READY / NOT READY | X | X |
| macOS    | READY / NOT READY | X | X |
| Linux    | READY / NOT READY | X | X |
| Windows  | READY / NOT READY | X | X |

---

## Critical Blockers

> These must be resolved before submitting to any store or deploying.

### Cross-Platform

- [ ] **App Icons** *(Affects: Android, iOS, macOS, …)*

  Default Flutter placeholder icons will be rejected by app stores.

  <flutter_launcher_icons setup steps here>

- [ ] **<Other cross-platform blocker>** *(Affects: Android, iOS)*

  <Why this matters and what to do — one concise action>

### Android

- [ ] **<Android-only blocker>**

  <What to do. Reference: https://docs.flutter.dev/deployment/android#…>

### iOS

- [ ] **<iOS-only blocker>**

  <What to do. Reference: https://docs.flutter.dev/deployment/ios#…>

### Web

- [ ] **<Web-only blocker>**

  <What to do.>

<!-- Add sections only for platforms that have items -->

---

## Warnings

> Strongly recommended before release but not hard blockers.

### Cross-Platform

- [ ] **<Cross-platform warning>** *(Affects: Android, iOS)*

  <Recommendation>

### Android

- [ ] **<Android-only warning>**

  <Recommendation>

<!-- Add platform sections only when they have items -->

---

## Platform Reports

Individual platform readiness reports are in `{OUTPUT_DIR}/`:

- [Android report](android-release-readiness.md)
- [iOS report](ios-release-readiness.md)
- [Web report](web-release-readiness.md)
- [macOS report](macos-release-readiness.md)
- [Linux report](linux-release-readiness.md)
- [Windows report](windows-release-readiness.md)
````

Only include platform report links for platforms that were actually audited.

## Completion

After writing `{OUTPUT_DIR}/RELEASE_TODO.md`, present a summary to the user:

```
Flutter app release readiness audit complete!

Platforms audited: {comma-separated list}

Status:
  Android: READY / NOT READY (X blockers, X warnings)
  iOS:     READY / NOT READY (X blockers, X warnings)
  Web:     READY / NOT READY (X blockers, X warnings)
  ...

Total across all platforms: {X} blockers, {X} warnings

Your release todo list is at: app-release-readiness-report/RELEASE_TODO.md
Individual platform reports are in: app-release-readiness-report/
```

## Rules

- **Never modify any project file.** Only write to `app-release-readiness-report/`.
- Launch platform agents concurrently — do not run them sequentially.
- Only include sections in `RELEASE_TODO.md` that have at least one item.
- If a platform agent fails or its report is missing, note that platform as "audit failed" in the summary and continue synthesizing from available reports.
- When any platform has an app icon issue, always consolidate into the `flutter_launcher_icons` recommendation — do not list icon fixes per-platform separately.
- Keep every todo item actionable: tell the developer exactly what to do, not just what is wrong.
- Use `- [ ]` checkboxes for every todo item so the list can be tracked as work is completed.
