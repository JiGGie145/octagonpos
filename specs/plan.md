# Implementation Plan — Offline-First POS

**Started:** 3 March 2026  
**Stack:** Flutter, Drift, Riverpod, GoRouter  
**Design:** Tablet-first, 2-panel layout (product grid + order panel)  
**Currency storage:** Integer (cents)

---

## Phase 1: Project Foundations

- [x] Update SDK constraint in `pubspec.yaml` to Dart 3+ / Flutter 3.x
- [x] Remove unused dependencies (`flutter_bloc`, `equatable`, old `go_router` v3, `flutter_lints`)
- [x] Add core dependencies: `flutter_riverpod`, `riverpod_annotation`, `go_router` (latest)
- [x] Add database dependencies: `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`
- [x] Add utility dependencies: `uuid`, `intl`
- [x] Add printer dependencies: `printing` (desktop), `blue_thermal_printer` (Android)
- [x] Add dev dependencies: `drift_dev`, `build_runner`, `riverpod_generator`, `flutter_lints` replacement (`flutter_lints` → `lints` or `very_good_analysis`)
- [x] Run `flutter pub get` and resolve any version conflicts
- [x] Run `dart fix --apply` to address Dart 3 migration issues

## Phase 2: Folder Structure

- [x] Create `lib/core/theme/` (app_theme, app_colors, app_typography, app_spacing)
- [x] Create `lib/core/utils/`
- [x] Create `lib/core/constants/`
- [x] Create `lib/core/errors/`
- [x] Create `lib/core/router/`
- [x] Create `lib/domain/entities/`
- [x] Create `lib/domain/repositories/`
- [x] Create `lib/domain/enums/`
- [x] Create `lib/application/usecases/`
- [x] Create `lib/application/services/`
- [x] Create `lib/data/models/`
- [x] Create `lib/data/database/`
- [x] Create `lib/data/repositories/`
- [x] Create `lib/data/mappers/`
- [x] Create `lib/presentation/screens/`
- [x] Create `lib/presentation/widgets/`
- [x] Create `lib/presentation/providers/`

## Phase 3: Theme & Design System

Based on the Figma design: light background (`#F5F5F5`), white product cards, blue accent for active filters and prices, clean typography, 2-panel layout.

- [x] Create `app_colors.dart` — define all colors centrally:
  - Primary: blue (active filter pill, price text)
  - Surface: white (cards, order panel)
  - Background: light gray `#F5F5F5`
  - Error/delete: red (trash icon, cancel)
  - Success: green (paid status)
  - Warning: amber/orange (pending, "In Progress" badge)
  - Text primary: dark/black
  - Text secondary: gray
  - Border: light gray
  - Disabled: muted gray
  - Order status color map: pending→warning, paid→success, completed→primary, cancelled→error
- [x] Create `app_spacing.dart` — define spacing scale:
  - `xs`: 4, `sm`: 8, `md`: 16, `lg`: 24, `xl`: 32, `xxl`: 48
- [x] Create `app_typography.dart` — define text theme using Material 3 TextTheme scales, no hardcoded font sizes in widgets
- [x] Create `app_theme.dart` — assemble `ThemeData`:
  - `AppTheme.light()` with white cards, light gray background, blue accent
  - `AppTheme.dark()` (stubbed for future, based on existing dark prototype `RGB(17,19,21)`)
  - Centralized button themes (min height 48px for POS touch targets)
  - Card theme, input decoration theme, app bar theme
  - Chip/filter pill theme (for category filters)
- [x] Update `main.dart` to use `AppTheme.light()` / `AppTheme.dark()`

## Phase 4: Domain Layer (Pure Dart, No Flutter Imports)

