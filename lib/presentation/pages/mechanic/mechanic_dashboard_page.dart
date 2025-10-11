import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/presentation/pages/mechanic/availability_management_page.dart';
import 'package:scheduling_app/presentation/pages/mechanic/slot_management_page.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';

class MechanicDashboardPage extends ConsumerWidget {
  const MechanicDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanicId = ref.watch(currentMechanicIdProvider);
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: slotsAsync.when(
        data: (slots) {
          final mySlots = slots.where((slot) => slot.mechanicId == mechanicId).toList();
          final myAvailableSlots = mySlots
              .where((slot) => slot.status == AppointmentStatus.available)
              .toList();
          final pendingSlots = slots
              .where(
                (slot) => slot.status == AppointmentStatus.scheduled && slot.mechanicId == null,
              )
              .toList();
          final completedSlots = mySlots
              .where((slot) => slot.status == AppointmentStatus.completed)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome, Mechanic',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('ID: $mechanicId', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Available',
                        count: myAvailableSlots.length,
                        icon: Icons.event_available,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        count: pendingSlots.length,
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'My Active',
                        count: mySlots.where((s) => s.status == AppointmentStatus.scheduled).length,
                        icon: Icons.work,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Completed',
                        count: completedSlots.length,
                        icon: Icons.check_circle,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AvailabilityManagementPage()),
                    );
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text('Manage My Availability'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SlotManagementPage()),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Manage Appointments'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading dashboard...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
