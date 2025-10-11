# Quick Reference Guide

## 🚀 Getting Started (5 Minutes)

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

Update these files with your Firebase credentials:

- `lib/firebase_options.dart`
- `web/index.html` (for Web)

Get credentials from: https://console.firebase.google.com/

### 3. Run the App

```bash
flutter run -d chrome  # For Web
flutter run            # For mobile (if device connected)
```

---

## 📝 Key Files to Know

| File                                             | Purpose                   |
| ------------------------------------------------ | ------------------------- |
| `lib/main.dart`                                  | App entry point           |
| `lib/firebase_options.dart`                      | Firebase config           |
| `lib/core/constants/app_constants.dart`          | Time slots, store ID      |
| `lib/presentation/providers/slot_providers.dart` | Current user/mechanic IDs |

---

## 🎭 Testing with Mock Data

Add to `main.dart` after Firebase initialization:

```dart
await DatabaseInitializer.initializeWithMockData(
  FirebaseFirestore.instance
);
```

---

## 👥 Test Accounts

### Clients:

- `client_1`
- `client_2`
- `client_3`

### Mechanics:

- `mechanic_1`
- `mechanic_2`

Change current user in:

- `lib/presentation/providers/slot_providers.dart`

---

## 🔄 Common Commands

```bash
# Get dependencies
flutter pub get

# Run on Web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Clean build
flutter clean && flutter pub get

# Build for production
flutter build web --release
flutter build apk --release
flutter build ios --release

# Format code
dart format lib/

# Analyze code
flutter analyze
```

---

## 📊 Firestore Structure

```
schedules/
  └── store_001/
      └── slots/
          └── {slotId}/
              - appointmentTime: "10:00-10:59"
              - status: "available" | "scheduled" | "canceled" | "completed"
              - clientId: "client_1"
              - mechanicId: "mechanic_1"
              - clientFeedback: "..."
              - mechanicFeedback: "..."
```

---

## 🎨 Customization Quick Tips

### Change App Colors

`lib/main.dart`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Change this
),
```

### Add More Time Slots

`lib/core/constants/app_constants.dart`:

```dart
static const List<String> timeSlots = [
  '09:00-09:59',
  '10:00-10:59',
  // Add more here
];
```

### Change Store ID

`lib/core/constants/app_constants.dart`:

```dart
static const String defaultStoreId = 'your_store_id';
```

---

## 🐛 Troubleshooting

### Firebase not working?

✅ Check credentials in `firebase_options.dart`  
✅ Enable Firestore in Firebase Console  
✅ Check Firestore rules allow read/write

### No data showing?

✅ Run database seeder (see Testing section)  
✅ Check Firebase Console for data  
✅ Check internet connection

### Build errors?

```bash
flutter clean
flutter pub get
```

### Web CORS errors?

✅ Normal in development  
✅ Deploy to hosting for production

---

## 📁 Project Structure Overview

```
lib/
├── core/           # Constants, enums, utils
├── domain/         # Business logic (entities, use cases)
├── data/           # Data layer (models, repositories)
└── presentation/   # UI (pages, widgets, providers)
```

---

## 🔗 Useful Links

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Setup Guide](SETUP_GUIDE.md) - Detailed instructions

---

## 💡 Key Concepts

### State Management (Riverpod)

Providers are in `lib/presentation/providers/`

### Clean Architecture

- **Domain**: Business rules (what the app does)
- **Data**: Data sources and repositories (where data comes from)
- **Presentation**: UI and state management (what users see)

### Real-time Updates

Firestore streams automatically update the UI when data changes!

---

## 📞 Need Help?

1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions
2. Check [README.md](README.md) for project overview
3. Review Flutter/Firebase documentation

---

**Happy Coding! 🎉**
