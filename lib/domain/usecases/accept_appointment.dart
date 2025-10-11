import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class AcceptAppointment {
  final SlotRepository repository;

  AcceptAppointment(this.repository);

  Future<void> call({
    required String storeId,
    required String slotId,
    required String mechanicId,
  }) async {
    return await repository.acceptAppointment(storeId, slotId, mechanicId);
  }
}
