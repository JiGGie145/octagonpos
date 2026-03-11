# Offline-First POS System

**Project Name (Working Title):** TBD  
**Author:** Monaheng Ramokhoro  
**Status:** Initial Definition (MVP Scope Locked)  
**Primary Stack:** Flutter  

---

## 1. Vision

Build a free, high-quality, offline-first Point of Sale (POS) application for:

- Small food trucks
- Small convenience stores
- Informal/local businesses
- Eventually scalable to medium and large businesses

The product must:
- Work fully offline
- Sync optionally to cloud APIs (separate project)
- Be easy to install and update
- Be reliable in low-connectivity regions
- Be simple for non-technical users

---

## 2. Core Principles

1. Offline First Always
2. Data is Local Authority
3. Simple Installation
4. Safe Updates
5. Solo Developer Maintainability

---

## 3. Target Platforms (Phase 1)

- Android
- iOS
- Windows
- macOS
- Linux

Web is NOT in scope for MVP.

---

## 4. MVP Scope (Strict)

### 4.1 Products

- Create product
- Edit product
- Delete product
- Price
- Basic category
- Active / inactive status

No inventory tracking yet.

---

### 4.2 Orders

Must support:

- Create new order
- Add multiple products
- Adjust quantity
- Remove product
- Calculate total
- Add optional note
- Assign order status

#### Order Status (Required)

- Pending
- Paid
- Completed
- Cancelled

Status must be editable after order creation.

---

### 4.3 Payments

- Cash
- Card (manual confirmation only)
- Mark as paid

No payment gateway integration in MVP.

---

### 4.4 Receipt Printing

Must include:

- Business name
- Date & time
- Order number
- Line items
- Total
- Payment method

Support:
- Desktop printers
- Bluetooth thermal printer (Android first)

---

### 4.5 Business Setup

First launch must collect:

- Business name
- Currency
- Receipt footer message
- Optional tax percentage

Editable later in settings.

---

## 5. Explicitly Out of Scope (MVP)

Do NOT implement:

- Multi-user authentication
- Inventory tracking
- Supplier management
- Advanced reporting
- Discounts
- Promotions
- Barcode scanning
- Cloud sync
- Multi-branch support
- Role-based access control
- Web dashboard
- Accounting integration

---

## 6. Architecture Requirements

- Clean architecture separation
- Embedded local database
- Schema versioning
- Automatic migrations
- Non-destructive upgrades

---

## 7. Update Strategy

- Installer-based updates (desktop)
- APK-based updates (Android)
- Data must persist
- Migrations automatic
- No manual SQL required

---

## 8. Sync Readiness (Future)

Each table must include:

- local_id
- created_at
- updated_at
- deleted_at (nullable)
- sync_status

---

## 9. Success Criteria (MVP)

A small business owner must be able to:

1. Install app
2. Add products
3. Take orders
4. Accept payment
5. Print receipt
6. Reopen app next day and see previous orders intact

Without internet.

---

## End of MVP Requirements
