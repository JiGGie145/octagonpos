# Project Guidelines

**Authoritative references:**
- Architecture: [specs/technical-architecture.md](../specs/technical-architecture.md)
- Inventory & reporting feature spec: [specs/Inventory + Reporting + Data Export Requirements.md](../specs/Inventory%20+%20Reporting%20+%20Data%20Export%20Requirements.md)
- Inventory UI spec: [specs/inventory_ui_reqs.md](../specs/inventory_ui_reqs.md)
- Implementation plan: [specs/plan.md](../specs/plan.md)

---

## Commands

```bash
# Run all tests
flutter test

# Regenerate Drift + Riverpod code after schema/annotation changes
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

**Never edit `*.g.dart` files** — they are auto-generated and will be overwritten.  
Run `build_runner` any time you add or change a Drift table, add `part` directives, or modify `@riverpod` annotations.

---

## Architecture

Dependency flow: **Presentation → Application → Domain → Data**. See [specs/technical-architecture.md](../specs/technical-architecture.md) for full layer responsibilities.

- Do not let UI code access the database directly.
- Do not put SQL, persistence logic, or business rules inside widgets.
- Keep the domain layer pure Dart — no Flutter or database imports.
- Keep repositories behind interfaces (`domain/repositories/`) so the data layer can be replaced.
- Prefer simple, maintainable MVP solutions over premature abstraction.

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Use case classes | `PascalCase`, no suffix | `CreateOrder`, `GetProducts` |
| Use case files | `snake_case.dart` | `create_order.dart` |
| Repository implementations | `Drift{Entity}Repository` | `DriftProductRepository` |
| Drift table classes | `{Entities}Table` (plural) | `ProductsTable` |
| Riverpod providers | `{action}{Entity}[UseCase]Provider` | `createProductUseCaseProvider`, `productListProvider` |
| Screen widgets | `{Name}Screen` | `OrderHistoryScreen` |
| Dialog widgets | `show{Name}Dialog()` function + `_{Name}Content` private widget | `showPaymentDialog()` |

---

## File Placement

```
lib/application/usecases/{domain}/   ← use case per domain (order/, product/, payment/, inventory/, reporting/)
lib/application/services/           ← abstract + concrete service implementations
lib/data/database/tables/           ← one file per Drift table
lib/data/mappers/                   ← one mapper per entity
lib/data/repositories/              ← Drift implementations
lib/domain/entities/                ← pure Dart entities
lib/domain/enums/                   ← pure Dart enums
lib/domain/repositories/            ← abstract repository interfaces
lib/presentation/providers/         ← Riverpod providers (group by feature)
lib/presentation/screens/           ← one file per screen
lib/presentation/widgets/           ← shared/reusable widgets
lib/core/router/app_router.dart     ← all routes and route guard
lib/core/theme/                     ← AppTheme, AppColors, AppSpacing, AppTypography
test/                               ← mirror lib/ structure
test/mocks/                         ← shared mock implementations
```

---

## Data Conventions

- **All monetary values are `int` (cents).** `3500` = $35.00. Never use `double` for money. Tax: `(subtotal * taxPct) ~/ 100`.
- **Soft-delete is mandatory** for orders and products. Set `deletedAt = DateTime.now()`. Never `DELETE`. Queries always filter `where((t) => t.deletedAt.isNull())`.
- **Every table must have** `localId` (UUID), `createdAt`, `updatedAt`, `deletedAt` (nullable), `syncStatus` (TEXT, default `'pending'`). This is required for future sync.
- **`localId` is a UUID** generated with `const Uuid().v4()`. `orderNumber` is auto-increment for display only (e.g., `#1234`).
- **`syncStatus`** values: `pending`, `synced`, `failed`. Parse via `SyncStatus.fromString(row.syncStatus)`.
- Stock quantities are `double` (supports fractional units like kg, L).
- Cost prices are `int` (cents), consistent with product prices.

---

## Database Migrations

- Schema version is in `lib/data/database/app_database.dart` → `int get schemaVersion`.
- **Current version: 1.** Bump to 2 for the inventory feature branch.
- Add migration logic inside `onUpgrade: (m, from, to) async { if (from < 2) { ... } }`.
- Use `m.addColumn(table, column)` for new columns — never `DROP` or `CREATE TABLE` on existing tables.
- Write a migration test in `test/data/database/` before shipping any schema change.

---

## Offline-First And Data Rules

- Maintain offline-first behavior in all features.
- Do not introduce changes that could wipe local data, reset settings, or break order history.
- Keep future sync readiness in mind: timestamped records, replaceable repositories, conflict-friendly data modeling.

---

## State Management

- Use Riverpod for state management and dependency injection.
- `StateNotifier<State>` for mutable local state (e.g., cart, form state).
- `FutureProvider` for async data from repositories.
- `Provider` for use case instances — inject repositories via `ref.watch(xRepositoryProvider)`.
- Keep state logic in notifiers/providers, not in widget `build()` methods.
- Invalidate stale providers after mutations: `ref.invalidate(productListProvider)`.

---

## Adding a New Route / Tab

1. Add a `static const` route path to `AppRoutes` in `lib/core/router/app_router.dart`.
2. Add a `GoRoute` inside the `ShellRoute.routes` list (or as a nested route).
3. Use `NoTransitionPage` as the `pageBuilder` for top-level tabs to prevent animation.
4. Add a `_Destination` entry to the `_destinations` list in `lib/presentation/widgets/app_shell.dart`.
5. Create the screen widget in `lib/presentation/screens/`.

Navigation: `context.go(AppRoutes.x)` for tabs, `context.push(...)` for detail screens.

---

## Mappers Are Required

Domain entities must never expose Drift row types. All Drift ↔ Domain conversion goes through a mapper in `lib/data/mappers/`:

```dart
// toDomain: Drift row → domain entity
static Product toDomain(ProductRow row) { ... }

// toCompanion: domain entity → Drift companion for insert/update
static ProductsCompanion toCompanion(Product entity) { ... }
```

---

## Cart

- Cart state lives in `lib/presentation/providers/cart_provider.dart`.
- **Cart does NOT auto-clear after order creation.** UI must call `ref.read(cartProvider.notifier).clear()` explicitly after a successful payment.

---

## UI And Theming

- Do not hardcode colors, font sizes, spacing, or button styles inside widgets.
- Use `AppColors`, `AppSpacing`, `AppTypography` from `lib/core/theme/`.
- Responsive breakpoint: `AppSpacing.tabletBreakpoint` (768px). Use `LayoutBuilder` to switch layouts.
- POS buttons must have a minimum tap target of `AppSpacing.minTapTarget` (48px).
- Status color mapping lives in `AppColors.orderStatusColor(status)` — do not define it inline.

---

## Testing

- Mirror `lib/` structure under `test/`.
- Shared mocks go in `test/mocks/`. Implement the repository interface, track calls with a `callLog` list.
- Test use cases by injecting mock repositories; assert both return value and `callLog`.
- Use `setUp()` with `late` variables; use helper factory functions (`makeProduct()`, `makeOrder()`).
- Always add a migration test when bumping `schemaVersion`.

---

## Decision Filter

Before implementing a feature:
1. Does this break offline-first operation?
2. Does this tightly couple UI and data?
3. Does this add unnecessary complexity?
4. Is this outside MVP scope?

If yes → prefer a simpler approach aligned with [specs/technical-architecture.md](../specs/technical-architecture.md).