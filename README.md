# SchedulingApp

A modern, full-featured appointment scheduling application built with Flutter, Firebase Firestore, and Riverpod. Supports Web, iOS, and Android platforms.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange.svg)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-purple.svg)

## 🎯 Features

### For Clients:

- ✅ Browse available time slots
- ✅ Book appointments instantly
- ✅ View appointment history
- ✅ Provide feedback after consultations

### For Mechanics:

- ✅ View dashboard with statistics
- ✅ Manage pending appointments
- ✅ Accept or decline bookings
- ✅ Complete consultations
- ✅ Add consultation notes

### Technical Features:

- 🏗️ **Clean Architecture** - Separation of concerns with domain, data, and presentation layers
- 🔄 **Real-time Updates** - Live sync with Firebase Firestore
- 📱 **Multi-platform** - Web, iOS, and Android support
- 🎨 **Material Design 3** - Modern and beautiful UI
- 🧪 **Mock Data Generator** - Easy testing with sample data
- 📦 **Modular Structure** - Scalable and maintainable codebase

## 🏗️ Architecture

The app follows **Clean Architecture** principles:

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│  (UI, Widgets, State Management)    │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│          Domain Layer               │
│  (Entities, Use Cases, Repositories)│
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│           Data Layer                │
│  (Models, Data Sources, Repositories)│
└─────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── core/                        # Core utilities and constants
│   ├── constants/               # App and Firebase constants
│   ├── enums/                   # Enums (AppointmentStatus, UserRole)
│   └── utils/                   # Utilities (date formatter, mock data)
│
├── domain/                      # Business Logic Layer
│   ├── entities/                # Pure business entities
│   │   ├── slot.dart
│   │   └── feedback.dart
│   ├── repositories/            # Repository interfaces
│   │   └── slot_repository.dart
│   └── usecases/                # Business use cases
│       ├── get_available_slots.dart
│       ├── book_slot.dart
│       ├── accept_appointment.dart
│       └── ...
│
├── data/                        # Data Layer
│   ├── models/                  # Data models
│   │   └── slot_model.dart
│   ├── datasources/             # Data sources
│   │   └── firestore_slot_datasource.dart
│   └── repositories/            # Repository implementations
│       └── slot_repository_impl.dart
│
├── presentation/                # Presentation Layer
│   ├── pages/                   # App pages
│   │   ├── user/               # Client pages
│   │   │   ├── user_home_page.dart
│   │   │   ├── schedule_selection_page.dart
│   │   │   └── feedback_page.dart
│   │   └── mechanic/           # Mechanic pages
│   │       ├── mechanic_dashboard_page.dart
│   │       ├── slot_management_page.dart
│   │       └── appointment_details_page.dart
│   ├── widgets/                # Reusable widgets
│   │   └── common/
│   └── providers/              # Riverpod providers
│       ├── firebase_providers.dart
│       ├── repository_providers.dart
│       └── slot_providers.dart
│
├── firebase_options.dart        # Firebase configuration
└── main.dart                   # App entry point
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase project
- Dart SDK

### Installation

1. **Clone and navigate to the project:**

   ```bash
   cd scheduling_app
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**

   - Follow the detailed instructions in [SETUP_GUIDE.md](SETUP_GUIDE.md)
   - Update `lib/firebase_options.dart` with your Firebase credentials
   - Update `web/index.html` with your Firebase config (for Web)

4. **Run the app:**

   ```bash
   # For Web
   flutter run -d chrome

   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios
   ```

## 📊 Database Structure

### Firestore Collections:

```
schedules/{storeId}/slots/{slotId}
├── clientId: String
├── mechanicId: String
├── appointmentTime: String (e.g., "10:00-10:59")
├── status: Enum (available, scheduled, canceled, completed)
├── clientFeedback: String
├── mechanicFeedback: String
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

## 🧪 Testing with Mock Data

The app includes a mock data generator for easy testing:

```dart
import 'package:scheduling_app/core/utils/database_initializer.dart';

// In your main.dart (after Firebase initialization)
await DatabaseInitializer.initializeWithMockData(FirebaseFirestore.instance);
```

This will create 20 sample slots with various statuses.

## 📱 Screenshots & User Flows

### Client Flow:

1. **Role Selection** → Select "Client"
2. **Home Page** → Choose to book or view appointments
3. **Schedule Selection** → Browse available slots
4. **Book Appointment** → Confirm booking
5. **Feedback** → Provide feedback (optional)

### Mechanic Flow:

1. **Role Selection** → Select "Mechanic"
2. **Dashboard** → View statistics
3. **Slot Management** → Browse pending/active appointments
4. **Appointment Details** → Accept/decline/complete
5. **Feedback** → Add consultation notes

## 🔧 Configuration

### Time Slots

Edit time slots in `lib/core/constants/app_constants.dart`:

```dart
static const List<String> timeSlots = [
  '09:00-09:59',
  '10:00-10:59',
  // Add more...
];
```

### Store ID

Change the default store ID in the same file:

```dart
static const String defaultStoreId = 'store_001';
```

## 🔐 Security

**⚠️ Important**: The current setup is for development only. Before going to production:

1. Implement Firebase Authentication
2. Update Firestore Security Rules
3. Add proper user role management
4. Implement data validation
5. Add rate limiting

## 📚 Dependencies

Key dependencies used:

- `flutter_riverpod` - State management
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Firestore database
- `uuid` - Generate unique IDs
- `intl` - Date formatting

See [pubspec.yaml](pubspec.yaml) for the complete list.

## 🛠️ Development

### Code Generation

If you add new providers or models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build

If you encounter issues:

```bash
flutter clean
flutter pub get
```

## 📖 Documentation

- [Setup Guide](SETUP_GUIDE.md) - Detailed setup instructions
- [Architecture Guide](docs/ARCHITECTURE.md) - Coming soon
- [API Documentation](docs/API.md) - Coming soon

## 🤝 Contributing

This is a demonstration project. Feel free to use it as a template for your own projects.

## 📄 License

This project is created for demonstration purposes.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend infrastructure
- Riverpod for state management

## 📞 Support

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

**Built with ❤️ using Flutter**
