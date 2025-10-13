import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper function to seed sample mechanics into Firestore
/// This should be called once during development/setup
Future<void> seedMechanics(FirebaseFirestore firestore) async {
  final mechanics = [
    {'name': 'John Smith', 'email': 'john.smith@example.com', 'specialty': 'Engine Specialist'},
    {
      'name': 'Maria Garcia',
      'email': 'maria.garcia@example.com',
      'specialty': 'Transmission Expert',
    },
    {
      'name': 'David Johnson',
      'email': 'david.johnson@example.com',
      'specialty': 'Electrical Systems',
    },
    {
      'name': 'Sarah Williams',
      'email': 'sarah.williams@example.com',
      'specialty': 'Brake Specialist',
    },
    {
      'name': 'Michael Brown',
      'email': 'michael.brown@example.com',
      'specialty': 'General Maintenance',
    },
  ];

  final mechanicsCollection = firestore.collection('mechanics');

  for (var mechanic in mechanics) {
    await mechanicsCollection.add(mechanic);
  }

  print('✅ Successfully seeded ${mechanics.length} mechanics');
}
