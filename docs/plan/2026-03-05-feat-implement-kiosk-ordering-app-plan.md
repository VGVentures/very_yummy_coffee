---
title: "feat: implement kiosk ordering app"
type: feat
date: 2026-03-05
---

# feat: implement kiosk ordering app — Extensive

> **User flow analysis completed 2026-03-05.** Key gaps identified and resolved below in [User Flow Analysis Findings](#user-flow-analysis-findings).
> **Technical review completed 2026-03-05.** Critical and important issues applied below.

## Overview

Create `applications/kiosk_app` — a Flutter iPad/tablet kiosk application for in-store self-service ordering. The app mirrors mobile_app's full ordering flow (Home → Menu Groups → Menu Items → Item Detail → Cart → Checkout → Order Complete) adapted for a landscape 1366×1024 kiosk display with larger touch targets and split-pane layouts. Reuses all existing shared packages and the Dart Frog WebSocket backend with no backend changes.

---

## Problem Statement

The monorepo currently has:
- `mobile_app` — customer self-service app (iOS/Android phone)
- `kds_app` — kitchen display system (landscape tablet)
- `pos_app` — staff POS terminal (iPad)
- `menu_board_app` — passive display board

There is no in-store kiosk for customers to self-order on a fixed tablet.

---

## Proposed Solution

A new `applications/kiosk_app` Flutter package targeting iOS/Android tablet. Eight screens behind a WebSocket connection guard:

| Route | Screen | Layout |
|---|---|---|
| `/connecting` | `ConnectingPage` | Centered loading indicator |
| `/home` | `HomePage` | Full-screen BG image + brand name + tagline + "Start Order" gold pill |
| `/home/menu` | `MenuGroupsPage` | KioskHeader + 3 equal category cards in horizontal row |
| `/home/menu/:groupId` | `MenuItemsPage` | KioskHeader (back + group title + cart badge) + 2-column item grid |
| `/home/menu/:groupId/:itemId` | `ItemDetailPage` | KioskHeader + split pane (hero left, customization right) |
| `/home/menu/cart` | `CartPage` | KioskHeader + split pane (item list left, order summary right) |
| `/home/menu/cart/checkout` | `CheckoutPage` | KioskHeader + fake payment + order summary + "Place Order" bottom bar |
| `/home/menu/cart/checkout/confirmation/:orderId` | `OrderCompletePage` | Split pane (success hero left, order status right) |

---

## Key Research Findings

### No Shared Package Changes Needed

All required repository APIs already exist:
- `MenuRepository.getMenuGroups()` — [`shared/menu_repository/lib/src/menu_repository.dart:42`](shared/menu_repository/lib/src/menu_repository.dart#L42)
- `MenuRepository.getMenuItems(groupId)` — [`shared/menu_repository/lib/src/menu_repository.dart:62`](shared/menu_repository/lib/src/menu_repository.dart#L62)
- `MenuRepository.getMenuItem(groupId, itemId)` — [`shared/menu_repository/lib/src/menu_repository.dart:54`](shared/menu_repository/lib/src/menu_repository.dart#L54)
- `OrderRepository.currentOrderStream`, `createOrder()`, `addItemToCurrentOrder()`, `updateItemQuantity()`, `removeItemFromCurrentOrder()`, `submitCurrentOrder()`, `clearCurrentOrder()` — all present
- `OrderRepository.orderStream(orderId)` — for OrderComplete real-time tracking

### Bloc Reuse

All blocs are thin `emit.forEach` wrappers (20–40 lines each) identical to mobile_app. They can be copied with package-name substitution and no logic changes:

| Kiosk Bloc | Source | Notes |
|---|---|---|
| `AppBloc` | [`mobile_app/lib/app/bloc/app_bloc.dart`](applications/mobile_app/lib/app/bloc/app_bloc.dart) | Identical — connection state only |
| `MenuGroupsBloc` | [`mobile_app/lib/menu_groups/bloc/`](applications/mobile_app/lib/menu_groups/bloc/) | Identical |
| `MenuItemsBloc` | [`mobile_app/lib/menu_items/bloc/`](applications/mobile_app/lib/menu_items/bloc/) | Identical |
| `ItemDetailBloc` | [`mobile_app/lib/item_detail/bloc/`](applications/mobile_app/lib/item_detail/bloc/) | Identical |
| `CartBloc` | [`mobile_app/lib/cart/bloc/`](applications/mobile_app/lib/cart/bloc/) | Identical |
| `CheckoutBloc` | [`mobile_app/lib/checkout/bloc/`](applications/mobile_app/lib/checkout/bloc/) | Identical |
| `OrderCompleteBloc` | [`mobile_app/lib/order_complete/bloc/`](applications/mobile_app/lib/order_complete/bloc/) | Identical |
| `CartCountBloc` | New (kiosk-specific) | Lightweight; provides cart badge count to header |

### Cart Badge — CartCountBloc Pattern

The kiosk header shows a live cart badge (item count) on Menu Groups, Menu Items, and Item Detail screens. Rather than hoisting `CartBloc` to the parent route (violating the "scope to feature" rule), a dedicated thin `CartCountBloc` is introduced:

```
lib/cart_count/
  bloc/
    cart_count_bloc.dart   // subscribes to currentOrderStream; emits item count
    cart_count_event.dart  // CartCountSubscriptionRequested
    cart_count_state.dart  // CartCountState { int itemCount }
  cart_count.dart
```

`CartCountBloc` is provided at `MenuGroupsPage` level (the GoRouter parent of all `/home/menu/*` routes). `KioskHeader` reads the count via `BlocSelector<CartCountBloc, CartCountState, int>`. `CartBloc` remains scoped to `CartPage` independently.

### Home Screen — No Bloc Needed

The kiosk Home screen is a static splash (BG image + brand name + "Start Order" button). No `HomeBloc` is required. `HomePage` contains only a `HomeView` — a `StatelessWidget` with a `Stack` layout.

### Split-Pane Layout Pattern

Three screens use a fixed-left / fill-right `Row` layout:
- **Item Detail**: 520px primary-colored left panel (hero), fill right panel (customization + cart bar)
- **Cart**: fill left (item list), 400px right (summary panel)
- **Order Complete**: 520px primary-colored left (success hero + back button), fill right (status cards)

---

## Technical Approach

### Architecture

The kiosk mirrors mobile_app exactly:
- **State management**: Bloc (with explicit event classes; no Cubits)
- **Navigation**: GoRouter with hardcoded `context.go('/path')` strings
- **Localization**: flutter_gen l10n with `lib/l10n/arb/app_en.arb`
- **Analysis**: `bloc_lint/recommended.yaml` + `very_good_analysis` + `public_member_api_docs: false`
- **Orientation**: locked to landscape in `main.dart` via `SystemChrome.setPreferredOrientations`
- **Theme**: `CoffeeTheme.light` from `very_yummy_coffee_ui`

### Router

`AppRouter` mirrors [`mobile_app/lib/app/app_router/app_router.dart`](applications/mobile_app/lib/app/app_router/app_router.dart) exactly — same routes, same redirect logic (disconnected → `/connecting`, connected + on `/connecting` → `/home`). Route structure:

```
/connecting
/home
  /menu                         ← MenuGroupsPage (provides CartCountBloc)
    /cart                       ← CartPage
      /checkout                 ← CheckoutPage
        /confirmation/:orderId  ← OrderCompletePage
    /:groupId                   ← MenuItemsPage
      /:itemId                  ← ItemDetailPage
```

### KioskHeader Widget

Internal kiosk-only shared widget (`lib/widgets/kiosk_header.dart`). NOT placed in `very_yummy_coffee_ui`.

```dart
class KioskHeader extends StatelessWidget {
  const KioskHeader({
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.showCartBadge = false,
    this.onCartTapped,
    super.key,
  });
```

- No `height` parameter — the header sizes to its content via padding on an `IntrinsicHeight` or fixed padding (48px vertical on Menu Groups, 28px on others). Callers do not set height; design differences come from content (two-line vs one-line title).
- Primary color background, white text
- Back button: 64×64 rounded pill (`context.colors.primaryForeground` at 20% opacity, via `withValues(alpha: 0.2)`), `chevron-left` icon
- Cart badge pill: shopping bag icon + "Cart (N)" text
- Cart count read from `BlocSelector<CartCountBloc, CartCountState, int>` when `showCartBadge` is true

### Feature File Structure

Each feature follows the standard pattern:

```
lib/<feature>/
  <feature>.dart              # barrel export
  bloc/
    <feature>_bloc.dart
    <feature>_event.dart
    <feature>_state.dart
  view/
    view.dart                 # barrel export
    <feature>_page.dart       # provides Bloc; defines routeName + pageBuilder
    <feature>_view.dart       # BlocBuilder UI
```

### l10n Strings Required

New kiosk-specific strings for `app_en.arb`:

| Key | Value |
|---|---|
| `kioskBrandName` | `Very Yummy Coffee` |
| `kioskTagline` | `Freshly brewed, just for you.` |
| `kioskStartOrder` | `Start Order` |
| `kioskCartBadge` | `Cart ({count})` |
| `kioskBackToMenu` | `Back to Menu` |
| `kioskOrderPlacedTitle` | `Order Placed!` |
| `kioskOrderPlacedSubtitle` | `We're brewing your order now.\nSee you in a few minutes!` |

Strings shared with mobile_app (redefine in kiosk arb):
- `itemDetailSizeLabel`, `itemDetailMilkLabel`, `itemDetailAddToCart`
- `cartTitle`, `cartEmptyTitle`, `cartEmptySubtitle`, `cartBrowseMenu`
- `cartOrderSummaryLabel`, `cartSubtotalLabel`, `cartTaxLabel`, `cartTotalLabel`
- `checkoutTitle`, `checkoutFakePaymentLabel`, `checkoutFakePaymentSubtitle`, `checkoutPlaceOrder`
- `orderCompleteStep1/2/3/4`, `errorSomethingWentWrong`

---

## Implementation Phases

### Phase 0: Project Scaffold

**Goal:** Runnable Flutter app skeleton with connection guard, theme, and l10n.

Files to create:
- `applications/kiosk_app/pubspec.yaml` — same deps as mobile_app; name: `very_yummy_coffee_kiosk_app`
- `applications/kiosk_app/analysis_options.yaml` — bloc_lint + very_good_analysis + `public_member_api_docs: false`
- `applications/kiosk_app/l10n.yaml` — `arb-dir: lib/l10n/arb`
- `applications/kiosk_app/.gitignore` — copy from `applications/kds_app/.gitignore`
- `applications/kiosk_app/lib/main.dart` — orientation lock + MultiRepositoryProvider (ConnectionRepository, MenuRepository, OrderRepository) + `App`
- `applications/kiosk_app/lib/app/bloc/app_bloc.dart` (+ `app_event.dart`, `app_state.dart`) — identical to mobile_app
- `applications/kiosk_app/lib/app/view/app.dart` — MaterialApp.router + CoffeeTheme.light + l10n
- `applications/kiosk_app/lib/app/view/connecting_page.dart` — identical to mobile_app
- `applications/kiosk_app/lib/app/view/view.dart` — barrel
- `applications/kiosk_app/lib/app/app_router/app_router.dart` — full router (stub page builders initially)
- `applications/kiosk_app/lib/app/app.dart` — barrel
- `applications/kiosk_app/lib/l10n/l10n.dart` — `extension on BuildContext`
- `applications/kiosk_app/lib/l10n/arb/app_en.arb` — all strings

**Key pubspec.yaml `flutter` section** (easy to miss):
```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/images/home_bg.jpg
```

`flutter_localizations` must be listed as an SDK dependency alongside `intl`.

**New `AppColors` token needed** (add to `shared/very_yummy_coffee_ui` before Phase 2):
- `homeBackgroundOverlay` = `Color(0x30000000)` — 19% black overlay for home screen BG

Post-scaffold commands:
```sh
cd applications/kiosk_app && flutter gen-l10n
.github/update_github_actions.sh  # after pubspec.yaml is final
```

**Success criteria:** `flutter analyze` passes with no issues; app launches to connecting screen.

---

### Phase 1: KioskHeader + CartCountBloc

**Goal:** Core header widget and cart badge infrastructure used by all menu screens.

Files to create:
- `applications/kiosk_app/lib/widgets/kiosk_header.dart` — `KioskHeader` widget per design spec
- `applications/kiosk_app/lib/widgets/widgets.dart` — barrel export
- `applications/kiosk_app/lib/cart_count/bloc/cart_count_bloc.dart`
- `applications/kiosk_app/lib/cart_count/bloc/cart_count_event.dart`
- `applications/kiosk_app/lib/cart_count/bloc/cart_count_state.dart`
- `applications/kiosk_app/lib/cart_count/cart_count.dart`

`CartCountBloc` logic:
```dart
// CartCountState: { int itemCount }
// CartCountSubscriptionRequested event
on<CartCountSubscriptionRequested>(_onSubscriptionRequested);

Future<void> _onSubscriptionRequested(...) async {
  await emit.forEach(
    _orderRepository.currentOrderStream,
    onData: (order) => CartCountState(
      itemCount: order?.items.fold(0, (sum, i) => sum + i.quantity) ?? 0,
    ),
    onError: (_, _) => const CartCountState(),
  );
}
```

**Success criteria:** KioskHeader renders correctly with back button, title, and cart badge slots.

---

### Phase 2: Home Screen

**Goal:** Full-screen kiosk splash with background image and "Start Order" button.

Files to create:
- `applications/kiosk_app/lib/home/view/home_page.dart` — simple StatelessWidget wrapping HomeView; `routeName = '/home'`
- `applications/kiosk_app/lib/home/view/home_view.dart` — Stack layout
- `applications/kiosk_app/lib/home/view/view.dart` — barrel
- `applications/kiosk_app/lib/home/home.dart` — barrel

**HomeView layout:**
```
PopScope(canPop: false)          // prevents OS back from exiting app
└── Scaffold
    └── Stack (fill screen)
        ├── Image.asset('assets/images/home_bg.jpg', fit: BoxFit.cover)  // bundled asset
        ├── ColoredBox(color: context.colors.homeBackgroundOverlay, fill) // named token
        └── Center
            └── Column (mainAxisSize: min, gap: spacing.huge × 1.5)
                ├── Text(l10n.kioskBrandName, typography.pageTitle at 88sp, primaryForeground)
                ├── Text(l10n.kioskTagline, 28sp, primaryForeground.withValues(alpha: 0.67))
                └── GestureDetector → context.go('/home/menu')
                    └── pill container (accentGold bg, 28/80 padding, radius.pill)
                        └── Text(l10n.kioskStartOrder, 36sp bold, foreground color)
```

Background image is a bundled asset (`assets/images/home_bg.jpg`) — not `Image.network`. Using an asset eliminates the network dependency for a retail kiosk that may not have internet access and removes the need for an `errorBuilder` fallback.

**Success criteria:** Home screen renders with overlay, brand name, tagline, and "Start Order" button. Tapping navigates to `/home/menu`. OS back gesture does nothing.

---

### Phase 3: Menu Groups Screen

**Goal:** Category selection screen with horizontal 3-card layout.

Files to create:
- `applications/kiosk_app/lib/menu_groups/bloc/menu_groups_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/menu_groups/view/menu_groups_page.dart` — provides MenuGroupsBloc + CartCountBloc
- `applications/kiosk_app/lib/menu_groups/view/menu_groups_view.dart`
- `applications/kiosk_app/lib/menu_groups/view/view.dart`
- `applications/kiosk_app/lib/menu_groups/menu_groups.dart`

**MenuGroupsPage provides:**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => MenuGroupsBloc(...)..add(MenuGroupsSubscriptionRequested())),
    BlocProvider(create: (_) => CartCountBloc(...)..add(CartCountSubscriptionRequested())),
  ],
  child: const MenuGroupsView(),
)
```

**MenuGroupsView layout:**
```
Scaffold
├── KioskHeader(
│     title: l10n.kioskBrandName,
│     subtitle: l10n.kioskWhatWouldYouLike,
│     showCartBadge: true,
│     onCartTapped: () => context.go('/home/menu/cart'),
│   )
└── Expanded
    └── BlocBuilder<MenuGroupsBloc, MenuGroupsState>
        └── Row(children: groups.map(_CategoryCard.new))  // equal flex width, gap: spacing.xxl
```

**_CategoryCard:**
- `cornerRadius: context.radius.card`
- Gradient background (group-specific colors from design tokens)
- Category image placeholder area (gradient fill matching design)
- Footer: category name (subtitle style, card color), item count (muted)
- Tap → `context.go('/home/menu/${group.id}')`

**Success criteria:** Three category cards fill the row equally; tapping navigates to correct group.

---

### Phase 4: Menu Items Screen

**Goal:** 2-column item grid for a selected category.

Files to create:
- `applications/kiosk_app/lib/menu_items/bloc/menu_items_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/menu_items/view/menu_items_page.dart`
- `applications/kiosk_app/lib/menu_items/view/menu_items_view.dart`
- `applications/kiosk_app/lib/menu_items/view/view.dart`
- `applications/kiosk_app/lib/menu_items/menu_items.dart`

`MenuItemsPage` extracts `groupId` from `GoRouterState.pathParameters['groupId']!` and passes to `MenuItemsBloc`.

**MenuItemsView layout:**
```
Scaffold
├── BlocSelector<MenuGroupsBloc, MenuGroupsState, String>(
│     selector: (s) => s.groups.where((g) => g.id == groupId).firstOrNull?.name ?? '',
│     builder: (context, groupName) => KioskHeader(
│       showBackButton: true,
│       onBack: () => context.go('/home/menu'),
│       title: groupName,
│       showCartBadge: true,
│       onCartTapped: () => context.go('/home/menu/cart'),
│     ),
│   )
└── Expanded
    └── GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: spacing.xl, crossAxisSpacing: spacing.xl,
          ),
          padding: EdgeInsets.all(spacing.xxl),
          itemBuilder: (_, i) => _ItemCard(item: items[i], groupId: groupId),
        )
