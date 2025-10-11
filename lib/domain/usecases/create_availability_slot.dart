import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class CreateAvailabilitySlot {
  final SlotRepository repository;

  CreateAvailabilitySlot({required this.repository});

  /// Creates an available slot for a mechanic
  /// [storeId] - The store ID
  /// [mechanicId] - The mechanic ID who is available
  /// [appointmentTime] - The time slot (formatted string)
  Future<void> call({
    required String storeId,
    required String mechanicId,
    required String appointmentTime,
  }) async {
    final now = DateTime.now();

    // Generate a unique ID for the slot
    final slotId =
        '${mechanicId}_${appointmentTime.replaceAll(RegExp(r'[^0-9]'), '')}_${now.millisecondsSinceEpoch}';

    final slot = Slot(
      slotId: slotId,
      storeId: storeId,
      mechanicId: mechanicId,
      appointmentTime: appointmentTime,
      status: AppointmentStatus.available,
      createdAt: now,
      updatedAt: now,
    );

    await repository.createSlot(slot);
  }
}