- [x] Create `domain/enums/order_status.dart` — `pending`, `paid`, `completed`, `cancelled`
- [x] Create `domain/enums/payment_method.dart` — `cash`, `card`
- [x] Create `domain/enums/sync_status.dart` — `pending`, `synced`, `failed` (future-proof)
- [x] Create `domain/entities/product.dart` — `localId` (UUID), `name`, `price` (int, cents), `category`, `isActive`, `imageUrl` (nullable), `createdAt`, `updatedAt`, `deletedAt`, `syncStatus`
- [x] Create `domain/entities/order.dart` — `localId`, `orderNumber`, `items` (list), `status`, `note`, `createdAt`, `updatedAt`, `deletedAt`, `syncStatus`
- [x] Create `domain/entities/order_item.dart` — `localId`, `orderId`, `productId`, `productName`, `quantity`, `unitPrice` (int, cents)
- [x] Create `domain/entities/payment.dart` — `localId`, `orderId`, `method`, `amount` (int, cents), `createdAt`
- [x] Create `domain/entities/business_settings.dart` — `businessName`, `currency`, `currencySymbol`, `taxPercentage` (int, basis points or simple int), `receiptFooter`
- [x] Create `domain/repositories/product_repository.dart` — interface with `getAll`, `getById`, `getByCategory`, `create`, `update`, `softDelete`
- [x] Create `domain/repositories/order_repository.dart` — interface with `getAll`, `getById`, `create`, `update`, `updateStatus`, `softDelete`
- [x] Create `domain/repositories/payment_repository.dart` — interface with `create`, `getByOrderId`
- [x] Create `domain/repositories/settings_repository.dart` — interface with `get`, `save`

## Phase 5: Data Layer (Drift Database)

- [x] Create `data/database/app_database.dart` — Drift database class with schema v1
- [x] Create `data/database/tables/products_table.dart` — columns: `local_id` (text PK, UUID), `name`, `price` (integer, cents), `category`, `is_active` (bool), `image_url` (nullable text), `created_at`, `updated_at`, `deleted_at` (nullable), `sync_status`
- [x] Create `data/database/tables/orders_table.dart` — columns: `local_id`, `order_number` (integer, auto-increment), `status`, `note` (nullable), timestamps, `sync_status`
- [x] Create `data/database/tables/order_items_table.dart` — columns: `local_id`, `order_id` (FK), `product_id` (FK), `product_name`, `quantity`, `unit_price` (integer, cents), timestamps
- [x] Create `data/database/tables/payments_table.dart` — columns: `local_id`, `order_id` (FK), `method`, `amount` (integer, cents), `created_at`
- [x] Create `data/database/tables/settings_table.dart` — columns: `id` (single row), `business_name`, `currency`, `currency_symbol`, `tax_percentage`, `receipt_footer`
- [x] Create DAOs: `ProductDao`, `OrderDao`, `OrderItemDao`, `PaymentDao`, `SettingsDao`
- [x] Run `dart run build_runner build` to generate Drift code
- [x] Create `data/mappers/product_mapper.dart` — DB model ↔ domain entity
- [x] Create `data/mappers/order_mapper.dart` — DB model ↔ domain entity
- [x] Create `data/mappers/payment_mapper.dart` — DB model ↔ domain entity
- [x] Create `data/mappers/settings_mapper.dart` — DB model ↔ domain entity
- [x] Create `data/repositories/drift_product_repository.dart` — implements domain `ProductRepository`
- [x] Create `data/repositories/drift_order_repository.dart` — implements domain `OrderRepository`
- [x] Create `data/repositories/drift_payment_repository.dart` — implements domain `PaymentRepository`
- [x] Create `data/repositories/drift_settings_repository.dart` — implements domain `SettingsRepository`

## Phase 6: Application Layer (Use Cases)

- [x] Create `application/usecases/product/create_product.dart`
- [x] Create `application/usecases/product/update_product.dart`
- [x] Create `application/usecases/product/delete_product.dart` (soft delete)
- [x] Create `application/usecases/product/get_products.dart` (exclude soft-deleted)
- [x] Create `application/usecases/order/create_order.dart`
- [x] Create `application/usecases/order/update_order_status.dart`
- [x] Create `application/usecases/order/get_orders.dart` (exclude soft-deleted)
- [x] Create `application/usecases/order/get_order_detail.dart`
- [x] Create `application/usecases/payment/process_payment.dart`
- [x] Create `application/services/printer_service.dart` — abstract `PrinterService`
- [x] Create `application/services/desktop_printer_service.dart`
- [x] Create `application/services/bluetooth_printer_service.dart`
- [x] Create `application/services/receipt_template.dart` — formats receipt content

