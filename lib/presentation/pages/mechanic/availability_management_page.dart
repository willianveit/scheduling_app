import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/usecases/create_availability_slot.dart';
import 'package:scheduling_app/presentation/providers/repository_providers.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';

class AvailabilityManagementPage extends ConsumerStatefulWidget {
  const AvailabilityManagementPage({super.key});

  @override
  ConsumerState<AvailabilityManagementPage> createState() => _AvailabilityManagementPageState();
}

class _AvailabilityManagementPageState extends ConsumerState<AvailabilityManagementPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentMechanicIdProvider);
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Availability Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Available Time Slot',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date Selector
                    OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Selector
                    OutlinedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${selectedTime!.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Button
                    ElevatedButton.icon(
                      onPressed: isLoading || selectedTime == null
                          ? null
                          : () => _addAvailability(context, mechanicId),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(isLoading ? 'Adding...' : 'Add Availability'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Add Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Add - Today',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickTimeButton(
                          time: '09:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '09:00'),
                        ),
                        _QuickTimeButton(
                          time: '10:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '10:00'),
                        ),
                        _QuickTimeButton(
                          time: '11:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '11:00'),
                        ),
                        _QuickTimeButton(
                          time: '14:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '14:00'),
                        ),
                        _QuickTimeButton(
                          time: '15:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '15:00'),
                        ),
                        _QuickTimeButton(
                          time: '16:00',
                          onPressed: () => _quickAddTime(context, mechanicId, '16:00'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // My Available Slots
            Text(
              'My Available Slots',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            slotsAsync.when(
              data: (slots) {
                final myAvailableSlots =
                    slots
                        .where(
                          (slot) =>
                              slot.mechanicId == mechanicId &&
                              slot.status == AppointmentStatus.available,
                        )
                        .toList()
                      ..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

                if (myAvailableSlots.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No available slots yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first availability above',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myAvailableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = myAvailableSlots[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Icon(Icons.event_available, color: Colors.green[700]),
                        ),
                        title: Text(
                          slot.appointmentTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Status: ${slot.status.toJson()}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSlot(context, slot.slotId),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Card(
                child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _addAvailability(BuildContext context, String mechanicId) async {
    if (selectedTime == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

      final repository = ref.read(slotRepositoryProvider);
      final createSlot = CreateAvailabilitySlot(repository: repository);

      await createSlot(
        storeId: AppConstants.defaultStoreId,
        mechanicId: mechanicId,
        appointmentTime: formattedTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Availability added successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }

      // Reset time selection
      setState(() {
        selectedTime = null;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _quickAddTime(BuildContext context, String mechanicId, String time) async {
    try {
      final timeParts = time.split(':');
      final dateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

      final repository = ref.read(slotRepositoryProvider);
      final createSlot = CreateAvailabilitySlot(repository: repository);

      await createSlot(
        storeId: AppConstants.defaultStoreId,
        mechanicId: mechanicId,
        appointmentTime: formattedTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability added for $time today!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteSlot(BuildContext context, String slotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Availability'),
        content: const Text('Are you sure you want to delete this availability slot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(slotRepositoryProvider);
      await repository.deleteSlot(AppConstants.defaultStoreId, slotId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String time;
  final VoidCallback onPressed;

  const _QuickTimeButton({required this.time, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(time, style: const TextStyle(fontSize: 16)),
    );
  }
}
