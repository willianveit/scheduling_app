import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class GetMechanicSlots {
  final SlotRepository repository;

  GetMechanicSlots(this.repository);

  Future<List<Slot>> call(String mechanicId) async {
    return await repository.getSlotsByMechanic(mechanicId);
  }
}
