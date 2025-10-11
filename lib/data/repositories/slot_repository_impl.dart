import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/data/datasources/firestore_slot_datasource.dart';
import 'package:scheduling_app/data/models/slot_model.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';

class SlotRepositoryImpl implements SlotRepository {
  final FirestoreSlotDatasource datasource;

  SlotRepositoryImpl({required this.datasource});

  @override
  Future<List<Slot>> getSlots(String storeId) async {
    final models = await datasource.getSlots(storeId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Slot?> getSlotById(String storeId, String slotId) async {
    final model = await datasource.getSlotById(storeId, slotId);
    return model?.toEntity();
  }

  @override
  Future<List<Slot>> getSlotsByStatus(String storeId, AppointmentStatus status) async {
    final models = await datasource.getSlotsByStatus(storeId, status.toJson());
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Slot>> getSlotsByMechanic(String mechanicId) async {
    final models = await datasource.getSlotsByMechanic(mechanicId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Slot>> getSlotsByClient(String clientId) async {
    final models = await datasource.getSlotsByClient(clientId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createSlot(Slot slot) async {
    final model = SlotModel.fromEntity(slot);
    await datasource.createSlot(slot.storeId, model);
  }

  @override
  Future<void> updateSlot(Slot slot) async {
    final model = SlotModel.fromEntity(slot);
    await datasource.updateSlot(slot.storeId, model);
  }

  @override
  Future<void> deleteSlot(String storeId, String slotId) async {
    await datasource.deleteSlot(storeId, slotId);
  }

  @override
  Future<void> bookSlot(String storeId, String slotId, String clientId) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    if (slot.status != AppointmentStatus.available) {
      throw Exception('Slot is not available');
    }

    final updatedSlot = slot.copyWith(
      clientId: clientId,
      status: AppointmentStatus.scheduled,
      updatedAt: DateTime.now(),
    );

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> acceptAppointment(String storeId, String slotId, String mechanicId) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(mechanicId: mechanicId, updatedAt: DateTime.now());

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> declineAppointment(String storeId, String slotId) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(
      status: AppointmentStatus.canceled,
      updatedAt: DateTime.now(),
    );

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> completeAppointment(String storeId, String slotId) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(
      status: AppointmentStatus.completed,
      updatedAt: DateTime.now(),
    );

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> cancelAppointment(String storeId, String slotId) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(
      status: AppointmentStatus.canceled,
      clientId: null,
      mechanicId: null,
      updatedAt: DateTime.now(),
    );

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> addClientFeedback(String storeId, String slotId, String feedback) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(clientFeedback: feedback, updatedAt: DateTime.now());

    await updateSlot(updatedSlot);
  }

  @override
  Future<void> addMechanicFeedback(String storeId, String slotId, String feedback) async {
    final slot = await getSlotById(storeId, slotId);
    if (slot == null) {
      throw Exception('Slot not found');
    }

    final updatedSlot = slot.copyWith(mechanicFeedback: feedback, updatedAt: DateTime.now());

    await updateSlot(updatedSlot);
  }

  @override
  Stream<List<Slot>> watchSlots(String storeId) {
    return datasource
        .watchSlots(storeId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }
}