## Phase 7: State Management (Riverpod Providers)

- [x] Create `presentation/providers/database_provider.dart` — singleton DB instance
- [x] Create `presentation/providers/repository_providers.dart` — provides all repo instances
- [x] Create `presentation/providers/product_providers.dart` — product list, filtered by category, search
- [x] Create `presentation/providers/order_providers.dart` — order list, current order (cart state)
- [x] Create `presentation/providers/cart_provider.dart` — manages current order: add item, remove item, update quantity, clear, calculate totals (subtotal, tax, total in cents)
- [x] Create `presentation/providers/settings_provider.dart` — business settings state
- [x] Wrap `main.dart` with `ProviderScope`

## Phase 8: UI — Order Screen (Primary Screen, Tablet-First)

This is the main screen matching the Figma design: 2-panel layout with product browsing on the left and current order on the right.

### Shared Utility
- [x] Create `core/utils/currency_formatter.dart` — shared `formatCurrency(int cents, String symbol)` helper used by all price-displaying widgets (e.g. `formatCurrency(3500, 'R')` → `"R35.00"`)

### Left Panel — Product Browsing
- [x] Create `presentation/screens/order_screen.dart` — main `ConsumerWidget` scaffold with responsive `Row` layout (uses `LayoutBuilder`): left `Expanded` panel + right fixed-width (`380px`) order panel
- [x] Create `presentation/widgets/product_search_bar.dart` — rounded search field updating `productSearchQueryProvider`, matching Figma style (rounded, light gray fill)
- [x] Create `presentation/widgets/category_filter_chips.dart` — horizontal scrollable row of filter chips watching `categoryListProvider`, toggling `selectedCategoryProvider`; blue fill for active, outlined for inactive
- [x] Create `presentation/widgets/product_grid.dart` — `GridView.builder` with adaptive cross-axis count watching `filteredProductListProvider`, grouped by category with section headers
- [x] Create `presentation/widgets/product_card.dart` — white rounded card with optional image placeholder (icon fallback), product name, price via `formatCurrency()`, tap calls `cartProvider.notifier.addProduct()`

