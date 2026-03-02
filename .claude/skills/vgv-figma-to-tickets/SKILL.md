---
name: vgv-figma-to-tickets
description: Break down a Figma design file into actionable GitHub issues or Jira tickets for team distribution.
---

# Break a Figma design into tickets

Read a Figma design file, identify screens and components, and create tickets that your team can pick up — each linked back to the original designs. Supports both **GitHub Issues** and **Jira**.

## Input

<figma_url> #$ARGUMENTS </figma_url>

**If the Figma URL above is empty, ask the user:** "Please share the Figma file URL in Dev Mode you'd like to break into tickets. It looks like: `https://www.figma.com/design/<file_key>/<file_name>&m=dev`"

Do not proceed without a valid Figma URL in dev mode.

## Phase 0 — Validate prerequisites

### 0.1 Figma URL

Parse the Figma URL to extract:

- **File key** — the alphanumeric segment after `/design/` or `/file/`
- **Node ID** (optional) — if the URL contains `?node-id=`, scope analysis to that subtree

If the URL format is unrecognizable, ask the user to double-check it.

### 0.2 Choose ticket system

Use **AskUserQuestion** to ask:

> "Where would you like to create tickets?"
>
> 1. **GitHub Issues** — requires `gh` CLI authenticated in the current repo
> 2. **Jira** — requires a Jira MCP server to be configured

Do not proceed until the user picks one.

### 0.3 Validate ticket system

#### If GitHub Issues

Run:

```bash
gh repo view --json nameWithOwner,url --jq '.nameWithOwner + " (" + .url + ")"'
```

If `gh` is not authenticated or no repo is detected, tell the user:

- Ensure `gh` CLI is installed and authenticated (`gh auth login`)
- Run the skill from inside the target repository

#### If Jira

Use the Jira MCP to list accessible projects (e.g. `list_projects` or equivalent). If the Jira MCP server is not configured or authentication fails, tell the user:

- Ensure a Jira MCP server is configured and authenticated
- Refer to their MCP server documentation for setup instructions

Then use **AskUserQuestion** to ask which Jira project to use and what issue type to create (e.g. Task, Story, Bug). Default to **Task** if the user has no preference.

### 0.4 Confirm scope

Use **AskUserQuestion** to confirm:

- **Figma file**: `<file_name>` (`<file_key>`)
- **Destination**: `<owner/repo>` (GitHub) or `<project_key>` (Jira)
- **Scope**: Entire file / specific page / specific node

Ask: "Does this look right? Any pages or sections to include or exclude?"

Do not proceed until the user confirms.

## Phase 1 — Read the design file

Use the **Figma MCP** tools to read the design file.

### 1.1 Get file structure

Use the Figma MCP `get_figma_data` tool to fetch the top-level structure of the file. Request depth 2 to see pages and their immediate children (frames/sections).

### 1.2 Identify work units

Walk through the returned node tree and categorize each top-level frame or section:

| Category | Heuristic |
|----------|-----------|
| **Screen** | Top-level frame on a page, typically device-sized (e.g., 375x812, 1440x900) |
| **Component** | Node of type `COMPONENT` or `COMPONENT_SET` |
| **Flow** | A group of frames connected by prototype links or named with a shared prefix (e.g., `Onboarding/Step1`, `Onboarding/Step2`) |
| **Shared element** | Repeated across multiple screens (nav bars, tab bars, modals) |

### 1.3 Deep-read important nodes

For each identified work unit, fetch additional detail from the Figma MCP if needed:

- Layout and dimensions
- Key text content (headings, labels, button text)
- Component variants and states (default, hover, error, disabled)
- Connections to other frames (prototype links)

Collect just enough detail to write a useful ticket — avoid exhaustive property dumps.

## Phase 2 — Organize into tickets

### 2.1 Group logically

Group work units into tickets using these guidelines:

- **One screen = one ticket** unless screens are trivially similar (e.g., empty vs. populated states of the same list). In that case, combine them.
- **Shared components** that appear across multiple screens get their own ticket, implemented first.
- **Flows** (multi-screen sequences like onboarding or checkout) can be a single ticket or split per screen — use judgment based on complexity. When in doubt, split.
- **Design system foundations** (colors, typography, spacing tokens) become a single setup ticket if they don't already exist in the codebase.

### 2.2 Determine ticket order

Sort tickets by dependency:

1. Design system / shared tokens (if needed)
2. Shared components (bottom-up: atoms before molecules)
3. Individual screens (ordered by flow, not alphabetically)
4. Integration / navigation wiring

### 2.3 Draft ticket list

For each ticket, draft:

- **Title** — conventional commit format: `feat: <concise description>`
- **Figma link** — deep link to the specific node in Dev Mode: `https://www.figma.com/design/<file_key>/<file_name>?node-id=<node_id>&m=dev`
- **Summary** — 2-3 sentences: what this screen/component does, key interactions
- **Acceptance criteria** — checkboxes covering visible states and behaviors
- **Design notes** — dimensions, key colors/tokens, component variants, responsive behavior
- **Dependencies** — which other tickets must land first (reference by title)

