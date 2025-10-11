import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/presentation/pages/user/feedback_page.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/providers/usecase_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/error_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/slot_card.dart';

class ScheduleSelectionPage extends ConsumerWidget {
  const ScheduleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: slotsAsync.when(
        data: (slots) {
          final availableSlots = slots
              .where((slot) => slot.status == AppointmentStatus.available)
              .toList();

          if (availableSlots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Available Slots',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check back later for available time slots',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: availableSlots.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              return SlotCard(
                slot: slot,
                onTap: () async {
                  final bookSlot = ref.read(bookSlotProvider);

                  try {
                    // Show loading dialog
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      );
                    }

                    await bookSlot(
                      storeId: AppConstants.defaultStoreId,
                      slotId: slot.slotId,
                      clientId: currentUserId,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog

                      // Navigate to feedback page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackPage(
                            slotId: slot.slotId,
                            storeId: AppConstants.defaultStoreId,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to book slot: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading available slots...'),
        error: (error, stack) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(slotsStreamProvider),
        ),
      ),
    );
  }
}
