import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart';

class MechanicModel {
  final String id;
  final String name;
  final String? email;
  final String? specialty;
  final List<DayAvailability>? availability;
  final DateTime? availabilityUpdatedAt;

  MechanicModel({
    required this.id,
    required this.name,
    this.email,
    this.specialty,
    this.availability,
    this.availabilityUpdatedAt,
  });

  factory MechanicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    List<DayAvailability>? availability;
    if (data?['availability'] != null) {
      availability = (data!['availability'] as List)
          .map((item) => DayAvailability.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    DateTime? availabilityUpdatedAt;
    if (data?['availabilityUpdatedAt'] != null) {
      if (data!['availabilityUpdatedAt'] is Timestamp) {
        availabilityUpdatedAt = (data['availabilityUpdatedAt'] as Timestamp).toDate();
      } else if (data['availabilityUpdatedAt'] is String) {
        availabilityUpdatedAt = DateTime.parse(data['availabilityUpdatedAt'] as String);
      }
    }

    return MechanicModel(
      id: doc.id,
      name: data?['name'] ?? 'Mechanic ${doc.id}',
      email: data?['email'],
      specialty: data?['specialty'],
      availability: availability,
      availabilityUpdatedAt: availabilityUpdatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'specialty': specialty,
      if (availability != null) 'availability': availability!.map((a) => a.toJson()).toList(),
      if (availabilityUpdatedAt != null)
        'availabilityUpdatedAt': Timestamp.fromDate(availabilityUpdatedAt!),
    };
  }

  Mechanic toEntity() {
    return Mechanic(
      id: id,
      name: name,
      email: email,
      specialty: specialty,
      availability: availability,
      availabilityUpdatedAt: availabilityUpdatedAt,
    );
  }

  factory MechanicModel.fromEntity(Mechanic entity) {
    return MechanicModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      specialty: entity.specialty,
      availability: entity.availability,
      availabilityUpdatedAt: entity.availabilityUpdatedAt,
    );
  }
}
