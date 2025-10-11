import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/error_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/slot_card.dart';

class UserAppointmentsPage extends ConsumerWidget {
  const UserAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: slotsAsync.when(
        data: (slots) {
          final mySlots = slots
              .where((slot) => slot.clientId == currentUserId)
              .toList();

          if (mySlots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Appointments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You have no scheduled appointments',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: mySlots.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final slot = mySlots[index];
              return SlotCard(slot: slot);
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading appointments...'),
        error: (error, stack) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(slotsStreamProvider),
        ),
      ),
    );
  }
}