```

Group name is derived reactively via `BlocSelector<MenuGroupsBloc, ...>` — not via `context.read` (which would not rebuild when state changes). `MenuGroupsBloc` is in the widget tree because `MenuGroupsPage` is the GoRouter parent route.

**_ItemCard:**
- Custom card with gradient image area, item name, price
- Unavailable: `ColoredBox(colors.unavailableOverlay)` stacked on top, `IgnorePointer` wrapping tap
- Tap (if available) → `context.go('/home/menu/$groupId/${item.id}')`

**Success criteria:** 2-column grid of items; unavailable items overlaid; tapping navigates to item detail.

---

### Phase 5: Item Detail Screen

**Goal:** Split-pane customization screen with left hero and right options panel.

Files to create:
- `applications/kiosk_app/lib/item_detail/bloc/item_detail_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/item_detail/view/item_detail_page.dart`
- `applications/kiosk_app/lib/item_detail/view/item_detail_view.dart`
- `applications/kiosk_app/lib/item_detail/view/view.dart`
- `applications/kiosk_app/lib/item_detail/item_detail.dart`

**ItemDetailView layout:**
```
Scaffold
├── KioskHeader(
│     showBackButton: true,
│     onBack: () => context.go('/home/menu/$groupId'),
│     title: state.item?.name ?? '',
│     showCartBadge: true,
│     onCartTapped: () => context.go('/home/menu/cart'),
│   )
└── Expanded
    └── Row
        ├── _ItemHeroPanel(width: 520, primary bg)  // left
        │   └── Column(center): hero circle, name, description, price pill
        └── _ItemCustomPanel(fill)                  // right
            ├── Expanded
            │   └── SingleChildScrollView
            │       └── Column: size picker, milk picker, extras toggles
            └── _AddToCartBar (card bg, bordered top)
                └── Row: qty stepper + BaseButton("Add to Cart")
