# Technical Architecture

**Project:** Offline-First POS  
**Primary Stack:** Flutter  
**Author:** Monaheng Ramokhoro  
**Status:** MVP Architecture Definition. 

---

## 1. Architectural Goals

This architecture must:

- Support offline-first operation
- Be cross-platform (Android, iOS, Windows, macOS, Linux)
- Be easy to maintain by a solo developer
- Allow future cloud sync without refactoring core logic
- Prevent tight coupling between UI and storage
- Support database migrations safely
- Support long-term scalability

---

## 2. High-Level Architecture

We will use a simplified Clean Architecture approach:

```
Presentation Layer (Flutter UI)
        ↓
Application Layer (Use Cases / Services)
        ↓
Domain Layer (Business Logic & Entities)
        ↓
Data Layer (Repositories & Local Database)
```

Each layer must only depend on the layer below it.

UI must never directly access the database.

---

## 3. Layer Responsibilities

### 3.1 Presentation Layer

Responsible for:
- Screens
- Widgets
- State management
- User interaction
- Navigation

Must NOT:
- Contain SQL
- Contain database logic
- Contain business rules

Recommended State Management:
- Riverpod (preferred)
OR
- Bloc (if stricter structure desired)

Keep state logic separate from UI widgets.

---

### 3.2 Application Layer

Contains:
- Use cases
- Service classes
- Transaction orchestration

Examples:
- CreateOrderUseCase
- AddProductToOrderUseCase
- CompleteOrderUseCase
- UpdateOrderStatusUseCase

This layer:
- Coordinates repositories
- Applies validation rules
- Handles transactions

No UI code here.
No direct SQL here.

---

### 3.3 Domain Layer

Contains:
- Core business entities
- Value objects
- Business rules

Examples:
- Order
- OrderItem
- Product
- Payment
- OrderStatus enum

This layer must:
- Be pure Dart
- Have zero Flutter imports
- Have zero database imports

It must be testable in isolation.

---

### 3.4 Data Layer

Responsible for:
- Local database
- Repositories
- Mappers (DB <-> Domain models)

Preferred Database:
- Drift (SQLite) for maximum control
OR
- Isar (if wanting high performance and easier schema)

Database Requirements:
- Schema versioning
- Automatic migrations
- Non-destructive upgrades
- Transaction support

Repositories must:
- Implement interfaces defined in Domain
- Be replaceable later with sync-enabled versions

---

## 4. Database Design Strategy

### 4.1 Tables Required (MVP)

- products
- orders
- order_items
- payments
- settings

### 4.2 Required Fields (All Major Tables)

- local_id (UUID)
- created_at
- updated_at
- deleted_at (nullable)
- sync_status (enum, future-proof)

### 4.3 Soft Delete Policy

Paid orders must NOT be hard deleted.

Use:
- deleted_at timestamp
Instead of:
- DELETE FROM

---

## 5. State Management Strategy

Recommended: Riverpod

Reason:
- Scales well
- Clear dependency injection
- Easy testing
- No heavy boilerplate
- Works well cross-platform

State types:
- Immutable state objects
- Explicit loading/success/error states

---

## 6. Printing Architecture

Create a PrinterService abstraction:

```
abstract class PrinterService {
  Future<void> printReceipt(Order order);
}
```

Implementations:
- DesktopPrinterService
- BluetoothPrinterService (Android first)

UI must not depend on printer implementation directly.

---

## 7. Update & Migration Architecture

Database must support:

- Schema version tracking
- Incremental migrations
- Automatic execution on app start

Migration pattern:

- v1 → v2
- v2 → v3
- No destructive resets

App update must NOT:
- Wipe database
- Reset settings
- Break order history

---

## 8. Future Sync Architecture (Not Implemented Yet)

Prepare for:

SyncEngine (future layer)

Future architecture addition:

```
Data Layer
   ↓
Sync Adapter
   ↓
Remote API
```

