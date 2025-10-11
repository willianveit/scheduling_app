import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/domain/usecases/accept_appointment.dart';
import 'package:scheduling_app/domain/usecases/book_slot.dart';
import 'package:scheduling_app/domain/usecases/complete_appointment.dart';
import 'package:scheduling_app/domain/usecases/decline_appointment.dart';
import 'package:scheduling_app/domain/usecases/get_available_slots.dart';
import 'package:scheduling_app/domain/usecases/get_mechanic_slots.dart';
import 'package:scheduling_app/domain/usecases/submit_feedback.dart';
import 'package:scheduling_app/presentation/providers/repository_providers.dart';

// Use case providers
final getAvailableSlotsProvider = Provider<GetAvailableSlots>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return GetAvailableSlots(repository);
});

final bookSlotProvider = Provider<BookSlot>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return BookSlot(repository);
});

final acceptAppointmentProvider = Provider<AcceptAppointment>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return AcceptAppointment(repository);
});

final declineAppointmentProvider = Provider<DeclineAppointment>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return DeclineAppointment(repository);
});

final completeAppointmentProvider = Provider<CompleteAppointment>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return CompleteAppointment(repository);
});

final submitFeedbackProvider = Provider<SubmitFeedback>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return SubmitFeedback(repository);
});

final getMechanicSlotsProvider = Provider<GetMechanicSlots>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return GetMechanicSlots(repository);
});
