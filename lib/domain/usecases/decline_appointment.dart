import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class DeclineAppointment {
  final SlotRepository repository;

  DeclineAppointment(this.repository);

  Future<void> call({required String storeId, required String slotId}) async {
    return await repository.declineAppointment(storeId, slotId);
  }
}
