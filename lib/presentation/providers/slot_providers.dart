import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/presentation/providers/repository_providers.dart';

// Stream provider for real-time slots
final slotsStreamProvider = StreamProvider.family<List<Slot>, String>((ref, storeId) {
  final repository = ref.watch(slotRepositoryProvider);
  return repository.watchSlots(storeId);
});

// Provider for available slots (default store)
final availableSlotsProvider = StreamProvider<List<Slot>>((ref) {
  final repository = ref.watch(slotRepositoryProvider);
  return repository.watchSlots(AppConstants.defaultStoreId);
});

// State provider for selected slot
final selectedSlotProvider = StateProvider<Slot?>((ref) => null);

// State provider for current user ID (in a real app, this would come from auth)
final currentUserIdProvider = StateProvider<String>((ref) => 'user_001');

// State provider for current mechanic ID
final currentMechanicIdProvider = StateProvider<String>((ref) => 'mechanic_001');

// State provider for user role selection
final userRoleProvider = StateProvider<String>((ref) => 'client'); // 'client' or 'mechanic'
