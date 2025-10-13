import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart';

class MechanicAvailabilityModel {
  final String mechanicId;
  final String storeId;
  final List<Map<String, dynamic>> availability;
  final DateTime updatedAt;

  MechanicAvailabilityModel({
    required this.mechanicId,
    required this.storeId,
    required this.availability,
    required this.updatedAt,
  });

  factory MechanicAvailabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MechanicAvailabilityModel(
      mechanicId: doc.id,
      storeId: data['storeId'] ?? '',
      availability: List<Map<String, dynamic>>.from(data['availability'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mechanicId': mechanicId,
      'storeId': storeId,
      'availability': availability,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MechanicAvailabilityModel.fromEntity(MechanicAvailability entity) {
    return MechanicAvailabilityModel(
      mechanicId: entity.mechanicId,
      storeId: entity.storeId,
      availability: entity.availability.map((day) => day.toJson()).toList(),
      updatedAt: entity.updatedAt,
    );
  }

  MechanicAvailability toEntity() {
    return MechanicAvailability(
      mechanicId: mechanicId,
      storeId: storeId,
      availability: availability.map((dayData) => DayAvailability.fromJson(dayData)).toList(),
      updatedAt: updatedAt,
    );
  }
}
