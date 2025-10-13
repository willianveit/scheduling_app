import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/data/models/mechanic_model.dart';

class FirestoreMechanicDatasource {
  final FirebaseFirestore firestore;

  FirestoreMechanicDatasource({required this.firestore});

  CollectionReference _getMechanicsCollection() {
    return firestore.collection('mechanics');
  }

  Future<List<MechanicModel>> getMechanics() async {
    try {
      final snapshot = await _getMechanicsCollection().get();
      return snapshot.docs.map((doc) => MechanicModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch mechanics: $e');
    }
  }

  Future<MechanicModel?> getMechanicById(String mechanicId) async {
    try {
      final doc = await _getMechanicsCollection().doc(mechanicId).get();
      if (!doc.exists) return null;
      return MechanicModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch mechanic: $e');
    }
  }

  Future<void> createMechanic(MechanicModel mechanic) async {
    try {
      await _getMechanicsCollection().doc(mechanic.id).set(mechanic.toFirestore());
    } catch (e) {
      throw Exception('Failed to create mechanic: $e');
    }
  }

  Stream<List<MechanicModel>> watchMechanics() {
    return _getMechanicsCollection().snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => MechanicModel.fromFirestore(doc)).toList(),
    );
  }
}
