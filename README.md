# Cash Register POS

A Flutter cash point-of-sale app for a grocery store with multiple salespersons.

## Features

- **Multi-salesperson login** — each salesperson logs in with a 4-digit PIN (`User` with `role = 'salesperson'`).
- **Cash register** — salesperson builds a cart from the product grid, optionally picks a client (walk-in supported), enters cash received, and the app computes VAT (19.25%) and change.
- **Receipts** — after each sale a printable/shareable PDF receipt (80 mm) is shown (Print via system print dialog, Share via PDF).
- **Orders** — every sale creates an `Order` (status `paid`, payment method `cash`) plus an `OrderItem` per line and a `CashPayment` record (amount tendered + change).
- **Void / refund** — long-press an order to void it: the order is marked cancelled/refunded and items are returned to stock.
- **Stock** — product `stockQuantity` is decremented on each sale and restored on void.
- **Daily report** — total sales, VAT, cash in drawer, and per-salesperson breakdown (voided orders excluded).
- **Admin** — manage products (add/edit/activate/delete), salespersons (add, reset PIN, activate/deactivate), and clients (add/edit/delete).

## Data model (Hive local DB)

| Model | Box | Notes |
| --- | --- | --- |
| `User` | `users` | salespersons; `pin`, `role`, `storeId` |
| `Product` | `products` | `price`, `stockQuantity`, `vendorId` |
| `Client` | `clients` | optional customer attached to an order |
| `Order` | `orders` | `salespersonId`, `clientId`, `cashPaymentId`, totals |
| `OrderItem` | `order_items` | line items of an order |
| `CashPayment` | `cash_payments` | `amountTendered`, `changeAmount`, `salespersonId` |
| `Store` / `Vendor` | `stores` / `vendors` | context for multi-store setups |

All data is stored locally (offline-first) in Hive.

## Run

```bash
flutter pub get
flutter run
```

### First-time setup

1. Tap **Admin** → **Salespersons** → **Add** to create users (PIN = 4 digits).
2. Tap **Admin** → **Products** → **Add Product** to add items with prices and stock.
3. (Optional) Tap **Admin** → **Clients** to add regular customers.
4. Log in on the POS with a salesperson PIN.

## Tests

```bash
flutter test
```

## Regenerate Hive adapters (after model changes)

```bash
dart run build_runner build --delete-conflicting-outputs
```