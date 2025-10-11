import 'package:scheduling_app/core/enums/appointment_status.dart';

class Slot {
  final String slotId;
  final String storeId;
  final String? clientId;
  final String? mechanicId;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? clientFeedback;
  final String? mechanicFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Slot({
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

  Slot copyWith({
    String? slotId,
    String? storeId,
    String? clientId,
    String? mechanicId,
    String? appointmentTime,
    AppointmentStatus? status,
    String? clientFeedback,
    String? mechanicFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Slot(
      slotId: slotId ?? this.slotId,
      storeId: storeId ?? this.storeId,
      clientId: clientId ?? this.clientId,
      mechanicId: mechanicId ?? this.mechanicId,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      clientFeedback: clientFeedback ?? this.clientFeedback,
      mechanicFeedback: mechanicFeedback ?? this.mechanicFeedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Slot && other.slotId == slotId;
  }

  @override
  int get hashCode => slotId.hashCode;
}
