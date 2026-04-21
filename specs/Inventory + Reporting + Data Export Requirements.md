# 📄 OFFLINE-FIRST POS

# Inventory + Reporting + Data Export Requirements

This document extends the MVP POS specification.

The goal of this release is to add:

• Inventory tracking (optional & non-blocking)
• Cost tracking & estimated profit
• Reporting system
• Data export & full backup/restore

The POS must remain **offline-first**, **self-serve**, and **simple**.

---

# 🧠 CORE PRINCIPLES

1. Inventory is OPTIONAL
   The POS must work fully without using inventory.

2. Mixed catalogues are supported
   A business may sell:

   * Services (no stock)
   * Stocked products
   * Recipe products
     All together.

3. Checkout is NEVER blocked by inventory.

4. All profit numbers are labelled **Estimated**.

5. All operations work 100% offline.

---

# 🧱 DATA MODEL

## Product

New fields:

| Field               | Type             | Notes                              |
| ------------------- | ---------------- | ---------------------------------- |
| track_stock         | bool             | default false                      |
| uses_ingredients    | bool             | only visible if track_stock = true |
| stock_qty           | decimal          | nullable                           |
| low_stock_threshold | decimal nullable | overrides global default           |
| cost_price          | decimal nullable | last known cost                    |
| is_sellable         | bool             | ingredients = false                |

---

## Ingredient Composition (Recipe/BOM)

```
RecipeItem
- id
- product_id (recipe product)
- ingredient_product_id
- quantity_required
```

Ingredients are normal products where:

```
track_stock = true
is_sellable = false (optional)
```

---

## Restock Entry

```
RestockEntry
- id
- product_id
- quantity_added
- unit_cost (optional)
- total_cost (optional)
- date
- notes
```

When restock saved:

```
product.stock_qty += quantity_added
IF unit_cost provided:
    product.cost_price = unit_cost
```

Editable and deletable forever.
Deleting must reverse stock.

---

## Stock Adjustment

Manual correction.

```
StockAdjustment
- id
- product_id
- quantity_change (+/-)
- reason (optional)
- date
```

---

## Order Item (NEW FIELDS)

We snapshot cost at time of sale.

```
OrderItem
- cost_snapshot_total nullable
- revenue_snapshot_total
```

---

# 📦 INVENTORY LOGIC

## Stock Deduction Moment

Stock changes ONLY when order becomes **Completed**.

---

## Cancellation Behaviour

| Action                   | Stock effect   |
| ------------------------ | -------------- |
| Cancel before completion | none           |
| Cancel after completion  | stock returned |

---

## Refund Behaviour

Refund **does NOT** return stock.

---

## Negative Stock

If stock insufficient:
• Allow sale
• Show warning

---

## Recipe Stock Deduction

When recipe product sold:

For each ingredient:

```
ingredient.stock_qty -= recipe.qty * order.qty
```

---

# 💰 COST & PROFIT ENGINE

## COGS Snapshot Rule

COGS is recorded at **completion time** using current cost.

Never recalc historical orders.

---

## Simple Product Cost

```
cost_snapshot_total = product.cost_price * qty
```

---

## Recipe Cost

```
cost_snapshot_total =
SUM(ingredient.qty_required * ingredient.cost_price)
```

Missing ingredient costs are ignored (partial costing allowed).

---

# 📊 PROFIT METRICS

## Revenue

```
Revenue = sum of PAID orders only
```

---

## COGS

```
COGS = sum(order_item.cost_snapshot_total where not null)
```

---

## Estimated Profit

```
Estimated Profit = Revenue − Known COGS
```

---

## Profit Coverage %

```
Revenue_with_cost / Total_revenue
```

Must be displayed on:
• Dashboard
• Profit reports

---

# 📊 REPORTING MODULE

All reports support:

• Today
• Yesterday
• Last 7 days
• Last 30 days
• This month
• Custom range

Reports respect current filters when exported.

---

## SALES REPORTS

1. Sales Summary
   Revenue, orders, AOV, items sold

2. Sales by Product

3. Sales by Category

4. Orders List

---

## INVENTORY REPORTS

5. Stock on Hand
6. Low Stock Report
7. Stock Movement History
   (restocks + adjustments + sales)

---

## PROFIT REPORTS

8. Profit Summary
9. Profit by Product
10. Profit Coverage %

---

# 📊 DASHBOARD ADDITIONS

Add cards:

• Estimated Profit Today
• Profit Coverage %
• Stock Value
• Restock Spend (last 7 days)

---

# 📤 DATA EXPORT SYSTEM

Exports must be available on:

• Each report screen
• Settings → Data Management

---

## Export Formats

Per-report exports:
• Excel (.xlsx)
• CSV (.csv)
• JSON (.json)

Export exactly what is currently filtered.

File naming format:

```
pos_<report>_<YYYY-MM-DD>.ext
```

---

## FULL BACKUP EXPORT

Location: Settings → Data Management → Export Backup

Creates a **single JSON bundle** containing:

• Products
• Orders
• Order Items
• Payments
• Restocks
• Stock Adjustments
• Settings

---

## IMPORT / RESTORE

User can import backup file.

Behaviour:

• Warn user existing data will be overwritten
• Full database replacement
• App restart required after import

No merging in V1.

---

# 🧾 SETTINGS ADDITIONS

New section: **Data Management**

Contains:

• Export backup
• Import backup
• Danger warnings

---

# 🌍 SYSTEM CONSTRAINTS

• Single currency per device
• Device timezone used for reports
• No tax/VAT yet
• Barcode reserved for future

---

# ✅ IMPLEMENTATION ACCEPTANCE CRITERIA

The feature is complete when a business can:

✔ Track stock for selected products
✔ Restock and adjust stock
✔ See low stock warnings
✔ Record cost prices automatically
✔ View estimated profit
✔ Understand profit coverage
✔ Run reports with date filters
✔ Export any report to Excel/CSV/JSON
✔ Export full backup file
✔ Restore backup on new device

---

If you’d like, next we can write the **UI/UX screen requirements** to guide the Flutter agent 🎨
