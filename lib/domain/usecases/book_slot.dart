import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class BookSlot {
  final SlotRepository repository;

  BookSlot(this.repository);

  Future<void> call({
    required String storeId,
    required String slotId,
    required String clientId,
  }) async {
    return await repository.bookSlot(storeId, slotId, clientId);
  }
}
