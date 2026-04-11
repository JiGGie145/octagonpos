# Instruction for Agent — Update Order History Page

## Goal

Redesign the **Order History screen** to use a **tablet-first masonry card layout** similar to specs/order_history_mansory.png.

The layout must feel fast to scan, dense, and touch friendly.

---

## Layout Requirements

### Overall Layout

* Use a **responsive masonry / staggered grid layout**
* Cards should auto-flow vertically in columns
* Support desktop scaling to wider screens
* Cards should have fixed width and variable height

Target feel:

* Similar visual density to the Orders page in the image but conforming to current project styling.
* Optimised for fast scanning of many orders

---

## Order Card Structure

Each order should be displayed inside a **Card component**.

### Card Header

Top row should contain:

Left:

* **Order Number**

  * Format: `Order #1234`
  * Bold, prominent

Right:

* **Order Status badge**


Use colour-coded status chips.

---

### Items Section

Display compact table:

Columns:

```
QTY | Item | Total
```

Example:

```
2   Burger        $10.00
1   Coke          $2.50
```

Rules:

* Max 4–5 items visible
* If more items exist → show:

  ```
  + 3 more items
  ```

---

### Subtotal Section

Below items:

```
Subtotal        $12.50
```

Right aligned, slightly emphasized.

---

### Payment Section

Show **Payment Status**

Two possible states:

#### Paid

Show badge:

```
PAID ✓
```

Muted/green styling.

#### Unpaid

Show:

* Badge: `UNPAID`
* Primary button:

```
[ Pay Now ]
```

Button triggers payment flow (no logic required now, just UI + callback).

---

### Footer (Tiny Metadata)

Very small, subtle footer text:

Examples:

```
Today 14:32
Yesterday 09:10
12 Mar 2026 18:02
```

Style:

* Smallest text size in card
* Low contrast / secondary colour
* Bottom right aligned

---

## Interaction Requirements

Each card should be **tappable/clickable**.

Tap action:

```
Open Order Details screen
```

---

## Visual Style Guidelines

Match existing theme:

* Dark theme
* Same card styling as Orders screen
* Same spacing scale
* Same button + chip components

Card padding guideline:

```
16–20px internal padding
12–16px gap between cards
```

---

## Empty State

If no orders exist:

Centered content:

```
No orders yet
Your completed and unpaid orders will appear here.
```

Optional icon placeholder.

---

## Acceptance Criteria

The task is complete when:

* Masonry grid implemented
* Order cards render correctly
* Paid vs unpaid states visible
* Pay Now button appears only for unpaid orders
* Cards are responsive and tablet-optimised
* Styling matches Orders screen

---
