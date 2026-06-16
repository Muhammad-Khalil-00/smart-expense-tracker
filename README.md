# Smart Expense Tracker

A Flutter app I built as part of my **Teyzix Core Internship (June Batch)** — Task MAD-1.

The idea was simple: build something that actually helps people track where their money is going. No Firebase, no internet required — everything runs offline using Hive as local storage.

---

## What it does

- **Auth** — Register/Login with secure SHA-256 hashed passwords. Session persists so you don't have to log in every time.
- **Expenses** — Add, edit, delete expenses with category, payment method, date and description.
- **Income** — Track your income sources the same way.
- **Budgets** — Set a monthly budget or per-category budgets. Progress bars go orange/red as you get close or exceed the limit.
- **Analytics** — Pie chart for category-wise spending, bar chart for last 6 months income vs expenses.
- **Search & Filters** — Search by keyword, filter by type, category, or month.
- **Notifications** — Get alerted when you exceed a budget. Optional daily reminder to log your expenses (toggleable from profile).
- **Fully Offline** — No internet needed at any point. All data lives on your device.

---

## Tech Stack

- **Flutter** (Dart)
- **Hive** — local NoSQL database
- **Provider** — state management
- **fl_chart** — charts
- **flutter_local_notifications** — push notifications
- **crypto** — SHA-256 password hashing
- **uuid** — unique IDs

---

## Project Structure

```
lib/
├── main.dart
├── models/          # Hive models + generated adapters
├── providers/       # Business logic & state
├── screens/         # All UI screens
├── services/        # Notification service
├── widgets/         # Reusable components
└── utils/           # Constants, helpers
```

Followed a clean separation — models handle data, providers handle logic, screens only deal with UI.

---



## Notes

- Multi-user support is implemented — each account only sees its own data.
- No Firebase or any remote backend. This was intentional per the task requirements.
- Passwords are never stored in plain text — SHA-256 hash + unique salt per user.

---