### Right Panel — Current Order
- [x] Create `presentation/widgets/order_panel.dart` — fixed-width column reading from `cartProvider`: order header + scrollable line items + totals + actions
- [x] Create `presentation/widgets/order_header.dart` — order number (#1998), status badge ("In Progress" in colored pill), "Add Note" button
- [x] Create `presentation/widgets/order_line_item.dart` — product name, unit price via `formatCurrency()`, quantity stepper (− / count / +), line total, delete (trash) icon button
- [x] Create `presentation/widgets/order_totals.dart` — subtotal, tax (percentage from `settingsProvider`), total (bold, large), all formatted via `formatCurrency()`
- [x] Create `presentation/widgets/order_actions.dart` — "CLEAR" button (outlined/gray) + "PAY" button (filled blue, prominent), both large touch-friendly (48px+ height)

### Empty States
- [x] Product grid shows "No products yet — add products to get started" illustration/message when product list is empty
- [x] Order panel shows "Add items to get started" message when cart is empty, with PAY button disabled

### Responsive Behavior
- [x] On tablets/desktop (≥768px): show 2-panel side-by-side layout
- [x] On phones (<768px): show product grid full-screen with a cart summary badge/FAB; tapping opens order panel as a bottom sheet

## Phase 9: UI — Product Management Screen

- [x] Create `presentation/screens/product_list_screen.dart` — searchable list/grid of all products with edit/delete actions
- [x] Create `presentation/widgets/product_form_dialog.dart` — add/edit dialog: name (text), price (number input, stored as cents), category (dropdown), active toggle
- [x] Wire product CRUD to Riverpod providers and use cases
- [x] Implement soft delete with confirmation dialog (no archive page, just hide deleted)

## Phase 10: UI — Settings & First-Run Setup

- [x] Create `presentation/screens/setup_wizard_screen.dart` — first-run form: business name (required), currency + symbol (required), tax percentage (required, default 15%), receipt footer (optional)
- [x] Create `presentation/screens/settings_screen.dart` — edit all business settings fields, same form as setup but pre-populated
- [x] Add settings persistence via `SettingsRepository` + Riverpod
- [x] On app start: check if settings exist → if not, redirect to setup wizard

## Phase 11: UI — Order Detail & Status Management

- [x] Create `presentation/screens/order_detail_screen.dart` — full order view: line items, totals, payment info, timestamps
- [x] Add status update buttons: mark as Paid, Completed, Cancelled (with color-coded status badge)
- [x] Add "Print Receipt" button wired to `PrinterService`
- [x] Create `presentation/screens/order_history_screen.dart` — list of past orders, filterable by status, excludes soft-deleted

## Phase 12: UI — Payment Flow

- [x] Create `presentation/widgets/payment_dialog.dart` — modal/bottom sheet: shows order summary, payment method selection (Cash / Card with large buttons), confirm payment action
- [x] On payment confirmation: create `Payment` record, update order status to `Paid`, close dialog, optionally trigger receipt print
- [x] Format all amounts from cents using shared `formatCurrency()` helper and business settings from `settingsProvider`

## Phase 13: Navigation & Routing

- [x] Create `core/router/app_router.dart` with GoRouter:
  - `/` → Order screen (default/home)
  - `/products` → Product management
  - `/orders` → Order history
  - `/orders/:id` → Order detail
  - `/settings` → Settings
  - `/setup` → First-run wizard
- [x] Add redirect guard: if no settings exist → force `/setup`
- [x] Wire navigation: `NavigationRail` for tablet/desktop (Orders, Products, Settings), `BottomNavigationBar` for mobile

## Phase 14: Receipt Printing

- [x] Create receipt template: business name, date/time, order number, line items (name × qty, price), subtotal, tax, total, payment method, receipt footer
- [x] Implement `DesktopPrinterService` using `printing` package (PDF generation → system print dialog)
- [x] Implement `BluetoothPrinterService` using `blue_thermal_printer` (ESC/POS commands for Android thermal printers)
- [x] Add printer selection/configuration in settings screen

## Phase 15: Testing

- [x] Write Drift migration tests: verify v1 schema creates correctly, all tables exist with correct columns
- [x] Write domain entity unit tests: `Order` total calculation, status transitions
- [x] Write use case unit tests: `CreateOrderUseCase`, `ProcessPaymentUseCase` with mocked repositories
- [x] Write integration test: full order flow (create product → add to cart → process payment → verify in DB)
- [x] Verify app launch < 2s, order creation < 300ms

## Phase 16: Cleanup & Polish

- [x] Delete `lib/pages/home.dart` (old prototype)
- [x] Add loading indicators for async DB operations
- [x] Add empty states (no products yet, no orders yet)
- [x] Add error handling UI (snackbars for failures)
- [x] Verify all widgets use theme tokens only — zero hardcoded colors, font sizes, padding
- [x] Verify soft-deleted orders are hidden from all list views
- [x] Final responsive layout pass: test on tablet, phone, and desktop window sizes

---

## Decisions Log

| Decision | Choice | Rationale |
|---|---|---|
| Database | Drift (SQLite) | Maximum SQL control, strong migration support, sync-ready |
| State management | Riverpod | Scales well, clear DI, easy testing, no heavy boilerplate |
| Price storage | Integer (cents) | Avoids floating-point precision errors |
| UI approach | Tablet-first | Primary use case is tablet POS, responsive down to phone |
| Soft deletes | Hide only, no archive page | MVP simplicity — deleted records are just filtered from queries |
| Design reference | Figma screenshot | Light theme, 2-panel layout, blue accent, white cards |
| Currency formatting | Shared `formatCurrency()` in `core/utils/` | Single source of truth for cents → display string conversion |
