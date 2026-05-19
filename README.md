# Expense Tracker

A Flutter expense manager with **local SQLite storage** and **cloud sync**.

## Features

- Phone + OTP login
- Dashboard (income, expenses, recent transactions)
- Add/delete transactions and categories
- Sync to backend (upload & delete)
- Monthly budget limit with local notifications

## Tech Stack

Flutter · BLoC · sqflite · shared_preferences · flutter_local_notifications

## Getting Started

```bash
flutter pub get
flutter run
```

**API base URL:** `https://appskilltest.zybotech.in`

Use `Flutter Skill Test.postman_collection.json` for API reference.

## Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`