## Phase 3 — Review with user

Present the full ticket breakdown as a numbered list:

```
Proposed tickets (N total):

1. feat: add design tokens and theme setup
   Figma: <link>
   Depends on: —

2. feat: implement bottom navigation bar
   Figma: <link>
   Depends on: #1

3. feat: build home screen
   Figma: <link>
   Depends on: #1, #2

...
```

Use **AskUserQuestion** to ask:

- **Create all tickets** — proceed to Phase 4
- **Edit the list** — accept changes (merge, split, reorder, remove, rename)
- **Add labels or metadata** — specify labels (GitHub) or components/epics (Jira) to apply

Iterate until the user is satisfied.

## Phase 4 — Create tickets

### If GitHub Issues

#### 4.1 Check for existing labels

```bash
gh label list --limit 100 --json name --jq '.[].name'
```

If the user requested labels that don't exist, create them:

```bash
gh label create "<label>" --description "<description>"
```

#### 4.2 Create issues

For each approved ticket, create it using `gh`:

```bash
gh issue create \
  --title "<title>" \
  --body "$(cat <<'EOF'
## Summary

<summary text>

## Figma Design

🎨 [View in Figma (Dev Mode)](<figma_deep_link>)

## Acceptance Criteria

- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] <criterion 3>

## Design Notes

<dimensions, tokens, variants, responsive notes>

## Dependencies

<links to dependency issues or "None">
EOF
)" \
  --label "<label1>,<label2>"
```

**Important:**

- Create issues in dependency order so earlier issues exist when later ones reference them.
- After creating each issue, capture its number from the `gh` output.
- When an issue depends on a previously created issue, reference it with `#<number>` in the Dependencies section.

#### 4.3 Link to project (optional)

If the repository uses GitHub Projects, offer to add all issues to a project board:

```bash
gh project item-add <project_number> --owner <owner> --url <issue_url>
```

### If Jira

#### 4.1 Create tickets

For each approved ticket, use the Jira MCP to create an issue with:

- **Project**: the project key confirmed in Phase 0
- **Issue type**: the type confirmed in Phase 0 (default: Task)
- **Summary**: the ticket title
- **Description**: formatted as follows (using Jira wiki markup or ADF as supported by the MCP):

```
h2. Summary

<summary text>

h2. Figma Design

🎨 [View in Figma (Dev Mode)|<figma_deep_link>]

h2. Acceptance Criteria

* <criterion 1>
* <criterion 2>
* <criterion 3>

h2. Design Notes

<dimensions, tokens, variants, responsive notes>

h2. Dependencies

<links to dependency tickets or "None">
```

- **Labels / Components**: as requested by the user
- **Epic link**: if the user specified an epic

**Important:**

- Create tickets in dependency order so earlier tickets exist when later ones reference them.
- After creating each ticket, capture its key (e.g. `PROJ-123`) from the MCP response.
- When a ticket depends on a previously created ticket, reference it in the Dependencies section and create a "blocked by" link if supported by the MCP.

#### 4.2 Link to epic or board (optional)

If the user wants tickets added to an epic or sprint, use the Jira MCP to link them.

## Phase 5 — Summary

After all tickets are created, display:

### If GitHub Issues

```
Created N issues in <owner/repo>:

#<num> feat: add design tokens and theme setup
#<num> feat: implement bottom navigation bar
#<num> feat: build home screen
...

Figma source: <original_figma_url>
```

Use **AskUserQuestion** to offer next steps:

1. **Open issues in browser** — run `gh issue list --state open --json number,title,url` and display links
2. **Add to a GitHub Project** — add issues to an existing project board
3. **Start building** — pick an issue and run `/build`
4. **Done** — end the session

### If Jira

```
Created N tickets in <project_key>:

<PROJ-101> feat: add design tokens and theme setup
<PROJ-102> feat: implement bottom navigation bar
<PROJ-103> feat: build home screen
...

Figma source: <original_figma_url>
```

Use **AskUserQuestion** to offer next steps:

1. **Open tickets in browser** — display Jira URLs for each created ticket
2. **Add to a sprint** — use the Jira MCP to move tickets into an active or upcoming sprint
3. **Start building** — pick a ticket and run `/build`
4. **Done** — end the session

## Guidelines

- **Always use Dev Mode links.** Append `&m=dev` to every Figma URL so developers land directly in Dev Mode with inspect, measurements, and code snippets ready.
- **Link everything.** Every ticket must link to its Figma node. This is the primary value of the skill.
- **Right-size tickets.** A single button is too small. An entire app is too big. Target 1-3 day implementation scope per ticket.
- **Include visual context.** Mention key colors, sizes, and states so developers don't need to open Figma for basic implementation.
- **Respect existing patterns.** If the codebase already has a design system or theme, reference it in the tickets rather than asking developers to recreate tokens.
- **Be concise.** Ticket bodies should be scannable. Use bullet points and checklists, not paragraphs.

## Important

This skill creates tickets. It does NOT write code or implementation plans. For implementation, use `/plan` or `/build` on individual tickets after creation.
