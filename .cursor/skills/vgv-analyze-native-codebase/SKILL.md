---
name: vgv-analyze-native-codebase
description: Analyze iOS (Swift/Objective-C) and Android (Kotlin/Java) codebases to generate comprehensive Flutter migration manifests. Use when planning native-to-Flutter migrations, auditing mobile codebases, or generating migration roadmaps.
compatibility: Requires access to native iOS and Android project files
metadata:
  author: very-good-ventures
  version: "2.0"
---

# Analyze Native Codebase for Flutter Migration

This skill analyzes native mobile codebases and generates a migration manifest for Flutter conversion.

## Usage

```
/vgv-analyze-native-codebase [platform] [focus-area] [--swagger=path]
```

| Argument | Values | Description |
|----------|--------|-------------|
| platform | `ios`, `android`, `full` | Target platform (default: `full`) |
| focus-area | `screens`, `dependencies`, `architecture`, `api`, `testing`, `cicd`, `localization`, `accessibility`, `analytics`, `errors`, `startup` | Optional focus area |
| --swagger | path to file | Optional Swagger/OpenAPI spec for enhanced API analysis |

### Examples

```bash
/vgv-analyze-native-codebase full                      # Complete analysis
/vgv-analyze-native-codebase ios screens               # iOS screens only
/vgv-analyze-native-codebase full --swagger=api/openapi.yaml  # With API spec
```

## Workflow Overview

### Phase 1: Core Analysis (Steps 1-6)
1. **Project Discovery** - Locate project roots and identify structure
2. **Dependency Inventory** - Catalog all dependencies with Flutter equivalents
3. **Architecture Detection** - Identify patterns (MVVM, VIPER, Clean, etc.)
4. **Screen Inventory** - Map all screens with metadata
5. **API Analysis** - Document network and data layers
6. **Platform API Audit** - Flag platform-specific features

### Phase 2: Extended Analysis (Steps 7-13)
7. **Testing Infrastructure** - Analyze test frameworks, coverage, mocking
8. **CI/CD Configuration** - Document build automation and deployment
9. **Localization** - Identify supported languages and i18n approach
10. **Accessibility** - Assess a11y implementation and compliance
11. **Analytics & Tracking** - Document analytics providers and events
12. **Error Handling** - Analyze crash reporting and error patterns
13. **App Startup Sequence** - Map initialization flow and dependencies

### Phase 3: Synthesis (Steps 14-18)
14. **Complexity Scoring** - Rate migration difficulty with t-shirt sizing
15. **Risk Analysis** - Identify risks with detailed rationale
16. **PRD Generation** - Auto-generate Product Requirements Document
17. **Feature Reports** - Generate per-feature detailed reports
18. **Manifest Generation** - Output YAML manifest with all artifacts

See [references/REFERENCE.md](references/REFERENCE.md) for detailed analysis steps.
See [references/FLUTTER_MAPPINGS.md](references/FLUTTER_MAPPINGS.md) for native-to-Flutter package mappings.

The manifest schema is bundled at [assets/migration-manifest.schema.json](assets/migration-manifest.schema.json).

## Project Structure Expected

```
.
├── native/
│   ├── ios/          # iOS project (.xcodeproj/.xcworkspace)
│   └── android/      # Android project (build.gradle)
├── api/              # Optional: Swagger/OpenAPI specs
│   └── openapi.yaml
└── docs/             # Analysis output location
```

## Output Structure

The skill generates an organized documentation folder:

```
docs/
├── MIGRATION_ANALYSIS.md           # Human-readable analysis report
├── migration-manifest.yaml         # Machine-readable manifest
├── PRD.md                          # Generated Product Requirements Document
├── RISKS.md                        # Detailed risk analysis with explanations
└── features/
    ├── feature_auth/
    │   ├── ANALYSIS.md             # Feature-specific analysis
    │   ├── screens.yaml            # Screen inventory
    │   ├── dependencies.yaml       # Dependencies used
    │   └── migration_notes.md      # Migration considerations
    ├── feature_home/
    │   └── ...
    └── ...
```

### MIGRATION_ANALYSIS.md

The primary human-readable report containing:

```markdown
# Migration Analysis: [App Name]

## Executive Summary
- Project overview and scope
- Key findings and recommendations
- Overall migration effort: [T-shirt size]

## Architecture Overview
- Current architecture patterns (iOS/Android)
- Recommended Flutter architecture
- Key architectural decisions needed

## Feature Inventory
| Feature | iOS | Android | Effort | Risks |
|---------|-----|---------|--------|-------|
| Auth    | UIKit | Compose | M | 1 |
| ...     | ...   | ...     | ... | ... |

## Dependency Analysis
- Critical dependencies requiring attention
- Drop-in replacements available
- Custom implementation needed

## Platform-Specific Concerns
- APIs requiring platform channels
- Feature parity gaps
- Native module requirements

## Testing & Quality
- Current test coverage
- Recommended Flutter testing strategy
- Quality gates for migration

## CI/CD Considerations
- Current build pipeline
- Flutter CI/CD recommendations
- Migration of secrets and signing

## Risk Summary
| Risk | Severity | Mitigation |
|------|----------|------------|
| ...  | ...      | ...        |

## Recommended Migration Phases
1. **Phase 1**: [Features] - [Effort]
2. **Phase 2**: [Features] - [Effort]
...

## Open Questions
- Items requiring stakeholder input
- Technical decisions to be made
```

