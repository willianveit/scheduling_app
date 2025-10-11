import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class CompleteAppointment {
  final SlotRepository repository;

  CompleteAppointment(this.repository);

  Future<void> call({required String storeId, required String slotId}) async {
    return await repository.completeAppointment(storeId, slotId);
  }
}
