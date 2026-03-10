# Very Yummy Coffee UI

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A shared UI package providing the theme, design tokens, and reusable widgets for all Very Yummy Coffee applications.

## Overview

This is a pure UI package with no domain dependencies. All applications depend on it for consistent styling.

### Design Tokens

Accessed via `BuildContext` extensions:

- **`context.colors`** — named color tokens (`AppColors`: surface, text, primary, accent, status colors, etc.)
- **`context.spacing`** — spacing scale (`AppSpacing`: xxs=2, xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, huge=32)
- **`context.radius`** — border radius tokens (`AppRadius`: small=12, medium=14, large=18, card=20, pill=9999)
- **`context.typography`** — text styles (`AppTypography`: pageTitle, subtitle, label, body, muted, caption, etc.)

### Shared Widgets

- **`AppTopBar`** — dark top bar with connection indicator, title, live clock, and optional middle/action widget slots
- **`BaseButton`** — primary, secondary, and cancel button variants with loading state support
- **`CustomBackButton`** — standard back arrow for colored headers

### Widget Gallery

A gallery app for previewing shared widgets is available at `gallery/`.

## Testing

```sh
flutter test
```