```

On `ItemDetailStatus.added` → navigate back: `context.go('/home/menu/$groupId')`.

**Success criteria:** Split pane renders; size/milk/qty selections work; "Add to Cart" adds item and returns to menu items.

---

### Phase 6: Cart Screen

**Goal:** Review cart and proceed to checkout.

Files to create:
- `applications/kiosk_app/lib/cart/bloc/cart_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/cart/view/cart_page.dart`
- `applications/kiosk_app/lib/cart/view/cart_view.dart`
- `applications/kiosk_app/lib/cart/view/view.dart`
- `applications/kiosk_app/lib/cart/cart.dart`

**CartView layout:**
```
Scaffold
├── KioskHeader(
│     showBackButton: true,
│     onBack: () => context.go('/home/menu'),
│     title: l10n.cartTitle,
│     subtitle: l10n.cartItemCount(itemCount),
│   )
└── Expanded
    └── Row
        ├── Expanded                             // left: item list
        │   └── ListView.builder (CartItems)
        │       └── _CartItemRow: name+options, qty stepper, delete btn
        └── _OrderSummaryPanel(width: 400)       // right: summary + checkout
            ├── Expanded: subtotal, tax, total rows
            └── BaseButton(l10n.kioskProceedToCheckout)
                → context.go('/home/menu/cart/checkout')
