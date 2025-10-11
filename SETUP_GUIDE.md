# SchedulingApp - Setup Guide

## Overview

This is a Flutter application built with Clean Architecture, Firebase Firestore, and Riverpod state management. The app supports two user roles: **Client** and **Mechanic**.

## Features

- **Client Flow**: Book appointments, view schedules, provide feedback
- **Mechanic Flow**: Manage appointments, accept/decline bookings, complete consultations
- **Real-time updates** with Firebase Firestore
- **Clean Architecture** for maintainability and scalability
- **Riverpod** for state management

---

## Prerequisites

1. **Flutter SDK** (version 3.9.2 or higher)
2. **Firebase Project** (create one at [Firebase Console](https://console.firebase.google.com/))
3. **Node.js** (optional, for Firebase tools)

---

## Firebase Setup

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Enable **Firestore Database** in the Firebase console
   - Go to **Firestore Database** → **Create database**
   - Start in **production mode** or **test mode** (for development)

### Step 2: Register Your Apps

#### For Web:

1. In Firebase Console, go to Project Settings
2. Add a Web app
3. Copy the Firebase configuration

#### For Android:

1. Add an Android app in Firebase Console
2. Download `google-services.json`
3. Place it in `android/app/`

#### For iOS:

1. Add an iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`

### Step 3: Configure Firebase in the Project

#### Update `lib/firebase_options.dart`:

Replace the placeholder values with your actual Firebase credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

#### Update `web/index.html`:

Replace the Firebase configuration in the script section with your credentials.

---

## Installation

### 1. Clone the Repository

```bash
cd /path/to/scheduling_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

#### For Web:

```bash
flutter run -d chrome
```

#### For Android:

```bash
flutter run -d android
```

#### For iOS:

```bash
flutter run -d ios
```

---

## Database Structure

The Firestore database follows this structure:

```
schedules (collection)
  └── {storeId} (document)
      └── slots (collection)
          └── {slotId} (document)
              - clientId: String
              - mechanicId: String
              - appointmentTime: String (e.g., "10:00-10:59")
              - status: String (available, scheduled, canceled, completed)
              - clientFeedback: String
              - mechanicFeedback: String
              - createdAt: Timestamp
              - updatedAt: Timestamp
```

---

## Seeding Mock Data

To populate the database with test data:

### Option 1: Automatic Initialization (Recommended for Testing)

Add this to your `main.dart` after Firebase initialization:

```dart
import 'package:scheduling_app/core/utils/database_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize with mock data (only for development/testing)
  await DatabaseInitializer.initializeWithMockData(FirebaseFirestore.instance);

  runApp(const ProviderScope(child: MyApp()));
}
```

### Option 2: Manual Seeding

Create a separate script or use the Flutter DevTools console:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/core/utils/firestore_seeder.dart';

final seeder = FirestoreSeeder(FirebaseFirestore.instance);
await seeder.seedDatabase(); // Seeds with 20 mock slots
```

### Option 3: Reset Database

```dart
await seeder.resetDatabase(); // Clears and re-seeds
```

---

## Project Structure

```
lib/
├── core/                    # Core utilities, constants, enums
│   ├── constants/
│   ├── enums/
│   └── utils/
├── domain/                  # Business logic layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/                    # Data layer
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── presentation/            # UI layer
│   ├── pages/
│   │   ├── user/           # Client pages
│   │   └── mechanic/       # Mechanic pages
│   ├── widgets/
│   └── providers/          # Riverpod providers
├── firebase_options.dart    # Firebase configuration
└── main.dart               # App entry point
```

---

## User Flows

### Client Flow:

1. **Role Selection** → Choose "Client"
2. **User Home Page** → View options
3. **Schedule Selection** → Browse and book available slots
4. **Feedback Page** → Provide feedback after appointment

### Mechanic Flow:

1. **Role Selection** → Choose "Mechanic"
2. **Mechanic Dashboard** → View statistics
3. **Slot Management** → View pending/active/completed appointments
4. **Appointment Details** → Accept/decline/complete appointments
5. **Feedback Page** → Add consultation notes

---

## Testing

### Test Users

The mock data includes:

- **Clients**: `client_1`, `client_2`, `client_3`
- **Mechanics**: `mechanic_1`, `mechanic_2`

You can change these in:

- `lib/presentation/providers/slot_providers.dart`
  - `currentUserIdProvider`
  - `currentMechanicIdProvider`

---

## Firestore Security Rules (Production)

For production, update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /schedules/{storeId}/slots/{slotId} {
      allow read: if true;
      allow write: if true; // Add authentication in production
    }
  }
}
```

**⚠️ Important**: Add proper authentication before deploying to production!

---

## Troubleshooting

### Issue: Firebase not initialized

**Solution**: Make sure Firebase is properly configured in `firebase_options.dart` and `web/index.html`

### Issue: No data appearing

**Solution**: Run the database seeder or manually add data through Firebase Console

### Issue: CORS errors on Web

**Solution**: This is expected in development. For production, deploy to Firebase Hosting or configure CORS properly

### Issue: Build errors

**Solution**: Run `flutter clean && flutter pub get`

---

## Production Deployment

### Web Deployment:

```bash
flutter build web --release
```

Deploy the `build/web` folder to:

- Firebase Hosting
- Netlify
- Vercel
- Or any static hosting service

### Android Deployment:

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Deployment:

```bash
flutter build ios --release
```

---

## Next Steps

1. **Add Authentication**: Implement Firebase Auth for user management
2. **Add Push Notifications**: Notify users of appointment updates
3. **Add Payment Integration**: If needed for appointments
4. **Implement Offline Support**: Cache data locally
5. **Add Analytics**: Track user behavior with Firebase Analytics

---

## Support

For issues or questions:

- Check the Flutter documentation: https://flutter.dev/docs
- Check the Firebase documentation: https://firebase.google.com/docs
- Check the Riverpod documentation: https://riverpod.dev

---

## License

This project is for demonstration purposes.
