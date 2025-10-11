import 'package:scheduling_app/core/enums/user_role.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class SubmitFeedback {
  final SlotRepository repository;

  SubmitFeedback(this.repository);

  Future<void> call({
    required String storeId,
    required String slotId,
    required String feedback,
    required UserRole userRole,
  }) async {
    if (userRole == UserRole.client) {
      return await repository.addClientFeedback(storeId, slotId, feedback);
    } else {
      return await repository.addMechanicFeedback(storeId, slotId, feedback);
    }
  }
}
