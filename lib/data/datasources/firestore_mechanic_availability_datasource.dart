import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/data/models/mechanic_availability_model.dart';

class FirestoreMechanicAvailabilityDatasource {
  final FirebaseFirestore firestore;

  FirestoreMechanicAvailabilityDatasource({required this.firestore});

  CollectionReference _getMechanicAvailabilityCollection() {
    return firestore.collection('mechanic_availability');
  }

  Future<MechanicAvailabilityModel?> getMechanicAvailability(String mechanicId) async {
    try {
      final doc = await _getMechanicAvailabilityCollection().doc(mechanicId).get();
      if (!doc.exists) return null;
      return MechanicAvailabilityModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch mechanic availability: $e');
    }
  }

  Future<void> saveMechanicAvailability(MechanicAvailabilityModel availability) async {
    try {
      await _getMechanicAvailabilityCollection()
          .doc(availability.mechanicId)
          .set(availability.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save mechanic availability: $e');
    }
  }

  Future<void> deleteMechanicAvailability(String mechanicId) async {
    try {
      await _getMechanicAvailabilityCollection().doc(mechanicId).delete();
    } catch (e) {
      throw Exception('Failed to delete mechanic availability: $e');
    }
  }

  Stream<MechanicAvailabilityModel?> watchMechanicAvailability(String mechanicId) {
    return _getMechanicAvailabilityCollection()
        .doc(mechanicId)
        .snapshots()
        .map((doc) => doc.exists ? MechanicAvailabilityModel.fromFirestore(doc) : null);
  }
}
