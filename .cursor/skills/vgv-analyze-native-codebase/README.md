# vgv-analyze-native-codebase

A Claude Code skill for analyzing iOS and Android codebases to generate comprehensive Flutter migration manifests.

Follows the [Agent Skills specification](https://agentskills.io/specification).

## Structure

```
vgv-analyze-native-codebase/
├── SKILL.md                            # Main skill file (required)
├── README.md                           # This file
├── assets/
│   └── migration-manifest.schema.json  # Output schema (v2.0)
└── references/
    ├── REFERENCE.md                    # Detailed analysis steps (13 steps)
    └── FLUTTER_MAPPINGS.md             # Native-to-Flutter package mappings
```

## Features (v2.0)

- **Human-readable analysis report** (MIGRATION_ANALYSIS.md) for stakeholders
- **18-step analysis workflow** covering core, extended, and synthesis phases
- **7 new analysis areas**: Testing, CI/CD, Localization, Accessibility, Analytics, Error Handling, App Startup
- **T-shirt sizing** for all effort estimates (XS/S/M/L/XL)
- **Detailed risk rationale** explaining WHY each risk matters
- **Auto-generated PRD** capturing app intent and requirements
- **Per-feature reports** in organized folder structure
- **Swagger/OpenAPI support** for enhanced API analysis
- **15-category Flutter mappings** reference

## Usage

```bash
# Full analysis
/vgv-analyze-native-codebase

# Platform-specific
/vgv-analyze-native-codebase ios
/vgv-analyze-native-codebase android

# Focus areas
/vgv-analyze-native-codebase full screens
/vgv-analyze-native-codebase ios testing
/vgv-analyze-native-codebase android cicd

# With Swagger/OpenAPI spec
/vgv-analyze-native-codebase full --swagger=api/openapi.yaml
```

### Focus Areas

| Area | Description |
|------|-------------|
| `screens` | Screen/feature inventory |
| `dependencies` | Dependency analysis with Flutter mappings |
| `architecture` | Architecture pattern detection |
| `api` | API and data layer analysis |
| `testing` | Testing infrastructure |
| `cicd` | CI/CD configuration |
| `localization` | i18n analysis |
| `accessibility` | a11y implementation |
| `analytics` | Analytics tracking |
| `errors` | Error handling and crash reporting |
| `startup` | App initialization sequence |

## Output Structure

```
docs/
├── MIGRATION_ANALYSIS.md           # Human-readable analysis report
├── migration-manifest.yaml         # Machine-readable manifest (schema v2.0)
├── PRD.md                          # Auto-generated PRD
├── RISKS.md                        # Detailed risk analysis
└── features/
    ├── feature_auth/
    │   ├── ANALYSIS.md             # Feature analysis
    │   ├── screens.yaml            # Screen inventory
    │   ├── dependencies.yaml       # Dependencies
    │   └── migration_notes.md      # Migration notes
    └── feature_[name]/
        └── ...
```

### MIGRATION_ANALYSIS.md

The primary human-readable report with:
- Executive summary and key findings
- Architecture overview and recommendations
- Feature inventory with effort estimates
- Dependency analysis and Flutter mappings
- Platform-specific concerns
- Risk summary with mitigations
- Recommended migration phases

## T-Shirt Sizing

| Size | Meaning | Typical Scope |
|------|---------|---------------|
| XS | Trivial | < 1 day |
| S | Small | 1-2 days |
| M | Medium | 3-5 days |
| L | Large | 1-2 weeks |
| XL | Extra Large | 2+ weeks |

## Risk Analysis

Each risk includes detailed rationale:

```yaml
- id: risk_healthkit_complexity
  description: "HealthKit integration requires platform channels"
  rationale: "HealthKit uses privacy-sensitive APIs requiring native code..."
  impact: "Delayed timeline, potential feature parity gap"
  probability: high
  severity: high
  mitigation: "Spike: evaluate health_kit_flutter plugin coverage..."
  affected_features: [feature_health_dashboard]
```

## Validation

Validate the skill using [skills-ref](https://github.com/agentskills/agentskills):

```bash
skills-ref validate ./vgv-analyze-native-codebase
```

## Schema

The manifest follows JSON Schema Draft-07. Key additions in v2.0:

- `testing` - Testing infrastructure analysis
- `cicd` - CI/CD configuration
- `localization` - i18n analysis
- `accessibility` - a11y implementation
- `analytics` - Analytics tracking
- `error_handling` - Error patterns and crash reporting
- `startup_sequence` - App initialization analysis
- `prd` - Auto-generated PRD
- `analysis_report_path` - Path to MIGRATION_ANALYSIS.md
- `feature_reports_path` - Path to per-feature reports in docs/features/

See [assets/migration-manifest.schema.json](assets/migration-manifest.schema.json) for the full schema.

## License

MIT
