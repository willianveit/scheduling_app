# Firebase Setup Checklist

Follow this checklist to get your SchedulingApp running with Firebase.

## 📋 Pre-Setup

- [ ] Have a Google account
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)

---

## 🔥 Step 1: Create Firebase Project

- [ ] Click "Add project" or "Create a project"
- [ ] Enter project name (e.g., "scheduling-app")
- [ ] Accept terms and click "Continue"
- [ ] Disable Google Analytics (or enable if you want)
- [ ] Click "Create project"
- [ ] Wait for project creation
- [ ] Click "Continue"

---

## 📊 Step 2: Enable Firestore Database

- [ ] In Firebase Console, click "Firestore Database" in left menu
- [ ] Click "Create database"
- [ ] Choose "Start in test mode" (for development)
  - Test mode allows read/write for 30 days
  - You can change rules later
- [ ] Click "Next"
- [ ] Choose a location (closest to your users)
- [ ] Click "Enable"
- [ ] Wait for database creation

---

## 🌐 Step 3: Register Web App

- [ ] In Project Overview, click the Web icon `</>`
- [ ] Enter app nickname (e.g., "scheduling-app-web")
- [ ] Check "Also set up Firebase Hosting" (optional)
- [ ] Click "Register app"
- [ ] Copy the Firebase configuration object:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
};
```

- [ ] Keep this configuration - you'll need it!
- [ ] Click "Continue to console"

---

## 📱 Step 4: Configure Web App

### Update `web/index.html`:

- [ ] Open `web/index.html` in your editor
- [ ] Find the Firebase configuration section (around line 46)
- [ ] Replace the placeholder values with your configuration:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef",
};
```

- [ ] Save the file

### Update `lib/firebase_options.dart`:

- [ ] Open `lib/firebase_options.dart` in your editor
- [ ] Update the `web` configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
);
```

- [ ] Save the file

---

## 🤖 Step 5: (Optional) Register Android App

- [ ] In Firebase Console, click "Add app" → Android icon
- [ ] Enter Android package name: `com.example.scheduling_app`
  - Find in `android/app/build.gradle.kts` as `namespace`
- [ ] Enter app nickname (optional)
- [ ] Click "Register app"
- [ ] Download `google-services.json`
- [ ] Place file in `android/app/` directory
- [ ] Follow Firebase setup instructions
- [ ] Update `lib/firebase_options.dart` android section

---

## 🍎 Step 6: (Optional) Register iOS App

- [ ] In Firebase Console, click "Add app" → iOS icon
- [ ] Enter iOS bundle ID: `com.example.schedulingApp`
  - Find in `ios/Runner.xcodeproj` or `Info.plist`
- [ ] Enter app nickname (optional)
- [ ] Click "Register app"
- [ ] Download `GoogleService-Info.plist`
- [ ] Open Xcode and drag file into `ios/Runner/` directory
- [ ] Make sure "Copy items if needed" is checked
- [ ] Update `lib/firebase_options.dart` ios section

---

## 🗄️ Step 7: Set Firestore Rules

For development, use test mode rules:

- [ ] In Firebase Console, go to "Firestore Database"
- [ ] Click "Rules" tab
- [ ] Use this for development (allows all read/write):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

- [ ] Click "Publish"

> ⚠️ **Warning**: These rules are insecure. Update before production!

---

## 🧪 Step 8: Seed Database with Test Data

After configuration, seed your database:

### Option A: Automatic (Recommended)

- [ ] Open `lib/main.dart`
- [ ] Add after Firebase initialization:

```dart
await DatabaseInitializer.initializeWithMockData(
  FirebaseFirestore.instance
);
```

- [ ] Run the app once to seed data
- [ ] Remove or comment out the line after first run

### Option B: Manual via Firebase Console

- [ ] Go to Firestore Database in Firebase Console
- [ ] Create collection: `schedules`
- [ ] Add document with ID: `store_001`
- [ ] Create subcollection: `slots`
- [ ] Add documents manually with fields:
  - `appointmentTime` (string): "10:00-10:59"
  - `status` (string): "available"
  - `createdAt` (timestamp): now
  - `updatedAt` (timestamp): now

---

## ✅ Step 9: Test Your Setup

- [ ] Run `flutter pub get`
- [ ] Run `flutter run -d chrome`
- [ ] App should start without errors
- [ ] Select a role (Client or Mechanic)
- [ ] Check if data loads
- [ ] Try booking an appointment (Client mode)
- [ ] Check Firebase Console to see if data was created

---

## 🐛 Troubleshooting

### App crashes on start?

- [ ] Check Firebase credentials are correct
- [ ] Verify Firestore is enabled
- [ ] Check console for error messages

### No data showing?

- [ ] Check Firestore rules allow read/write
- [ ] Verify database is seeded
- [ ] Check Firebase Console for data
- [ ] Check internet connection

### "Permission denied" errors?

- [ ] Update Firestore rules to allow access
- [ ] Make sure you're in test mode or have proper rules

### Firebase not initialized?

- [ ] Verify `firebase_options.dart` has correct values
- [ ] Check `web/index.html` has correct config
- [ ] Ensure Firebase SDK scripts are loaded (for Web)

---

## 🔐 Security Notes

### Current Setup (Development)

- ✅ Easy to test
- ❌ Not secure for production
- ❌ Anyone can read/write

### Before Production:

- [ ] Implement Firebase Authentication
- [ ] Update Firestore rules with authentication checks
- [ ] Add data validation rules
- [ ] Enable App Check
- [ ] Review security rules

Example secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /schedules/{storeId}/slots/{slotId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📝 Summary

After completing this checklist:

- ✅ Firebase project created
- ✅ Firestore database enabled
- ✅ Web app registered and configured
- ✅ Firebase credentials updated in project
- ✅ Test data seeded
- ✅ App tested and working

---

## 🎉 You're Done!

Your SchedulingApp is now connected to Firebase and ready to use!

**Next Steps:**

- Customize time slots in `lib/core/constants/app_constants.dart`
- Add more features
- Improve security before production
- Deploy to hosting

For more information:

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup guide
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick commands
- [README.md](README.md) - Project overview

**Need help?** Check Firebase documentation: https://firebase.google.com/docs
