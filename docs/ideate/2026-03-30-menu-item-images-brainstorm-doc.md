---
date: 2026-03-30
topic: menu-item-images
---

# Menu item images (issue #28)

## What We're Building

Add optional `imageUrl` to each `MenuItem`, propagate it through HTTP and WebSocket menu payloads, seed `fixtures/menu.json` with a URL per item, and introduce a shared `MenuItemImage` widget in `very_yummy_coffee_ui` for loading, error, and empty states. Wire images into the mobile and kiosk item detail heroes, show thumbnails where the issue calls for them (mobile menu list optional, kiosk grid optional, POS item list optional), and display images prominently on the menu board. KDS is explicitly out of scope for images.

This matches [issue #28](https://github.com/VGVentures/very_yummy_coffee/issues/28): model + fixtures + backend passthrough + shared UI + per-app integration + widget tests, using design tokens only (no raw `Color(...)` or ad-hoc `TextStyle` in views).

### Existing codebase alignment

- `MenuGroup` already has optional `imageUrl`; the menu board’s `FeaturedItemPanel` uses `NetworkImage` inside a circular `DecorationImage` when `group.imageUrl` is set.
- Mobile `ItemDetailView` and kiosk `_ItemHeroPanel` today use a gradient or solid panel plus a circular **placeholder** (`Icons.local_cafe_outlined`), not real images—those heroes are the natural insertion points for `MenuItemImage`.
- `very_yummy_coffee_ui` has **no** third-party image packages today; network image guidance in repo standards points at `Image.network` with loading/error handling.

## Why This Approach

Three realistic ways to implement the shared widget differ mainly on **caching and dependencies**, not on the data model or API shape.

### **A — `Image.network` + `frameBuilder` / `errorBuilder` (recommended)**

Implement `MenuItemImage` with Flutter’s built-in network image API, a neutral placeholder (e.g. `context.colors.imagePlaceholder` + icon) while `frameBuilder` shows loading, and `errorBuilder` on failure. Optional: fixed aspect ratio via `AspectRatio` or a bounded `BoxFit.cover` clip controlled by constructor parameters (`hero` vs `thumbnail`).

- **Pros:** No new dependencies; stays within current `very_yummy_coffee_ui` constraints; consistent with internal standards snippets for network images; easy to test with `networkImageMocks` / `HttpOverrides` patterns if needed.
- **Cons:** No disk cache—scrolling back through long lists may refetch images (acceptable for the current small fixture menu).
- **Best when:** Ship the feature quickly, keep the shared UI package minimal, and URLs are stable CDN or placeholder services.

### **B — Add `cached_network_image` (or similar) in `very_yummy_coffee_ui`**

Same API surface for `MenuItemImage`, but backed by a caching package.

- **Pros:** Better scroll performance and less network churn on menu grids and repeated visits.
- **Cons:** New shared dependency for all apps; extra version/maintenance surface; may require golden or integration care for cache behavior.
- **Best when:** Production menus are large, images are heavy, or offline-ish repeat viewing is a product priority.

### **C — Asset-only images keyed by item id**

Store files under `assets/` and map `id` → asset path in code or a small map, skipping remote URLs in fixtures.

- **Pros:** Works fully offline; no network failures in UI.
- **Cons:** Conflicts with the issue’s acceptance criteria (optional `imageUrl` on the model and URLs in fixtures); more asset pipeline work per new item.
- **Best when:** Not this issue—reserve for a deliberate “offline menu” follow-up.

**Choice for this effort:** Prefer **Approach A** unless product explicitly prioritizes caching (then **B**). The issue asks for URL-based data and a reusable widget, not a caching layer.

## Key Decisions

- **Model:** Add `String? imageUrl` to `MenuItem` with default `null` for backwards-compatible JSON; regenerate `dart_mappable` output.
- **Fixtures:** One HTTPS URL per item (placeholder service or static CDN is fine); keep entries valid JSON and consistent with existing `menu.json` structure.
- **Backend:** No special routes required if menu is already loaded from fixtures and broadcast as JSON—ensure serialized `MenuItem` maps include `imageUrl` for HTTP snapshot and WS `update` payloads (verify `server_state` / serialization path).
- **Shared widget:** `MenuItemImage` lives in `very_yummy_coffee_ui`, takes primitives (`String? imageUrl`, layout hints such as `BoxFit`, optional fixed aspect ratio or size), and never imports repositories. If `imageUrl` is null, skip the network request and show the placeholder. If a URL is present but loading fails, `errorBuilder` shows the **same** placeholder so missing and broken images look identical.
- **Apps:** Mobile + kiosk item detail **must** show the image per AC; menu board **must** show item images prominently; POS thumbnail is optional per issue—implement if layout allows without crowding; KDS unchanged.
- **Tests:** New widget tests for `MenuItemImage` (loading/error/null states); follow `pumpApp` / project test helpers. Avoid introducing raw color or font literals in new code. **Risk:** Tests must not depend on live HTTP—mock network images (`HttpOverrides`, golden-friendly fakes, or project patterns) so CI stays deterministic.

## Planning defaults (refinement)

These unblock `/plan` without waiting on product. Revise if stakeholder input disagrees.

- **Hero vs thumbnail:** Implement `MenuItemImage` with two explicit layouts (names TBD in code, e.g. constructor variants or an enum): **hero** — fills the existing hero regions with `BoxFit.cover` inside the current mobile/kiosk bounds (rounded rect or full-width banner, matching each screen’s existing chrome); **thumbnail** — square, fixed small extent for optional list/grid chips. Mobile and kiosk heroes both use **hero**; they need not share identical pixel dimensions.
- **Menu board:** Show the **item** image prominently as a **rounded rectangle or card** (via `MenuItemImage`), distinct from the **circular** group image in `FeaturedItemPanel`, so group vs item are not confused when both have URLs.
- **POS:** **Defer** the optional grid thumbnail in v1 to keep scope small; the issue marks it optional. Add in a fast follow if desired.
- **GitHub Actions:** If Approach B adds a dependency, run `.github/update_github_actions.sh` after `pubspec.yaml` changes (per `CLAUDE.md`).

## Open Questions (only if product pushes back)

- POS thumbnail in the first release instead of deferral.
- Switching to Approach B (`cached_network_image`) after real-world performance feedback.

---

**Next step:** Run `/plan` (models → fixtures/api → `MenuItemImage` + tests → app integrations). Revisit Approach A vs B only if caching becomes a stated requirement.