Each record must be:
- Conflict-detectable
- Timestamped
- Soft-deletable

---

## 9. Folder Structure

lib/
│
├── core/
│   ├── utils/
│   ├── constants/
│   └── errors/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── enums/
│
├── application/
│   ├── usecases/
│   └── services/
│
├── data/
│   ├── models/
│   ├── database/
│   ├── repositories/
│   └── mappers/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
│
└── main.dart

---

## 10. Testing Strategy

Must include:

- Unit tests for:
  - Use cases
  - Domain logic

- Integration tests for:
  - Database migrations
  - Order creation flow

Do NOT skip migration tests.

---

## 11. Performance Constraints

- App launch < 2 seconds
- Order creation < 300ms
- UI must remain responsive during DB operations
- Use isolates if heavy computation is added later

---

## 12. Anti-Patterns to Avoid

- Putting SQL inside widgets
- God classes
- Direct DB calls from UI
- Mixing domain models with DB models
- Premature microservices thinking
- Over-abstraction in MVP

---

## 13. Architectural Review Rule

Before adding any feature:

Ask:
1. Does this break offline-first?
2. Does this tightly couple UI and data?
3. Does this increase complexity unnecessarily?
4. Is this MVP scope creep?

If yes → do not implement.

---

## 14. Theming & Design System Architecture

### 14.1 Theme Philosophy

The app must use a centralized theming system.

No widget should define its own:
- Hard-coded colors
- Hard-coded font sizes
- Hard-coded spacing
- Hard-coded text styles

All visual styling must flow from a single source of truth.

This ensures:
- Consistency across mobile and desktop
- Easy global rebranding
- Dark mode support
- Future white-label capability
- Maintainable long-term UI scaling

---

### 14.2 Theme Structure

The app must define:

- Global AppTheme
- Light theme
- Dark theme (future-ready, even if not used immediately)

Example structure:

lib/
└── core/
    └── theme/
        ├── app_theme.dart
        ├── app_colors.dart
        ├── app_typography.dart
        └── app_spacing.dart

---

### 14.3 AppTheme

AppTheme is responsible for:

- Creating ThemeData
- Defining color scheme
- Defining typography
- Defining button styles
- Defining input field styles
- Defining card styles
- Defining elevated button theme
- Defining app bar theme

The entire app must use:

MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
)

---

### 14.4 AppColors

All colors must be defined in one file:

Examples:
- primary
- secondary
- accent
- success
- warning
- error
- background
- surface
- border
- disabled

Never use Colors.red, Colors.blue, etc directly in widgets.

If a new color is needed, it must be added to AppColors.

---

### 14.5 Typography

Define a consistent text scale:

- displayLarge
- headlineMedium
- titleLarge
- bodyMedium
- labelSmall

Do not use TextStyle(fontSize: X) inside widgets.

Always use:

Theme.of(context).textTheme.titleLarge

---

### 14.6 Spacing System

Define spacing constants:

- xs
- sm
- md
- lg
- xl

Example:

AppSpacing.sm
AppSpacing.lg

Never use raw SizedBox(height: 12) or EdgeInsets.all(8) inside widgets.

---

### 14.7 POS-Specific UI Rules

Because this is a POS system:

- Buttons must be large and touch-friendly
- Minimum tap area: 48px
- Important actions must be visually distinct
- Payment button must be highly visible
- Order status must be color-coded consistently

Status color mapping must be defined centrally, not inside widgets.

Example:
- Pending → warning color
- Paid → success color
- Cancelled → error color

---

### 14.8 Future-Proofing

The theme system must allow:

- Business-specific branding
- Color override
- White-label potential
- Runtime theme switching (future feature)

---

### 14.9 Anti-Patterns to Avoid

Do NOT:

- Hardcode colors in widgets
- Hardcode font sizes
- Hardcode padding values
- Mix Material 2 and Material 3 randomly
- Define button styles inline repeatedly

All styling decisions must be centralized.

---



# End of Technical Architecture
