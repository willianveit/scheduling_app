import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/core/constants/firebase_constants.dart';
import 'package:scheduling_app/data/models/slot_model.dart';

class FirestoreSlotDatasource {
  final FirebaseFirestore firestore;

  FirestoreSlotDatasource({required this.firestore});

  CollectionReference _getSlotsCollection(String storeId) {
    return firestore
        .collection(FirebaseConstants.schedulesCollection)
        .doc(storeId)
        .collection(FirebaseConstants.slotsCollection);
  }

  Future<List<SlotModel>> getSlots(String storeId) async {
    try {
      final snapshot = await _getSlotsCollection(storeId).get();
      return snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch slots: $e');
    }
  }

  Future<SlotModel?> getSlotById(String storeId, String slotId) async {
    try {
      final doc = await _getSlotsCollection(storeId).doc(slotId).get();
      if (!doc.exists) return null;
      return SlotModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch slot: $e');
    }
  }

  Future<List<SlotModel>> getSlotsByStatus(String storeId, String status) async {
    try {
      final snapshot = await _getSlotsCollection(
        storeId,
      ).where(FirebaseConstants.status, isEqualTo: status).get();
      return snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch slots by status: $e');
    }
  }

  Future<List<SlotModel>> getSlotsByMechanic(String mechanicId) async {
    try {
      // This is a simplified version - in production, you might need to use collection group queries
      final stores = await firestore.collection(FirebaseConstants.schedulesCollection).get();
      final List<SlotModel> allSlots = [];

      for (var store in stores.docs) {
        final snapshot = await store.reference
            .collection(FirebaseConstants.slotsCollection)
            .where(FirebaseConstants.mechanicId, isEqualTo: mechanicId)
            .get();
        allSlots.addAll(snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)));
      }

      return allSlots;
    } catch (e) {
      throw Exception('Failed to fetch slots by mechanic: $e');
    }
  }

  Future<List<SlotModel>> getSlotsByClient(String clientId) async {
    try {
      // This is a simplified version - in production, you might need to use collection group queries
      final stores = await firestore.collection(FirebaseConstants.schedulesCollection).get();
      final List<SlotModel> allSlots = [];

      for (var store in stores.docs) {
        final snapshot = await store.reference
            .collection(FirebaseConstants.slotsCollection)
            .where(FirebaseConstants.clientId, isEqualTo: clientId)
            .get();
        allSlots.addAll(snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)));
      }

      return allSlots;
    } catch (e) {
      throw Exception('Failed to fetch slots by client: $e');
    }
  }

  Future<void> createSlot(String storeId, SlotModel slot) async {
    try {
      await _getSlotsCollection(storeId).doc(slot.slotId).set(slot.toFirestore());
    } catch (e) {
      throw Exception('Failed to create slot: $e');
    }
  }

  Future<void> updateSlot(String storeId, SlotModel slot) async {
    try {
      await _getSlotsCollection(storeId).doc(slot.slotId).update(slot.toFirestore());
    } catch (e) {
      throw Exception('Failed to update slot: $e');
    }
  }

  Future<void> deleteSlot(String storeId, String slotId) async {
    try {
      await _getSlotsCollection(storeId).doc(slotId).delete();
    } catch (e) {
      throw Exception('Failed to delete slot: $e');
    }
  }

  Stream<List<SlotModel>> watchSlots(String storeId) {
    return _getSlotsCollection(storeId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => SlotModel.fromFirestore(doc)).toList(),
    );
  }
}
