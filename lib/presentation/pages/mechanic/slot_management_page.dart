import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/presentation/pages/mechanic/appointment_details_page.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/error_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/slot_card.dart';

class SlotManagementPage extends ConsumerWidget {
  const SlotManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Appointments'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending', icon: Icon(Icons.pending)),
              Tab(text: 'Active', icon: Icon(Icons.work)),
              Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: slotsAsync.when(
          data: (slots) {
            final mechanicId = ref.watch(currentMechanicIdProvider);

            final pendingSlots = slots
                .where(
                  (slot) => slot.status == AppointmentStatus.scheduled && slot.mechanicId == null,
                )
                .toList();

            final activeSlots = slots
                .where(
                  (slot) =>
                      slot.mechanicId == mechanicId && slot.status == AppointmentStatus.scheduled,
                )
                .toList();

            final completedSlots = slots
                .where(
                  (slot) =>
                      slot.mechanicId == mechanicId && slot.status == AppointmentStatus.completed,
                )
                .toList();

            return TabBarView(
              children: [
                _buildSlotList(context, ref, pendingSlots, 'pending'),
                _buildSlotList(context, ref, activeSlots, 'active'),
                _buildSlotList(context, ref, completedSlots, 'completed'),
              ],
            );
          },
          loading: () => const LoadingWidget(message: 'Loading appointments...'),
          error: (error, stack) => ErrorDisplayWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(slotsStreamProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotList(BuildContext context, WidgetRef ref, List slots, String type) {
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'pending'
                    ? Icons.pending_actions
                    : type == 'active'
                    ? Icons.work_off
                    : Icons.check_circle_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${type.substring(0, 1).toUpperCase()}${type.substring(1)} Appointments',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: slots.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final slot = slots[index];
        return SlotCard(
          slot: slot,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppointmentDetailsPage(slot: slot)),
            );
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        );
      },
    );
  }
}
