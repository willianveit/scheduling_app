import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';

class SlotModel {
  final String slotId;
  final String storeId;
  final String? clientId;
  final String? mechanicId;
  final String appointmentTime;
  final String status;
  final String? clientFeedback;
  final String? mechanicFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  SlotModel({
    required this.slotId,
    required this.storeId,
    this.clientId,
    this.mechanicId,
    required this.appointmentTime,
    required this.status,
    this.clientFeedback,
    this.mechanicFeedback,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory SlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotModel(
      slotId: doc.id,
      storeId: data['storeId'] ?? '',
      clientId: data['clientId'],
      mechanicId: data['mechanicId'],
      appointmentTime: data['appointmentTime'] ?? '',
      status: data['status'] ?? 'available',
      clientFeedback: data['clientFeedback'],
      mechanicFeedback: data['mechanicFeedback'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'clientId': clientId,
      'mechanicId': mechanicId,
      'appointmentTime': appointmentTime,
      'status': status,
      'clientFeedback': clientFeedback,
      'mechanicFeedback': mechanicFeedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert from domain entity
  factory SlotModel.fromEntity(Slot slot) {
    return SlotModel(
      slotId: slot.slotId,
      storeId: slot.storeId,
      clientId: slot.clientId,
      mechanicId: slot.mechanicId,
      appointmentTime: slot.appointmentTime,
      status: slot.status.toJson(),
      clientFeedback: slot.clientFeedback,
      mechanicFeedback: slot.mechanicFeedback,
      createdAt: slot.createdAt,
      updatedAt: slot.updatedAt,
    );
  }

  // Convert to domain entity
  Slot toEntity() {
    return Slot(
      slotId: slotId,
      storeId: storeId,
      clientId: clientId,
      mechanicId: mechanicId,
      appointmentTime: appointmentTime,
      status: AppointmentStatus.fromJson(status),
      clientFeedback: clientFeedback,
      mechanicFeedback: mechanicFeedback,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
