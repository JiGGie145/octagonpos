# Plan: Inventory, Reporting & Data Export

## TL;DR
Implement inventory tracking (optional, non-blocking), cost/profit engine, dashboard, reporting module, and data export/backup — delivered across 7 independently verifiable phases. UI-first approach: each phase delivers visible UI backed by the minimum necessary data layer changes.

## Decisions
- **Order status flow:** Pending → Paid → Completed (stock deducts on Completed only)
- **Stock quantities:** Decimal (`double` in Dart, `REAL` in Drift) to support fractional units (kg, L, etc.)
- **Excel export:** `syncfusion_flutter_xlsio` package
- **Navigation:** 5 tabs — POS, Orders, Dashboard (with Reports nested inside), Products, Settings
- **Delivery:** Full plan, phased — each phase independently shippable and verifiable
- **Prices remain int (cents):** cost_price stored as int (cents) consistent with existing price handling

---

## Phase 1: Data Foundation — Schema Migration & Domain Updates
*All subsequent phases depend on this.*

### [x] Step 1.1: Database Migration (v1 → v2)
- **File:** `lib/data/database/app_database.dart` — bump `schemaVersion` to 2, add `onUpgrade` migration
- **New columns on `products` table:**
  - `track_stock` (BOOLEAN, default false)
  - `uses_ingredients` (BOOLEAN, default false)
  - `stock_qty` (REAL, nullable)
  - `low_stock_threshold` (REAL, nullable)
  - `cost_price` (INTEGER, nullable — cents)
  - `is_sellable` (BOOLEAN, default true)
- **New columns on `order_items` table:**
  - `cost_snapshot_total` (INTEGER, nullable — cents)
  - `revenue_snapshot_total` (INTEGER)
- **File:** `lib/data/database/tables/products_table.dart` — add new column definitions
- **File:** `lib/data/database/tables/order_items_table.dart` — add new column definitions

### [x] Step 1.2: New Tables
- **New file:** `lib/data/database/tables/recipe_items_table.dart`
  - Columns: localId, productId (FK→products), ingredientProductId (FK→products), quantityRequired (REAL), createdAt, updatedAt
- **New file:** `lib/data/database/tables/restock_entries_table.dart`
  - Columns: localId, productId (FK→products), quantityAdded (REAL), unitCost (INTEGER nullable, cents), totalCost (INTEGER nullable, cents), date (DATETIME), notes (TEXT nullable), createdAt, updatedAt
- **New file:** `lib/data/database/tables/stock_adjustments_table.dart`
  - Columns: localId, productId (FK→products), quantityChange (REAL), reason (TEXT nullable), date (DATETIME), createdAt, updatedAt
- Register all new tables in `AppDatabase` `@DriftDatabase(tables: [...])` annotation

### [x] Step 1.3: Domain Entity Updates
- **File:** `lib/domain/entities/product.dart` — add fields: `trackStock`, `usesIngredients`, `stockQty`, `lowStockThreshold`, `costPrice`, `isSellable`; update `copyWith()`
- **File:** `lib/domain/entities/order_item.dart` — add fields: `costSnapshotTotal`, `revenueSnapshotTotal`; update `copyWith()`
- **New file:** `lib/domain/entities/recipe_item.dart` — entity with: localId, productId, ingredientProductId, quantityRequired
- **New file:** `lib/domain/entities/restock_entry.dart` — entity with: localId, productId, quantityAdded, unitCost, totalCost, date, notes
- **New file:** `lib/domain/entities/stock_adjustment.dart` — entity with: localId, productId, quantityChange, reason, date

### [ ] Step 1.4: Repository Interfaces
- **File:** `lib/domain/repositories/product_repository.dart` — add: `getSellableProducts()`, `getIngredients()`, `getAllIncludingIngredients()`, `updateStock(localId, newQty)`
- **New file:** `lib/domain/repositories/recipe_repository.dart` — interface: `getByProductId()`, `create()`, `update()`, `deleteByProductId()`, `getIngredientsForProduct()`
- **New file:** `lib/domain/repositories/restock_repository.dart` — interface: `create()`, `getByProductId()`, `delete()`, `getByDateRange()`
- **New file:** `lib/domain/repositories/stock_adjustment_repository.dart` — interface: `create()`, `getByProductId()`, `getByDateRange()`

