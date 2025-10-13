import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';

class MechanicModel {
  final String id;
  final String name;
  final String? email;
  final String? specialty;

  MechanicModel({required this.id, required this.name, this.email, this.specialty});

  factory MechanicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return MechanicModel(
      id: doc.id,
      name: data?['name'] ?? 'Mechanic ${doc.id}',
      email: data?['email'],
      specialty: data?['specialty'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'email': email, 'specialty': specialty};
  }

  Mechanic toEntity() {
    return Mechanic(id: id, name: name, email: email, specialty: specialty);
  }

  factory MechanicModel.fromEntity(Mechanic entity) {
    return MechanicModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      specialty: entity.specialty,
    );
  }
}
