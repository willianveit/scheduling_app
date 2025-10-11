import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scheduling_app/core/utils/firestore_seeder.dart';

/// Helper class to initialize database with mock data
/// Useful for development and testing
class DatabaseInitializer {
  static Future<void> initializeWithMockData(FirebaseFirestore firestore) async {
    try {
      debugPrint('🔧 Initializing database with mock data...');

      final seeder = FirestoreSeeder(firestore);

      // Check if database already has data
      final snapshot = await firestore.collection('schedules').limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint('📦 No existing data found. Seeding database...');
        await seeder.seedDatabase();
      } else {
        debugPrint('✅ Database already contains data.');
        debugPrint('💡 To reset the database, call DatabaseInitializer.resetDatabase()');
      }
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
    }
  }

  static Future<void> resetDatabase(FirebaseFirestore firestore) async {
    final seeder = FirestoreSeeder(firestore);
    await seeder.resetDatabase();
  }
}