### [x] Step 1.5: Mappers & Data Layer Implementations
- **File:** `lib/data/mappers/product_mapper.dart` — map new fields
- **File:** `lib/data/mappers/order_mapper.dart` — map cost/revenue snapshot fields
- **New files:** `lib/data/mappers/recipe_item_mapper.dart`, `restock_entry_mapper.dart`, `stock_adjustment_mapper.dart`
- **New files:** `lib/data/repositories/drift_recipe_repository.dart`, `drift_restock_repository.dart`, `drift_stock_adjustment_repository.dart`
- **File:** `lib/data/repositories/drift_product_repository.dart` — implement new methods

### [x] Step 1.6: Run `build_runner` to regenerate Drift code

### [ ] Step 1.7: Provider Registration
- **File:** `lib/presentation/providers/repository_providers.dart` — add providers for new repositories
- **New file:** `lib/presentation/providers/inventory_providers.dart` — use case and state providers for inventory features

**Verification Phase 1:**
- [ ] Migration test: v1 → v2 upgrades without data loss (existing products/orders preserved)
- [ ] Unit tests for new entities (recipe_item, restock_entry, stock_adjustment)
- [ ] Unit tests for updated Product entity (new fields, copyWith, defaults)
- [x] App builds and existing functionality unchanged
- [ ] `flutter test` passes

---

## Phase 2: Product Form & Inventory UI
*Depends on Phase 1.*

