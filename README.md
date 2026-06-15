# Smart Expense Tracker & Personal Finance Manager

**Teyzix Core Internship — Task MAD-1 (Mobile App Development)**

A fully offline-first Flutter application that helps users record income and expenses, set monthly and category budgets, track spending against those budgets, and visualize their financial health through an analytics dashboard.

---

## ✨ Features

### 1. Authentication System
- User Registration (Name, Email, Password)
- Login with email/password
- Passwords are hashed using **SHA-256** before being stored (no plain-text passwords)
- Persistent sessions — once logged in, the user stays logged in until they explicitly log out (session stored locally via Hive)

### 2. Expense Management
- Add, edit, and delete expenses
- Fields: Amount, Category, Date, Payment Method, Description
- Full expense history, sorted by most recent

### 3. Income Management
- Add, edit, and delete income entries
- Fields: Amount, Source, Date, Description
- Full income history

### 4. Budget Planning
- Set an overall **Monthly Budget**
- Set individual **Category Budgets** (Food, Transport, Shopping, etc.)
- Visual progress bars show how much of each budget has been consumed
- Budgets are tracked per month/year, so history is preserved

### 5. Analytics Dashboard
- Total Income, Total Expenses, and Savings for the current month
- **Pie chart** of category-wise spending
- **Bar chart** of the last 6 months' spending trend

### 6. Search & Filters
- Search transactions by category/source or description
- Filter by transaction type (All / Expense / Income)
- Filter by category/source
- Filter by month (date picker)

### 7. Notifications
- **Budget Limit Alerts** — a local notification is triggered automatically when an expense pushes a category or the overall monthly budget over its limit
- **Daily Expense Reminder** — an optional, toggleable daily local notification (default 8 PM) reminding the user to log expenses

### 8. Offline Support
- The app is **fully offline-first** — all data (users, expenses, income, budgets, session) is stored locally using **Hive**
- No internet connection is required at any point; there is no remote backend (no Firebase)

---

## 🛠 Tech Stack

| Layer              | Technology              |
|--------------------|--------------------------|
| Framework          | Flutter                 |
| State Management   | Provider                |
| Local Database     | Hive (NoSQL, offline)   |
| Charts             | fl_chart                |
| Notifications      | flutter_local_notifications + timezone |
| Auth Hashing       | crypto (SHA-256)        |
| Unique IDs         | uuid                     |
| Session Storage    | Hive box (`session`)    |

---

## 📁 Project Structure

```
lib/
├── main.dart                       # App entry point, Hive init, Providers
├── models/                         # Hive data models + generated adapters
│   ├── user_model.dart
│   ├── expense_model.dart
│   ├── income_model.dart
│   └── budget_model.dart
├── providers/                      # State management (business logic)
│   ├── auth_provider.dart
│   ├── expense_provider.dart
│   ├── income_provider.dart
│   └── budget_provider.dart
├── services/
│   └── notification_service.dart   # Local notifications
├── screens/
│   ├── splash_screen.dart          # Session check / auto-login
│   ├── home_screen.dart            # Bottom navigation shell
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart   # Analytics (charts + summary)
│   ├── transactions/
│   │   └── transactions_screen.dart # Search, filters, combined list
│   ├── expense/
│   │   └── add_edit_expense_screen.dart
│   ├── income/
│   │   └── add_edit_income_screen.dart
│   ├── budget/
│   │   └── budget_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/                         # Reusable UI components
│   ├── custom_text_field.dart
│   ├── summary_card.dart
│   └── transaction_tile.dart
└── utils/
    ├── constants.dart               # Categories, colors, icons
    └── helpers.dart                 # Currency/date formatting
```

This follows a simple **Clean Architecture** style separation:
- **Models** — pure data classes (Hive entities)
- **Providers** — business logic & state (the "domain"/"data" layer combined for simplicity)
- **Screens/Widgets** — presentation layer (UI only, no direct database access)

---

## 🚀 Setup Instructions

### 1. Create the project & copy files
```bash
flutter create expense_tracker
cd expense_tracker
```
Copy the contents of this `lib/` folder and `pubspec.yaml` into your newly created project (overwrite the defaults).

### 2. Install dependencies
```bash
flutter pub get
```

### 3. (Optional) Regenerate Hive adapters
The `.g.dart` adapter files are already included and ready to use. If you add/change any model fields later, regenerate them with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Enable Notifications on Android
Open `android/app/src/main/AndroidManifest.xml` and add the following **inside the `<manifest>` tag, above `<application>`**:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

And add the following **inside the `<application>` tag** (after the main `<activity>` block):

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 5. Run the app
```bash
flutter run
```

---

## 📱 User Flow

1. **Splash Screen** checks if a session already exists → goes to **Home** if logged in, otherwise **Login**.
2. **Register/Login** — creates a local account (stored in Hive, password hashed).
3. **Dashboard** — shows monthly income, expenses, savings, category pie chart, and a 6-month spending trend bar chart.
4. **Transactions** — combined list of all expenses & income with search, type/category/month filters, and a "+" button to add a new Expense or Income.
5. **Budget** — set an overall monthly budget and per-category budgets; progress bars turn orange/red as spending approaches/exceeds the limit. Exceeding a budget while adding an expense triggers a push notification.
6. **Profile** — shows account info & lifetime totals, toggle for the daily expense reminder notification, and logout.

---

## ✅ Requirements Coverage

| Requirement                          | Status | Notes |
|---------------------------------------|--------|-------|
| User Registration                      | ✅ | |
| Login                                  | ✅ | |
| Secure Authentication                  | ✅ | Passwords never stored in plain text — SHA-256 hash + unique per-user random salt |
| Persistent Sessions                    | ✅ | Session stored in Hive `session` box, restored on app launch via `SplashScreen` |
| Expense CRUD + history                 | ✅ | Amount, Category, Date, Payment Method, Description |
| Income CRUD + history                  | ✅ | Amount, Source, Date, Description |
| Set Monthly Budget                     | ✅ | |
| Set Category Budgets                   | ✅ | |
| Track Budget Consumption               | ✅ | Progress bars (green/orange/red) per category & overall |
| Total Income / Expenses / Savings      | ✅ | Current month, shown on Dashboard |
| Monthly Spending Trends                | ✅ | Bar chart, last 6 months |
| Category-wise Spending                 | ✅ | Pie chart, current month |
| Search Transactions                    | ✅ | Searches category/source & description |
| Filter by Date                         | ✅ | Month picker with clear (X) button |
| Filter by Category                     | ✅ | Dropdown filter |
| Budget Limit Alerts                    | ✅ | Local notification when category/monthly budget is exceeded |
| Daily Expense Reminders                | ✅ | Toggleable in Profile, persisted, scheduled via `flutter_local_notifications` |
| Offline Storage                        | ✅ | All data in Hive — works fully without internet |
| "Sync when available"                  | ⚠️ | Not applicable — no remote backend is used (Firebase intentionally excluded as it's optional). All data lives locally on-device. |
| Clean Architecture                     | ✅ | models / providers / services / screens / widgets / utils |
| State Management                       | ✅ | Provider |
| Responsive UI                          | ✅ | Flexible layouts (`Expanded`, `ListView`, `Wrap`) — adapts to different screen sizes |
| Proper Navigation                      | ✅ | Splash → Auth/Home, bottom navigation, push/pushReplacement flows |

---

## 🔮 Possible Future Enhancements (Bonus)
- Biometric authentication (local_auth)
- Export reports as PDF
- Multi-currency support
- Light/Dark theme toggle
