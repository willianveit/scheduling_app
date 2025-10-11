import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:uuid/uuid.dart';

class MockDataGenerator {
  static const _uuid = Uuid();

  /// Generate mock slots for a store
  static List<Slot> generateMockSlots(String storeId, {int count = 20}) {
    final slots = <Slot>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final status = _getRandomStatus(i);
      final slotId = _uuid.v4();
      final timeSlot = AppConstants.timeSlots[i % AppConstants.timeSlots.length];

      slots.add(
        Slot(
          slotId: slotId,
          storeId: storeId,
          appointmentTime: timeSlot,
          status: status,
          clientId: status != AppointmentStatus.available ? 'client_${(i % 3) + 1}' : null,
          mechanicId:
              (status == AppointmentStatus.completed ||
                  (status == AppointmentStatus.scheduled && i % 2 == 0))
              ? 'mechanic_${(i % 2) + 1}'
              : null,
          clientFeedback: status == AppointmentStatus.completed
              ? 'Great service! Very helpful and professional.'
              : null,
          mechanicFeedback: status == AppointmentStatus.completed
              ? 'Customer was cooperative. Issue resolved successfully.'
              : null,
          createdAt: now.subtract(Duration(days: i)),
          updatedAt: now.subtract(Duration(hours: i)),
        ),
      );
    }

    return slots;
  }

  /// Generate a sample available slot
  static Slot generateAvailableSlot(String storeId, String timeSlot) {
    return Slot(
      slotId: _uuid.v4(),
      storeId: storeId,
      appointmentTime: timeSlot,
      status: AppointmentStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate a scheduled slot
  static Slot generateScheduledSlot(String storeId, String timeSlot, String clientId) {
    return Slot(
      slotId: _uuid.v4(),
      storeId: storeId,
      appointmentTime: timeSlot,
      status: AppointmentStatus.scheduled,
      clientId: clientId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static AppointmentStatus _getRandomStatus(int index) {
    // Create a distribution of statuses
    if (index < 5) {
      return AppointmentStatus.available;
    } else if (index < 12) {
      return AppointmentStatus.scheduled;
    } else if (index < 16) {
      return AppointmentStatus.completed;
    } else {
      return AppointmentStatus.canceled;
    }
  }
}