### Step 2.1: Update Product Form Dialog
- **File:** `lib/presentation/widgets/product_form_dialog.dart`
  - Add `Track Stock` toggle switch
  - When ON: reveal `Current Stock`, `Low Stock Threshold`, `Cost Price` fields
  - Add `is_sellable` toggle (for ingredients that aren't sold directly)
  - When `Track Stock` ON: reveal `Uses Ingredients` toggle
  - Conditionally show recipe builder (Phase 3 placeholder — disable for now)
- **File:** `lib/application/usecases/product/create_product.dart` — accept new fields
- **File:** `lib/application/usecases/product/update_product.dart` — accept new fields

### Step 2.2: Products Screen Segmented Control
- **File:** `lib/presentation/screens/product_list_screen.dart`
  - Add top segmented control: "Sellable" | "Ingredients" | "All"
  - Filter products based on `isSellable` flag
  - Show stock qty badge on tracked products
  - Show low stock warning indicator (⚠)

### Step 2.3: Stock List Screen (new)
- **New file:** `lib/presentation/screens/stock_list_screen.dart`
  - Columns: Product, Stock Qty, Cost Price, Stock Value, Low Stock indicator
  - Only shows products where `trackStock = true`
  - Row tap → Stock Detail screen
  - Empty state: "Enable stock tracking on products"
- **Route:** Add `/inventory` route to `app_router.dart`

### Step 2.4: Stock Detail Screen (new)
- **New file:** `lib/presentation/screens/stock_detail_screen.dart`
  - Current stock card (qty, value, cost price, low stock status)
  - Movement history list (restocks + adjustments chronological)
  - Buttons: "Restock" and "Adjust Stock"
- **Route:** Add `/inventory/:productId` route

### Step 2.5: Restock Dialog
- **New file:** `lib/presentation/widgets/restock_dialog.dart`
  - Fields: Quantity Added, Unit Cost (optional), Notes (optional)
  - Primary button: "Add Stock"
  - On save: create RestockEntry + update product.stockQty
- **New use case:** `lib/application/usecases/inventory/add_restock.dart`

### Step 2.6: Stock Adjustment Dialog
- **New file:** `lib/presentation/widgets/stock_adjustment_dialog.dart`
  - Fields: Quantity Change (+/−), Reason (optional)
  - Primary button: "Adjust Stock"
  - On save: create StockAdjustment + update product.stockQty
- **New use case:** `lib/application/usecases/inventory/adjust_stock.dart`

### Step 2.7: Low Stock Indicators
- **File:** `lib/presentation/widgets/product_card.dart` — show ⚠ badge when stock ≤ threshold
- **File:** `lib/presentation/screens/product_list_screen.dart` — show indicator in list rows
- **File:** `lib/presentation/screens/stock_list_screen.dart` — highlight low stock rows
- **New provider:** `lowStockProductsProvider` in inventory_providers.dart — global setting for default threshold (can be in settings or hardcoded MVP default of 5)

**Verification Phase 2:**
- [ ] Can add/edit a product with trackStock=true and see stock fields
- [ ] Can toggle isSellable for ingredient products
- [ ] Stock list shows only tracked products with correct values
- [ ] Can restock a product and see qty increase
- [ ] Can adjust stock and see qty change
- [ ] Low stock ⚠ appears on products at/below threshold
- [ ] Stock detail shows movement history
- [ ] Empty states display correctly

---

## Phase 3: Recipe/Ingredient System
*Depends on Phase 2. Parallel with Phase 4.*

### Step 3.1: Recipe Builder UI
- **File:** `lib/presentation/widgets/product_form_dialog.dart`
  - When `Uses Ingredients` toggle ON → show recipe builder section
  - List of ingredient rows: ingredient dropdown (filtered to trackStock=true products), quantity field
  - "Add Ingredient" button
  - Remove ingredient button per row
- **New provider:** recipe items state management in inventory_providers.dart

### Step 3.2: Recipe Use Cases
- **New file:** `lib/application/usecases/inventory/manage_recipe.dart`
  - Save recipe items when product is created/updated
  - Delete old recipe items and replace on update
  - Validate: ingredient cannot be the product itself

### Step 3.3: Recipe Cost Calculation
- Add computed property or utility: calculate recipe cost from ingredient cost_prices
- Display estimated cost on product form when recipe is defined

**Verification Phase 3:**
- [ ] Can create a recipe product with multiple ingredients
- [ ] Can edit recipe (add/remove ingredients)
- [ ] Recipe cost calculates correctly from ingredient costs
- [ ] Cannot add a product as its own ingredient

---

## Phase 4: Stock & Cost Engine (Business Logic)
*Depends on Phase 1. Parallel with Phase 3.*

### Step 4.1: Stock Deduction on Order Completion
- **File:** `lib/application/usecases/order/update_order_status.dart`
  - When status changes to `completed`:
    - For each order item where product has `trackStock=true`:
      - If product `usesIngredients`: deduct ingredient stock (recipe qty × order qty)
      - Else: deduct product.stockQty by order item quantity
    - Allow negative stock (no blocking)
  - Inject `ProductRepository` and `RecipeRepository` as new dependencies

### Step 4.2: Stock Return on Cancellation
- **File:** `lib/application/usecases/order/update_order_status.dart`
  - When cancelling a `completed` order: reverse stock deductions
  - When cancelling a `pending` or `paid` order: no stock effect

### Step 4.3: COGS Snapshot on Completion
- **File:** `lib/application/usecases/order/update_order_status.dart`
  - When status changes to `completed`:
    - For each order item: snapshot cost_snapshot_total and revenue_snapshot_total
    - Simple product: `cost_snapshot_total = product.costPrice * qty`
    - Recipe product: `cost_snapshot_total = SUM(ingredient.qtyRequired * ingredient.costPrice)`
    - `revenue_snapshot_total = unitPrice * qty`
    - Update order items in DB with snapshot values
  - Never recalculate historical orders

### Step 4.4: Restock Cost Price Auto-Update
- **File:** `lib/application/usecases/inventory/add_restock.dart`
  - When unit_cost provided: update product.costPrice = unitCost

**Verification Phase 4:**
- [ ] Completing an order deducts stock for tracked products
- [ ] Completing an order deducts ingredient stock for recipe products
- [ ] Cancelling a completed order returns stock
- [ ] Cancelling a pending/paid order has no stock effect
- [ ] Cost snapshots are recorded on completion
- [ ] Recipe cost snapshots sum ingredient costs correctly
- [ ] Missing ingredient costs are ignored (partial costing)
- [ ] Negative stock allowed (no checkout blocking)
- [ ] Restocking with unit cost updates product.costPrice

---

## Phase 5: Dashboard Screen
*Depends on Phase 4 for profit cards. Base cards (revenue, orders) can start after Phase 1.*

### Step 5.1: Navigation Update
- **File:** `lib/core/router/app_router.dart` — add `/dashboard` route
- **File:** `lib/presentation/widgets/app_shell.dart` — update to 5 tabs:
  1. POS (Orders) — `Icons.point_of_sale`
  2. History (Orders) — `Icons.receipt_long`
  3. Dashboard — `Icons.dashboard`
  4. Products — `Icons.inventory_2`
  5. Settings — `Icons.settings`

### Step 5.2: Dashboard Screen (new)
- **New file:** `lib/presentation/screens/dashboard_screen.dart`
  - Scrollable card layout (responsive grid on tablet, single column on phone)
  - Cards (grouped):
    - **Sales:** Today Revenue, Orders Today, Average Order Value, Items Sold Today
    - **Outstanding:** Unpaid Orders count + total
    - **Profit:** Estimated Profit Today, Profit Coverage %
    - **Inventory:** Stock Value (sum of stockQty × costPrice), Restock Spend (last 7 days)
  - Each card: label, value, optional trend indicator
  - "View Reports" link → navigates to reports section

### Step 5.3: Dashboard Providers & Use Cases
- **New file:** `lib/application/usecases/reporting/get_dashboard_metrics.dart`
  - Queries: today's orders (paid/completed), calculates revenue, AOV, item count
  - Queries: unpaid order count and total
  - Queries: COGS from today's completed orders, calculates estimated profit
  - Queries: stock value aggregation, restock spend in last 7 days
- **New providers:** `lib/presentation/providers/dashboard_providers.dart`

**Verification Phase 5:**
- [ ] Dashboard tab appears in navigation
- [ ] Revenue, orders, AOV cards show correct values
- [ ] Unpaid orders card accurate
- [ ] Estimated Profit card shows Revenue − COGS
- [ ] Profit Coverage % displays correctly
- [ ] Stock Value card sums (stockQty × costPrice) for tracked products
- [ ] Restock Spend shows sum of last 7 days restocks
- [ ] Cards are responsive (grid on tablet, column on phone)

---

## Phase 6: Reports Module
*Depends on Phase 5 (nested inside Dashboard). Can start UI scaffolding after Phase 1.*

### Step 6.1: Reports Shell & Navigation
- **New file:** `lib/presentation/screens/reports_screen.dart`
  - Top tabs: Sales | Inventory | Profit
  - Entry point: Dashboard → "View Reports" button OR tab within Dashboard screen
- **Route:** Add `/dashboard/reports` and `/dashboard/reports/:type` routes

### Step 6.2: Date Range Picker Widget
- **New file:** `lib/presentation/widgets/date_range_picker.dart`
  - Presets: Today, Yesterday, Last 7 Days, Last 30 Days, This Month, Custom Range
  - Custom range opens Flutter date range picker
  - Shared across all report screens
- **New provider:** `reportDateRangeProvider` in a new `lib/presentation/providers/report_providers.dart`

### Step 6.3: Sales Reports
- **Sales Summary screen:** Revenue, Order count, AOV, Items sold (for selected date range)
- **Sales by Product screen:** Table — product name, qty sold, revenue, % of total
- **Sales by Category screen:** Table — category, qty sold, revenue, % of total
- **Orders List screen:** Filterable table of orders in range
- **Use case:** `lib/application/usecases/reporting/get_sales_report.dart`

### Step 6.4: Inventory Reports
- **Stock on Hand screen:** Current stock list with values
- **Low Stock Report screen:** Products at/below threshold
- **Stock Movement History screen:** Chronological list of restocks, adjustments, sales deductions — filterable by date range and product
- **Use case:** `lib/application/usecases/reporting/get_inventory_report.dart`

### Step 6.5: Profit Reports
- **Profit Summary screen:** Revenue, Known COGS, Estimated Profit, Coverage %
- **Profit by Product screen:** Table — product, revenue, COGS, margin, margin %
- **Profit Coverage % screen:** Visual breakdown of costed vs uncosted revenue
- **Use case:** `lib/application/usecases/reporting/get_profit_report.dart`

**Verification Phase 6:**
- [ ] All 3 report tabs accessible from Dashboard
- [ ] Date range picker works with all presets + custom range
- [ ] Sales summary numbers match Dashboard for "Today"
- [ ] Sales by product/category totals match sales summary
- [ ] Inventory reports show only tracked products
- [ ] Stock movement history includes restocks, adjustments, and sale deductions
- [ ] Profit reports show "Estimated" label
- [ ] Profit coverage % is correct (costed revenue / total revenue)

---

## Phase 7: Data Export & Backup/Restore
*Depends on Phase 6 for per-report exports. Backup can start after Phase 1.*

### Step 7.1: Export Service
- **New file:** `lib/application/services/export_service.dart`
  - Abstract interface with methods: `exportToExcel()`, `exportToCsv()`, `exportToJson()`
  - Accepts report data (list of maps/rows) + column definitions + filename
  - Returns file path or bytes
- **New file:** `lib/application/services/file_export_service.dart`
  - Concrete implementation — uses `syncfusion_flutter_xlsio` for Excel, manual CSV generation, `dart:convert` for JSON
  - File naming: `pos_<report>_<YYYY-MM-DD>.ext`
  - Uses `path_provider` for temp directory + platform share/save dialog

### Step 7.2: Export Buttons on Report Screens
- **New file:** `lib/presentation/widgets/export_button_group.dart`
  - Row of 3 buttons: Excel, CSV, JSON
  - Triggers export with current filtered data
- Integrate into each report screen from Phase 6

### Step 7.3: Add `syncfusion_flutter_xlsio` and `share_plus` to pubspec.yaml

### Step 7.4: Full Backup Export
- **New file:** `lib/application/services/backup_service.dart`
  - `exportBackup()`: queries all tables, serializes to single JSON bundle
  - Includes: products, orders, order_items, payments, recipe_items, restock_entries, stock_adjustments, settings
  - `importBackup(jsonString)`: validates structure, clears all tables, inserts all data, signals app restart
- **Warning:** Import is destructive — must show confirmation dialog

### Step 7.5: Settings → Data Management Section
- **File:** `lib/presentation/screens/settings_screen.dart`
  - Add "Data Management" section below existing settings
  - "Export Full Backup" button → triggers backup_service.exportBackup()
  - "Import Backup" button → file picker → confirmation dialog → backup_service.importBackup()
  - Danger warning styling for import

**Verification Phase 7:**
- [ ] Can export any report as Excel, CSV, JSON
- [ ] Exported files contain correct filtered data
- [ ] File names follow `pos_<report>_<date>.ext` format
- [ ] Can export full backup from Settings
- [ ] Can import backup — shows warning dialog, requires confirmation
- [ ] After import, all data replaced correctly
- [ ] App functions normally after import

---

## Relevant Files

### Modify
- `lib/data/database/app_database.dart` — migration v1→v2, register new tables
- `lib/data/database/tables/products_table.dart` — add inventory columns
- `lib/data/database/tables/order_items_table.dart` — add cost/revenue snapshot columns
- `lib/domain/entities/product.dart` — add inventory fields
- `lib/domain/entities/order_item.dart` — add snapshot fields
- `lib/domain/repositories/product_repository.dart` — add inventory methods
- `lib/data/mappers/product_mapper.dart` — map new fields
- `lib/data/mappers/order_mapper.dart` — map snapshot fields
- `lib/data/repositories/drift_product_repository.dart` — implement new methods
- `lib/presentation/widgets/product_form_dialog.dart` — inventory fields + recipe builder
- `lib/presentation/screens/product_list_screen.dart` — segmented control, stock indicators
- `lib/presentation/widgets/product_card.dart` — low stock badge
- `lib/presentation/widgets/app_shell.dart` — 5-tab navigation
- `lib/core/router/app_router.dart` — new routes
- `lib/presentation/providers/repository_providers.dart` — new repository providers
- `lib/presentation/screens/settings_screen.dart` — data management section
- `lib/application/usecases/order/update_order_status.dart` — stock deduction + COGS snapshot
- `lib/application/usecases/product/create_product.dart` — accept new fields
- `lib/application/usecases/product/update_product.dart` — accept new fields
- `pubspec.yaml` — new dependencies

### Create
- `lib/data/database/tables/recipe_items_table.dart`
- `lib/data/database/tables/restock_entries_table.dart`
- `lib/data/database/tables/stock_adjustments_table.dart`
- `lib/domain/entities/recipe_item.dart`
- `lib/domain/entities/restock_entry.dart`
- `lib/domain/entities/stock_adjustment.dart`
- `lib/domain/repositories/recipe_repository.dart`
- `lib/domain/repositories/restock_repository.dart`
- `lib/domain/repositories/stock_adjustment_repository.dart`
- `lib/data/mappers/recipe_item_mapper.dart`
- `lib/data/mappers/restock_entry_mapper.dart`
- `lib/data/mappers/stock_adjustment_mapper.dart`
- `lib/data/repositories/drift_recipe_repository.dart`
- `lib/data/repositories/drift_restock_repository.dart`
- `lib/data/repositories/drift_stock_adjustment_repository.dart`
- `lib/application/usecases/inventory/add_restock.dart`
- `lib/application/usecases/inventory/adjust_stock.dart`
- `lib/application/usecases/inventory/manage_recipe.dart`
- `lib/application/usecases/reporting/get_dashboard_metrics.dart`
- `lib/application/usecases/reporting/get_sales_report.dart`
- `lib/application/usecases/reporting/get_inventory_report.dart`
- `lib/application/usecases/reporting/get_profit_report.dart`
- `lib/application/services/export_service.dart`
- `lib/application/services/file_export_service.dart`
- `lib/application/services/backup_service.dart`
- `lib/presentation/screens/dashboard_screen.dart`
- `lib/presentation/screens/stock_list_screen.dart`
- `lib/presentation/screens/stock_detail_screen.dart`
- `lib/presentation/screens/reports_screen.dart`
- `lib/presentation/widgets/restock_dialog.dart`
- `lib/presentation/widgets/stock_adjustment_dialog.dart`
- `lib/presentation/widgets/date_range_picker.dart`
- `lib/presentation/widgets/export_button_group.dart`
- `lib/presentation/providers/inventory_providers.dart`
- `lib/presentation/providers/dashboard_providers.dart`
- `lib/presentation/providers/report_providers.dart`

### Tests to Add
- `test/data/database/migration_v1_to_v2_test.dart`
- `test/domain/entities/recipe_item_test.dart`
- `test/domain/entities/restock_entry_test.dart`
- `test/domain/entities/stock_adjustment_test.dart`
- `test/application/usecases/add_restock_test.dart`
- `test/application/usecases/adjust_stock_test.dart`
- `test/application/usecases/stock_deduction_test.dart`
- `test/application/usecases/cogs_snapshot_test.dart`

---

## Scope Boundaries
**Included:**
- Inventory tracking (optional, non-blocking)
- Recipe/ingredient composition
- Restock & stock adjustment
- COGS snapshot & estimated profit
- Full dashboard with all spec cards
- 10 report types (3 categories) with date filtering
- Export: Excel/CSV/JSON per report
- Full backup export & import/restore
- Navigation restructure to 5 tabs

**Excluded:**
- Tax/VAT calculations
- Barcode scanning
- Multi-currency
- Cloud sync
- Customer management
- Discounts/promotions
- Dark theme (already future-ready in AppTheme)
