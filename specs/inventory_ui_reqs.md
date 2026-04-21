# 🎨 OFFLINE POS — UI/UX REQUIREMENTS

This document defines the full UI structure and behaviour.

---

# 🧠 GLOBAL UX PRINCIPLES

## Offline-first UX messaging

The UI must never imply internet is required.

No:
• “Syncing…”
• “Connection lost”
• Cloud icons

Everything feels local and instant.

---

# 🧭 APP NAVIGATION

## Primary Navigation = Bottom Nav (Mobile/Tablet)

Tabs:

1. **Main Screen (Order Screen)**
2. **Orders**
3. **Dashboard**
4. **Products**
5. **Reports**
6. **Settings**

Desktop may render this as a left sidebar.

---

# 🛒 CHECKOUT SCREEN (Core Screen)

This is the most important screen in the entire app.

## Layout

Tablet/Desktop = 2-panel layout

| Left         | Right         |
| ------------ | ------------- |
| Product grid | Current order |

Phone = stacked layout.

---

# 📜 ORDERS SCREEN

Masonry grid of cards.

Card must display:

• Order number
• Status badge (color coded)
• Items summary
• Total
• Payment status
• Timestamp
• PAY NOW button if unpaid

Tap card → Order Details screen.

---

# 📄 ORDER DETAILS SCREEN

Sections:

1. Order summary
2. Items list
3. Payment status
4. Actions

Actions:

• Mark completed
• Record payment
• Cancel order
• Refund order
• Print receipt

Buttons must be large and spaced.

Danger actions visually separated.

---

# 📦 PRODUCTS SCREEN

Top segmented control:

• Sellable products
• Ingredients
• All products

FAB button:
**Add Product**

---

## Product Form

Fields:

• Name
• Price
• Category
• Track stock toggle

If Track Stock ON → reveal:

• Current stock
• Low stock threshold override
• Cost price
• “Uses ingredients” toggle

If Uses Ingredients ON → show recipe builder.

---

## Recipe Builder UI

List of ingredient rows:

Ingredient selector dropdown
Quantity field
Unit label display

Button:
**Add ingredient**

---

# 📦 INVENTORY SCREENS

## Stock List Screen

Columns:

• Product
• Stock qty
• Cost price
• Stock value
• Low stock indicator

Row tap → Stock Detail screen.

---

## Stock Detail Screen

Sections:

• Current stock card
• Movement history list

Buttons:

• Restock
• Adjust stock

---

## Restock Dialog

Fields:

• Quantity added
• Unit cost (optional)
• Notes (optional)

Primary button: **Add Stock**

---

## Stock Adjustment Dialog

Fields:

• Quantity change (+/−)
• Reason (optional)

Primary button: **Adjust Stock**

---

# 📊 DASHBOARD SCREEN

Scrollable card layout.

Cards:

• Today Revenue
• Orders Today
• Average Order Value
• Unpaid Orders
• Items Sold Today

NEW CARDS:

• Estimated Profit Today
• Profit Coverage %
• Stock Value
• Restock Spend (7 days)

---

# 📈 REPORTS MODULE

Top tabs:

• Sales
• Inventory
• Profit

Each report screen must include:

• Date range picker
• Export button group

Export buttons:
• Excel
• CSV
• JSON

---

# ⚙️ SETTINGS → DATA MANAGEMENT

Section title: **Data Management**

Buttons:

• Export Full Backup
• Import Backup

Import must show warning dialog:

“This will replace all data on this device.”

User must confirm.

---

# 🎯 EMPTY STATES

Required empty states:

• No stock tracked → “Enable stock tracking on products”

Each empty state must contain a primary action button.

---

# 🔔 LOW STOCK INDICATORS

Visible in:

• Product list
• Checkout screen
• Stock list

Display:
⚠ Low stock badge

---

# 📱 RESPONSIVE BEHAVIOUR SUMMARY

Tablet/Desktop:
• Multi-column layouts

Phone:
• Stacked navigation
• Floating action buttons

---

# ✅ UI ACCEPTANCE CRITERIA

The UI is complete when a user can:

✔ Add stock-tracked products
✔ Create recipe products
✔ Restock and adjust inventory
✔ See low stock warnings
✔ View profit metrics
✔ Run reports and export files
✔ Backup and restore data

---