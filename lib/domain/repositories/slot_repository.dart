import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';

abstract class SlotRepository {
  /// Get all slots for a specific store
  Future<List<Slot>> getSlots(String storeId);

  /// Get a specific slot by ID
  Future<Slot?> getSlotById(String storeId, String slotId);

  /// Get slots filtered by status
  Future<List<Slot>> getSlotsByStatus(String storeId, AppointmentStatus status);

  /// Get slots for a specific mechanic
  Future<List<Slot>> getSlotsByMechanic(String mechanicId);

  /// Get slots for a specific client
  Future<List<Slot>> getSlotsByClient(String clientId);

  /// Create a new slot
  Future<void> createSlot(Slot slot);

  /// Update an existing slot
  Future<void> updateSlot(Slot slot);

  /// Delete a slot
  Future<void> deleteSlot(String storeId, String slotId);

  /// Book a slot (client)
  Future<void> bookSlot(String storeId, String slotId, String clientId);

  /// Accept an appointment (mechanic)
  Future<void> acceptAppointment(String storeId, String slotId, String mechanicId);

  /// Decline an appointment (mechanic)
  Future<void> declineAppointment(String storeId, String slotId);

  /// Complete an appointment
  Future<void> completeAppointment(String storeId, String slotId);

  /// Cancel an appointment
  Future<void> cancelAppointment(String storeId, String slotId);

  /// Add client feedback
  Future<void> addClientFeedback(String storeId, String slotId, String feedback);

  /// Add mechanic feedback
  Future<void> addMechanicFeedback(String storeId, String slotId, String feedback);

  /// Stream slots in real-time
  Stream<List<Slot>> watchSlots(String storeId);
}
