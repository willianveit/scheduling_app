import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/utils/mock_data_generator.dart';
import 'package:scheduling_app/data/models/slot_model.dart';

class FirestoreSeeder {
  final FirebaseFirestore firestore;

  FirestoreSeeder(this.firestore);

  /// Seed the database with mock data
  Future<void> seedDatabase() async {
    try {
      debugPrint('Starting database seeding...');

      // Generate mock slots for the default store
      final mockSlots = MockDataGenerator.generateMockSlots(AppConstants.defaultStoreId, count: 20);

      // Create a batch to optimize writes
      final batch = firestore.batch();

      for (final slot in mockSlots) {
        final slotModel = SlotModel.fromEntity(slot);
        final docRef = firestore
            .collection('schedules')
            .doc(AppConstants.defaultStoreId)
            .collection('slots')
            .doc(slot.slotId);

        batch.set(docRef, slotModel.toFirestore());
      }

      // Commit the batch
      await batch.commit();

      debugPrint('✅ Database seeded successfully with ${mockSlots.length} slots');
    } catch (e) {
      debugPrint('❌ Error seeding database: $e');
      rethrow;
    }
  }

  /// Clear all slots from the database
  Future<void> clearDatabase() async {
    try {
      debugPrint('Clearing database...');

      final slotsSnapshot = await firestore
          .collection('schedules')
          .doc(AppConstants.defaultStoreId)
          .collection('slots')
          .get();

      final batch = firestore.batch();

      for (final doc in slotsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('✅ Database cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing database: $e');
      rethrow;
    }
  }

  /// Reset database (clear and seed)
  Future<void> resetDatabase() async {
    await clearDatabase();
    await seedDatabase();
  }
}