### Main Manifest Structure

```yaml
version: "2.0"
generated_at: "2025-01-16T12:00:00Z"
project:
  name: "App Name"
  platforms: [ios, android]

ios:
  # iOS-specific analysis

android:
  # Android-specific analysis

features:
  # Unified feature list with platform mapping

dependencies:
  # Dependency inventory with Flutter mappings

api:
  swagger_source: "./api/openapi.yaml"  # If provided
  endpoints_from_spec: true
  # API endpoints and data contracts

testing:
  # Testing infrastructure analysis

cicd:
  # CI/CD configuration analysis

localization:
  # i18n analysis

accessibility:
  # a11y analysis

analytics:
  # Analytics tracking analysis

error_handling:
  # Error handling analysis

startup_sequence:
  # App initialization analysis

migration_plan:
  # Suggested phases with t-shirt sizing

prd:
  # Auto-generated PRD

feature_reports_path: "./docs/features/"
```

## T-Shirt Sizing for Estimates

All effort estimates use t-shirt sizing instead of numeric days:

| Size | Meaning | Typical Scope |
|------|---------|---------------|
| XS | Trivial | < 1 day, direct translation |
| S | Small | 1-2 days, minor adjustments |
| M | Medium | 3-5 days, some custom work |
| L | Large | 1-2 weeks, significant effort |
| XL | Extra Large | 2+ weeks, major implementation |

Applied to:
- Feature migration effort
- Dependency migration complexity
- Platform API integration effort
- Migration phase sizing
- Spike/POC effort
- Overall migration effort

## Complexity Scoring

Technical complexity uses a 1-5 scale:

| Score | Level | Description |
|-------|-------|-------------|
| 1 | Trivial | Direct translation, no platform specifics |
| 2 | Simple | Standard patterns, well-supported plugins |
| 3 | Moderate | Some custom logic, minor platform differences |
| 4 | Complex | Significant business logic, platform channels needed |
| 5 | Very Complex | Heavy platform integration, may need native modules |

## Risk Analysis

Each identified risk includes:

| Field | Description |
|-------|-------------|
| id | Unique identifier (e.g., `risk_healthkit_complexity`) |
| description | What is the risk |
| rationale | WHY it's a risk - detailed technical reasoning |
| impact | What happens if not addressed |
| probability | low / medium / high |
| severity | low / medium / high / critical |
| mitigation | Strategy to address the risk |
| affected_features | List of impacted feature IDs |

### Risk Example

```yaml
risks:
  - id: risk_healthkit_complexity
    description: "HealthKit integration requires platform channels"
    rationale: "HealthKit uses privacy-sensitive APIs that require native code. No Flutter plugin provides full HealthKit access. The app uses 12 different HealthKit data types including workout routes."
    impact: "Delayed timeline, potential feature parity gap"
    probability: high
    severity: high
    mitigation: "Spike: evaluate health_kit_flutter plugin coverage, plan custom platform channel for missing APIs"
    affected_features: [feature_health_dashboard, feature_workout_tracking]
```

## Optional Inputs

### Swagger/OpenAPI Specification

When a Swagger/OpenAPI file is available, provide it for enhanced API analysis:

**Supported formats:**
- `swagger.json` / `swagger.yaml` (Swagger 2.0)
- `openapi.json` / `openapi.yaml` (OpenAPI 3.x)

**Enhanced analysis when available:**

| Without Swagger | With Swagger |
|----------------|--------------|
| Endpoints inferred from code | Complete endpoint inventory from spec |
| Models extracted from source | Exact schema definitions with validation rules |
| Auth patterns detected | Full auth spec (OAuth flows, scopes, API keys) |
| Manual API matching | Automatic iOS/Android endpoint correlation |

**Benefits:**
- More accurate endpoint inventory (no missed endpoints)
- Precise request/response model definitions
- Flutter API client generation path (using openapi_generator)
- Validation rules already defined (can map to formz validators)
- Error response standardization

## Quality Checklist

Before finalizing the manifest:

### Core Analysis
- [ ] All screens from both platforms captured
- [ ] Navigation graph complete (no orphan screens)
- [ ] All dependencies listed with Flutter equivalents
- [ ] Platform-specific APIs flagged with complexity scores
- [ ] API endpoints match between platforms (or differences noted)
- [ ] Data models captured with field mappings
- [ ] Architecture pattern correctly identified

### Extended Analysis
- [ ] Testing frameworks and coverage documented
- [ ] CI/CD configuration captured
- [ ] Supported locales identified on both platforms
- [ ] Accessibility implementation assessed
- [ ] Analytics providers and event patterns documented
- [ ] Error handling and crash reporting analyzed
- [ ] App startup sequence mapped

### Synthesis
- [ ] T-shirt sizes realistic and justified
- [ ] Risks include detailed rationale (the "why")
- [ ] PRD captures app intent and requirements
- [ ] Feature reports generated for each feature
- [ ] Migration phases have clear boundaries
- [ ] No circular dependencies in package structure
- [ ] MIGRATION_ANALYSIS.md is complete and readable by non-technical stakeholders