```

Empty cart → centered message + "Browse Menu" button → `context.go('/home/menu')`.

**Success criteria:** Cart items display with working qty steppers and delete; order summary totals are correct; "Proceed to Checkout" navigates.

---

### Phase 7: Checkout Screen

**Goal:** Confirm order with fake payment and place it.

Files to create:
- `applications/kiosk_app/lib/checkout/bloc/checkout_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/checkout/view/checkout_page.dart`
- `applications/kiosk_app/lib/checkout/view/checkout_view.dart`
- `applications/kiosk_app/lib/checkout/view/view.dart`
- `applications/kiosk_app/lib/checkout/checkout.dart`

**CheckoutView layout:**
```
Scaffold
├── KioskHeader(
│     showBackButton: true,
│     onBack: () => context.go('/home/menu/cart'),
│     title: l10n.checkoutTitle,
│     subtitle: '${itemCount} items · $total',
│   )
├── Expanded
│   └── SingleChildScrollView
│       └── Column: _FakePaymentCard, _OrderSummaryCard
└── _PlaceOrderBar (card bg, bordered top, height 100)
    └── BaseButton(l10n.checkoutPlaceOrder(total), isLoading: submitting)
        → add CheckoutConfirmed()
```

On `CheckoutStatus.success` → `context.go('/home/menu/cart/checkout/confirmation/$orderId')`.

**Success criteria:** Fake payment card shows; order summary matches cart; "Place Order" submits and navigates to order complete.

---

### Phase 8: Order Complete Screen

**Goal:** Show success state and order tracking; let customer start a new order.

Files to create:
- `applications/kiosk_app/lib/order_complete/bloc/order_complete_bloc.dart` (+ event, state) — identical to mobile_app
- `applications/kiosk_app/lib/order_complete/view/order_complete_page.dart`
- `applications/kiosk_app/lib/order_complete/view/order_complete_view.dart`
- `applications/kiosk_app/lib/order_complete/view/view.dart`
- `applications/kiosk_app/lib/order_complete/order_complete.dart`

**OrderCompleteView layout:**
```
Scaffold
└── Row
    ├── _SuccessHeroPanel(width: 520, primary bg)   // left
    │   └── Column(center): checkmark circle, "Order Placed!", subtitle, back button
    │       └── "Back to Menu" ghost pill → _onBackToMenu(context)
    └── _OrderStatusPanel(fill)                     // right
        └── Column:
            ├── _StatusTrackerCard (OrderStepTracker widget)
            ├── _OrderNumberCard (#XXX + grand total row)
            └── _OrderItemsCard (list of items with options + price)
```

Add `OrderCompleteBackToMenuRequested` event to `OrderCompleteBloc`:
```dart
// event
class OrderCompleteBackToMenuRequested extends OrderCompleteEvent { const OrderCompleteBackToMenuRequested(); }

// handler (no-op on repo, but through the Bloc for layer separation)
void _onBackToMenuRequested(OrderCompleteBackToMenuRequested event, Emitter<OrderCompleteState> emit) {
  // _orderRepository._currentOrderId is already null after submitCurrentOrder().
  // clearCurrentOrder() is called defensively in case of an edge-case timing issue.
  _orderRepository.clearCurrentOrder();
  emit(state.copyWith(status: OrderCompleteStatus.navigatingBack));
}
```

In `OrderCompleteView`, the `BlocConsumer` listener navigates on `navigatingBack`:
```dart
listener: (context, state) {
  if (state.status == OrderCompleteStatus.navigatingBack) {
    context.go('/home/menu');
  }
},
```

The "Back to Menu" button dispatches:
```dart
context.read<OrderCompleteBloc>().add(const OrderCompleteBackToMenuRequested());
```

**No direct `context.read<OrderRepository>()` calls in the view.** All repository interactions go through the Bloc.

**Success criteria:** Success hero renders; order status tracker shows live updates; "Back to Menu" dispatches `OrderCompleteBackToMenuRequested`, which clears the order via Bloc and navigates to `/home/menu`.

---

### Phase 9: Tests + CI

**Goal:** Widget test coverage for all views; CI passes.

**Test helpers:**
- `test/helpers/pump_app.dart` — provides theme, l10n, routing, and injected repositories

**Bloc unit tests** (using `blocTest` + `mocktail`; all states covered):

| Test file | State scenarios covered |
|---|---|
| `test/app/bloc/app_bloc_test.dart` | `AppStarted` → connected; `AppStarted` → disconnected |
| `test/menu_groups/bloc/menu_groups_bloc_test.dart` | loading → success; loading → failure |
| `test/menu_items/bloc/menu_items_bloc_test.dart` | loading → success; loading → failure; empty items |
| `test/item_detail/bloc/item_detail_bloc_test.dart` | subscription (success/failure/null item); size/milk/extra selection; qty inc/dec (min clamp); add to cart (success/failure/no item) |
| `test/cart/bloc/cart_bloc_test.dart` | subscription (success/failure); quantity update; empty order state |
| `test/checkout/bloc/checkout_bloc_test.dart` | subscription (success/failure/null); `CheckoutConfirmed` (success/failure/submitting) |
| `test/order_complete/bloc/order_complete_bloc_test.dart` | subscription (success/failure/null); `OrderCompleteBackToMenuRequested` emits `navigatingBack` |
| `test/cart_count/bloc/cart_count_bloc_test.dart` | count = 0 (null order); count = sum of quantities; count on order update |

**Widget tests** (each view covers all Bloc states):

| Test file | States to cover |
|---|---|
| `test/home/view/home_view_test.dart` | Renders correctly; tap "Start Order" navigates |
| `test/menu_groups/view/menu_groups_view_test.dart` | Loading spinner; success (3 cards); failure; cart badge count; tap navigates |
| `test/menu_items/view/menu_items_view_test.dart` | Loading; success (2-column grid); failure; unavailable item overlay + no tap |
| `test/item_detail/view/item_detail_view_test.dart` | Loading; success split pane; unavailable item disables button; `added` navigates to groupId route |
| `test/cart/view/cart_view_test.dart` | Loading; success with items; empty state; checkout button disabled when empty |
| `test/checkout/view/checkout_view_test.dart` | Loading; success (fake payment + summary); submitting (loading button); failure error |
| `test/order_complete/view/order_complete_view_test.dart` | Loading; success (hero + tracker); "Back to Menu" dispatches event + navigates |
| `test/widgets/kiosk_header_test.dart` | No back button (showBackButton=false); back button visible + callback; cart badge hidden; cart badge with count; cart tap callback |

**CI steps:**
```sh
flutter gen-l10n
flutter pub get
flutter analyze --fatal-infos
flutter test
.github/update_github_actions.sh
```

**Success criteria:** `flutter analyze` zero warnings; all tests pass; GitHub Actions CI green.

---

---

## User Flow Analysis Findings

A user-flow analysis was run over the full 8-screen flow. The following gaps were identified and resolved.

### ✅ CartCountBloc Scope is Correct

Cart and Checkout headers in the design do NOT show a cart badge pill — they show an item count as plain subtitle text (`"3 items"` / `"3 items · $20.25"`). The cart badge pill only appears on Menu Groups, Menu Items, and Item Detail — all children of `MenuGroupsPage` in the widget tree. Providing `CartCountBloc` at `MenuGroupsPage` level is sufficient. No wider scope needed.

### 🔧 Route Ordering: `cart` MUST Be Registered Before `:groupId`

GoRouter matches routes in definition order. If `:groupId` is registered before `cart`, navigating to `/home/menu/cart` matches `:groupId = "cart"` and loads `MenuItemsPage` with a nonsense groupId.

**Resolution:** In `AppRouter`, define the `cart` child route BEFORE the `:groupId` child route (matching the mobile app's ordering). Add an explanatory inline comment in the router.

### 🔧 Order Complete Screen: Exempt from Disconnection Redirect

The POS app exempts `/pos-order-complete/:orderId` from the connection-drop redirect. If the kiosk applies the same blanket redirect (all non-connected → `/connecting`), a brief network blip yanks the customer off their Order Complete confirmation screen with no way back.

**Resolution:** Add an `onOrderComplete` check in the kiosk's router `redirect` function:
```dart
final onOrderComplete = state.uri.path.contains('/confirmation/');
if (status != AppStatus.connected && !onConnecting && !onOrderComplete) {
  return ConnectingPage.routeName;
}
```

### 🔧 Home Screen: Prevent OS Back from Exiting App

GoRouter places `/home` as the first real route; an OS-level swipe-back from the Home splash could close the app on some platforms. On a public kiosk, the app should never be exitable by customers.

**Resolution:** Wrap `HomeView`'s `Scaffold` in `PopScope(canPop: false)` to block OS-level back navigation, matching the pattern already used on mobile's Order Complete screen.

### 🔧 Post-"Add to Cart" Navigation Destination

Mobile's ItemDetailView navigates to `/home/menu/cart` on `added` status. The kiosk should navigate to `/home/menu/:groupId` instead — allowing customers to browse more items in the same category.

**Resolution:** `ItemDetailPage` passes `groupId` (extracted from route params) to `ItemDetailView`. The `BlocConsumer` listener uses `context.go('/home/menu/$groupId')` instead of `/home/menu/cart`.

```dart
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({required this.groupId, required this.itemId, super.key});

  final String groupId;  // ← required, unlike mobile_app
  final String itemId;
  ...
}
```

### 🔧 Reconnect After Connection Drop: Clear Current Order

When the WebSocket reconnects, the router redirects to `/home` (the splash). `OrderRepository._currentOrderId` persists in memory. A new customer who taps "Start Order" would unknowingly inherit the previous session's order ID.

**Resolution:** Drive the clear through `AppBloc`, not the router redirect. The router redirect is a pure routing function — side-effecting repository calls inside it are unpredictable and untestable. The fix: listen to `AppBloc` stream in `_AppViewState` and call `clearCurrentOrder()` when status transitions from `disconnected → connected`:

```dart
// In _AppViewState.initState or via BlocListener in App widget:
BlocListener<AppBloc, AppState>(
  listener: (context, state) {
    if (state.status == AppStatus.connected) {
      context.read<OrderRepository>().clearCurrentOrder();
    }
  },
  child: ...,
)
```

This fires on every reconnect (including initial connect — `clearCurrentOrder()` is a no-op when `_currentOrderId` is already null, so this is safe).

### 🔧 Checkout Button Disabled When Cart is Empty

The Cart's right-side summary panel persists even when items are removed. The "Proceed to Checkout" button must be disabled (or hidden) when `order == null || order.items.isEmpty`.

**Resolution:** In `_OrderSummaryPanel`, use `BlocSelector<CartBloc, CartState, bool>` to check `order.items.isEmpty` and pass `onPressed: null` to `BaseButton` when true.

### 🔧 Item Unavailable on Item Detail Screen

The Menu Items grid disables taps for unavailable items. But a customer already on Item Detail can have the item go unavailable via real-time menu WS update.

**Resolution:** In `ItemDetailView`, check `state.item?.available == false` in the build method and either:
- Disable the "Add to Cart" button with an inline "No longer available" message, or
- Auto-navigate back to menu items when `available` transitions to `false`

**Chosen approach:** Disable the "Add to Cart" button and show a small inline warning. Auto-navigating is jarring. The customer can back out manually.

### ℹ️ "Back to Menu" on Order Complete — Routed Through Bloc, Not View

`submitCurrentOrder()` already sets `_currentOrderId = null`. The `clearCurrentOrder()` call in the "Back to Menu" handler is technically a no-op by the time the customer reaches Order Complete. However, to maintain layer separation, the call goes through `OrderCompleteBloc` via a new `OrderCompleteBackToMenuRequested` event — no direct `context.read<OrderRepository>()` in the view. The bloc handler calls `clearCurrentOrder()` defensively and emits `navigatingBack`; the view listener then calls `context.go('/home/menu')`.

### ℹ️ Cart Badge Count = Total Quantity (Sum of Quantities)

`CartCountBloc` sums `item.quantity` across all line items. Two lattes (qty 2) + one muffin (qty 1) = badge shows "3".

---

## Alternative Approaches Considered

### A. Extract Shared Blocs into a Package

**Rejected.** Blocs are 20–40 lines each and diverge slightly between kiosk and mobile (e.g., different navigation targets, no HomeBloc on kiosk). A shared bloc package adds coordination overhead and risks coupling two apps that should evolve independently.

### B. Hoist CartBloc to MenuGroupsPage

**Rejected.** Providing full `CartBloc` at the parent level gives all menu screens access to cart mutations that are only needed in CartPage. `CartCountBloc` (proposed) is purpose-built, minimal, and doesn't leak cart write operations.

### C. Pass Cart Count as Route Extra

**Rejected.** CLAUDE.md prohibits `extra` parameters on routes. Cart count must come from state management.

---

## Acceptance Criteria

### Functional Requirements

- [ ] App locks to landscape orientation on launch
- [ ] Connection guard: shows `/connecting` until WebSocket connects; returns if connection drops
- [ ] Home: BG image + overlay + brand name + tagline + gold "Start Order" button renders
- [ ] Menu Groups: 3 category cards in equal-width horizontal row with cart badge in header
- [ ] Menu Items: 2-column grid; unavailable items show overlay and are non-interactive
- [ ] Item Detail: split pane; size/milk/extras selection; qty stepper (min 1); "Add to Cart" works
- [ ] Item Detail: after add, navigates back to `/home/menu/:groupId`
- [ ] Cart: split pane; qty stepper updates order; delete removes item; empty state shown when no items
- [ ] Cart: order summary shows correct subtotal, tax (8%), and grand total
- [ ] Checkout: fake payment card shown; "Place Order" submits and navigates to order complete
- [ ] Order Complete: success hero + live status tracker + order number + item list
- [ ] Order Complete "Back to Menu" clears current order and navigates to `/home/menu`
- [ ] Cart badge shows live item count on Menu Groups, Menu Items, Item Detail headers
- [ ] Back navigation: Menu Groups → `/home` (splash); all other screens → previous screen
- [ ] Item Detail "Add to Cart" navigates to `/home/menu/:groupId` (NOT to `/home/menu/cart`)
- [ ] Item Detail "Add to Cart" disabled with inline message when `item.available == false`
- [ ] Cart "Proceed to Checkout" button disabled when cart is empty
- [ ] Order Complete screen is NOT redirected to `/connecting` when WebSocket drops
- [ ] Home splash `PopScope(canPop: false)` prevents OS back gesture from exiting app
- [ ] Reconnection after disconnect clears stale `_currentOrderId` before redirecting to `/home`
- [ ] Router `cart` route is defined before `:groupId` route (prevents path conflict)

### Non-Functional Requirements

- [ ] `flutter analyze --fatal-infos` passes with zero issues
- [ ] All design tokens used (`context.colors.xxx`, `context.spacing.xxx`, `context.radius.xxx`, `context.typography.xxx`)
- [ ] No raw `Color(0xFF...)`, `Colors.xxx`, `EdgeInsets.fromLTRB`, or inline `TextStyle(fontFamily: ...)` in view code
- [ ] `public_member_api_docs: false` set in analysis_options.yaml
- [ ] `generate: true` and `uses-material-design: true` in pubspec.yaml flutter section

### Quality Gates

- [ ] Bloc unit tests written for all 8 Blocs (using `blocTest` + `mocktail`), covering success, failure, and edge-case states
- [ ] Widget tests written for all 8 view files, covering loading/success/failure/empty states
- [ ] `KioskHeader` widget test covers back button + cart badge variants
- [ ] `homeBackgroundOverlay` color token added to `AppColors` + `CoffeeTheme` before Phase 2 implementation
- [ ] No `context.read<OrderRepository>()` calls anywhere in view files
- [ ] GitHub Actions CI passes after `.github/update_github_actions.sh` is run

---

## Dependencies & Prerequisites

### Existing packages (no changes needed)

| Package | Used by |
|---|---|
| `shared/api_client` | `main.dart` (ApiClient, WsRpcClient) |
| `shared/connection_repository` | AppBloc |
| `shared/menu_repository` | MenuGroupsBloc, MenuItemsBloc, ItemDetailBloc |
| `shared/order_repository` | ItemDetailBloc, CartBloc, CheckoutBloc, OrderCompleteBloc, CartCountBloc |
| `shared/very_yummy_coffee_ui` | Theme, design tokens, BaseButton, CustomBackButton, OrderStepTracker |

### External packages (same versions as mobile_app)

```yaml
bloc: ^9.0.0
dart_mappable: ^4.6.1
flutter_bloc: ^9.1.1
go_router: ^14.6.2
intl: ^0.20.2
rxdart: ^0.28.0
```

---

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Cart badge count goes stale if CartCountBloc subscription drops | Low | Medium | `emit.forEach` auto-reconnects; same pattern used in all blocs |
| Stale `_currentOrderId` after reconnect visible to new customer | Low | High | `BlocListener` on `AppBloc` in `_AppView` clears order on every `connected` state |
| Landscape lock breaks on Android tablet | Low | Medium | Test on Android emulator; `SystemChrome.setPreferredOrientations` is the standard approach |
| Router `:groupId` vs `cart` path conflict | Low (if ordered correctly) | High | Cart route defined before `:groupId`; inline comment in router explains ordering requirement |
| `context.read` inside builder for group title doesn't rebuild | Eliminated | N/A | Replaced with `BlocSelector<MenuGroupsBloc, ...>` which is reactive |

---

## Future Considerations

- **Idle timeout / auto-reset**: Return to `/home` splash after N minutes of inactivity. Can be added later with a `Timer` in `HomeView` or `AppBloc`.
- **Real payment integration**: Swap `_FakePaymentCard` for a real payment terminal widget.
- **Kiosk-only menu items**: If the backend adds a `kioskOnly` flag to `MenuItem`, filter in `MenuItemsBloc`.
- **Accessibility**: Large touch targets are already enforced by the 64px back button and pill buttons. Semantic labels for screen readers can be added later.
- **Animations**: Page transition animations (hero animation on item detail, fade on cart) can be added without architectural changes.

---

## References & Research

### Internal References

- Mobile app architecture (pattern source): [`applications/mobile_app/lib/`](applications/mobile_app/lib/)
- AppBloc pattern: [`applications/mobile_app/lib/app/bloc/app_bloc.dart`](applications/mobile_app/lib/app/bloc/app_bloc.dart)
- AppRouter pattern: [`applications/mobile_app/lib/app/app_router/app_router.dart`](applications/mobile_app/lib/app/app_router/app_router.dart)
- Analysis options reference: [`applications/mobile_app/analysis_options.yaml`](applications/mobile_app/analysis_options.yaml)
- AppColors design tokens: [`shared/very_yummy_coffee_ui/lib/src/colors/app_colors.dart`](shared/very_yummy_coffee_ui/lib/src/colors/app_colors.dart)
- Kiosk screen designs: `design.pen` (frames prefixed "Kiosk —")
- Brainstorm document: [`docs/ideate/2026-03-05-kiosk-app-brainstorm-doc.md`](docs/ideate/2026-03-05-kiosk-app-brainstorm-doc.md)

### Related Plans

- POS app (sister app): [`docs/plan/2026-03-03-feat-pos-app-plan.md`](docs/plan/2026-03-03-feat-pos-app-plan.md)
- KDS app: [`docs/plan/2026-03-02-feat-implement-kds-kitchen-display-app-plan.md`](docs/plan/2026-03-02-feat-implement-kds-kitchen-display-app-plan.md)
