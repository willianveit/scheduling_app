import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class GetAvailableSlots {
  final SlotRepository repository;

  GetAvailableSlots(this.repository);

  Future<List<Slot>> call(String storeId) async {
    return await repository.getSlotsByStatus(storeId, AppointmentStatus.available);
  }
}
