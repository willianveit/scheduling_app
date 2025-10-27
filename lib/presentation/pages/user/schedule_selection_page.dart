import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/presentation/pages/user/feedback_page.dart';
import 'package:scheduling_app/presentation/providers/mechanic_providers.dart';
import 'package:scheduling_app/presentation/providers/repository_providers.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/error_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';

/// Helper class to represent an available time slot
class AvailableSlot {
  final String mechanicId;
  final DateTime appointmentTime;

  AvailableSlot({required this.mechanicId, required this.appointmentTime});
}

class ScheduleSelectionPage extends ConsumerStatefulWidget {
  const ScheduleSelectionPage({super.key});

  @override
  ConsumerState<ScheduleSelectionPage> createState() => _ScheduleSelectionPageState();
}

class _ScheduleSelectionPageState extends ConsumerState<ScheduleSelectionPage> {
  String? _selectedMechanicId;
  String? _selectedDate;
  static const int slotDurationMinutes = 30; // Duration of each appointment slot

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Generate available time slots from mechanic's availability
  List<AvailableSlot> _generateSlotsFromAvailability(Mechanic mechanic, List<Slot> existingSlots) {
    if (mechanic.availability == null || mechanic.availability!.isEmpty) {
      return [];
    }

    final List<AvailableSlot> availableSlots = [];
    final now = DateTime.now();

    for (final dayAvailability in mechanic.availability!) {
      // Skip past dates
      if (dayAvailability.date.isBefore(DateTime(now.year, now.month, now.day))) {
        continue;
      }

      for (final workPeriod in dayAvailability.workPeriods) {
        // Parse work period times
        final startParts = workPeriod.startTime.split(':');
        final endParts = workPeriod.endTime.split(':');

        final startHour = int.parse(startParts[0]);
        final startMinute = int.parse(startParts[1]);
        final endHour = int.parse(endParts[0]);
        final endMinute = int.parse(endParts[1]);

        // Create DateTime for start and end
        var currentSlotTime = DateTime(
          dayAvailability.date.year,
          dayAvailability.date.month,
          dayAvailability.date.day,
          startHour,
          startMinute,
        );

        final endTime = DateTime(
          dayAvailability.date.year,
          dayAvailability.date.month,
          dayAvailability.date.day,
          endHour,
          endMinute,
        );

        // Generate slots in intervals
        while (currentSlotTime.add(Duration(minutes: slotDurationMinutes)).isBefore(endTime) ||
            currentSlotTime.add(Duration(minutes: slotDurationMinutes)).isAtSameMomentAs(endTime)) {
          // Check if this slot is already booked
          final slotTimeStr = currentSlotTime.toIso8601String();
          final isBooked = existingSlots.any(
            (slot) =>
                slot.mechanicId == mechanic.id &&
                slot.appointmentTime == slotTimeStr &&
                slot.status != AppointmentStatus.available,
          );

          if (!isBooked && currentSlotTime.isAfter(now)) {
            availableSlots.add(
              AvailableSlot(mechanicId: mechanic.id, appointmentTime: currentSlotTime),
            );
          }

          currentSlotTime = currentSlotTime.add(Duration(minutes: slotDurationMinutes));
        }
      }
    }

    return availableSlots;
  }

  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(mechanicsStreamProvider);
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (_selectedMechanicId != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMechanicId = null;
                  _selectedDate = null;
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: mechanicsAsync.when(
        data: (mechanics) {
          if (mechanics.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.engineering, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Mechanics Available',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check back later',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // If no mechanic selected, show mechanic selection
          if (_selectedMechanicId == null) {
            return _buildMechanicSelection(mechanics);
          }

          // If mechanic selected, show slots for that mechanic
          return slotsAsync.when(
            data: (existingSlots) {
              final selectedMechanic = mechanics.firstWhere((m) => m.id == _selectedMechanicId);

              // Generate available slots from mechanic's availability
              final availableSlots = _generateSlotsFromAvailability(
                selectedMechanic,
                existingSlots,
              );

              if (availableSlots.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No Available Slots',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This mechanic has no available time slots',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedMechanicId = null;
                              _selectedDate = null;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Choose Another Mechanic'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group slots by date
              final Map<String, List<AvailableSlot>> slotsByDate = {};
              for (var slot in availableSlots) {
                final dateKey = _formatDate(slot.appointmentTime);
                slotsByDate.putIfAbsent(dateKey, () => []).add(slot);
              }

              final sortedDates = slotsByDate.keys.toList()..sort();

              // Set initial selected date if not set
              if (_selectedDate == null && sortedDates.isNotEmpty) {
                _selectedDate = sortedDates.first;
              }

              final filteredSlots = _selectedDate != null ? (slotsByDate[_selectedDate] ?? []) : [];

              return Column(
                children: [
                  // Selected Mechanic Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          radius: 24,
                          child: const Icon(Icons.engineering, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected Mechanic',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                selectedMechanic.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (selectedMechanic.specialty != null)
                                Text(
                                  selectedMechanic.specialty!,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedMechanicId = null;
                              _selectedDate = null;
                            });
                          },
                          icon: const Icon(Icons.change_circle_outlined),
                          tooltip: 'Change Mechanic',
                        ),
                      ],
                    ),
                  ),
                  // Date selector section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          Theme.of(context).colorScheme.inversePrimary.withOpacity(0.12),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select a Date',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    '${sortedDates.length} days available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 174,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final dateKey = sortedDates[index];
                              final dateTime = DateTime.parse(dateKey);
                              final isSelected = _selectedDate == dateKey;
                              final slotCount = slotsByDate[dateKey]?.length ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Material(
                                    elevation: isSelected ? 8 : 2,
                                    borderRadius: BorderRadius.circular(20),
                                    shadowColor: isSelected
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.1),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDate = dateKey;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 140,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Theme.of(context).colorScheme.primary,
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary.withOpacity(0.8),
                                                  ],
                                                )
                                              : LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [Colors.white, Colors.grey.shade50],
                                                ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.grey.shade300,
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                      'EEE',
                                                    ).format(dateTime).toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: isSelected
                                                          ? Colors.white.withOpacity(0.9)
                                                          : Colors.grey.shade600,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    DateFormat('d').format(dateTime),
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      height: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    DateFormat(
                                                      'MMM',
                                                    ).format(dateTime).toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: isSelected
                                                          ? Colors.white.withOpacity(0.85)
                                                          : Colors.grey.shade700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.green.shade500,
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              (isSelected
                                                                      ? Colors.white
                                                                      : Colors.green.shade500)
                                                                  .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 12,
                                                          color: isSelected
                                                              ? Theme.of(
                                                                  context,
                                                                ).colorScheme.primary
                                                              : Colors.white,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '$slotCount',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: isSelected
                                                                ? Theme.of(
                                                                    context,
                                                                  ).colorScheme.primary
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Available Time Slots',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '${filteredSlots.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredSlots.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No slots available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try selecting a different date',
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredSlots.length,
                            itemBuilder: (context, index) {
                              final availableSlot = filteredSlots[index];
                              final timeStr = _formatTime(availableSlot.appointmentTime);

                              return _SlotTimeCard(
                                time: timeStr,
                                onTap: () => _bookSlot(context, ref, availableSlot, currentUserId),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const LoadingWidget(message: 'Loading available slots...'),
            error: (error, stack) => ErrorDisplayWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(slotsStreamProvider),
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading mechanics...'),
        error: (error, stack) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(mechanicsStreamProvider),
        ),
      ),
    );
  }

  Widget _buildMechanicSelection(List<Mechanic> mechanics) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.engineering,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Your Mechanic',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Choose a mechanic to see their available times',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: mechanics.length,
              itemBuilder: (context, index) {
                final mechanic = mechanics[index];
                final hasAvailability =
                    mechanic.availability != null && mechanic.availability!.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: hasAvailability
                        ? () {
                            setState(() {
                              _selectedMechanicId = mechanic.id;
                              _selectedDate = null; // Reset date selection
                            });
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: hasAvailability
                              ? [Colors.white, Colors.blue.shade50.withOpacity(0.3)]
                              : [Colors.grey.shade100, Colors.grey.shade200],
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: hasAvailability
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            radius: 32,
                            child: Icon(Icons.engineering, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mechanic.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: hasAvailability ? Colors.black87 : Colors.grey.shade600,
                                  ),
                                ),
                                if (mechanic.specialty != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.build, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        mechanic.specialty!,
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: hasAvailability
                                        ? Colors.green.shade100
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasAvailability ? Icons.check_circle : Icons.event_busy,
                                        size: 16,
                                        color: hasAvailability
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        hasAvailability
                                            ? '${mechanic.availability!.length} days available'
                                            : 'No availability',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: hasAvailability
                                              ? Colors.green.shade700
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: hasAvailability
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookSlot(
    BuildContext context,
    WidgetRef ref,
    AvailableSlot availableSlot,
    String currentUserId,
  ) async {
    final slotRepository = ref.read(slotRepositoryProvider);

    try {
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
            ),
          ),
        );
      }

      // Generate a unique slot ID
      final slotId = 'slot_${DateTime.now().millisecondsSinceEpoch}';

      // Create a new slot
      final newSlot = Slot(
        slotId: slotId,
        storeId: AppConstants.defaultStoreId,
        clientId: currentUserId,
        mechanicId: availableSlot.mechanicId,
        appointmentTime: availableSlot.appointmentTime.toIso8601String(),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the slot to Firestore
      await slotRepository.createSlot(newSlot);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Navigate to feedback page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FeedbackPage(slotId: slotId, storeId: AppConstants.defaultStoreId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book slot: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _SlotTimeCard extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const _SlotTimeCard({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      shadowColor: Colors.green.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.green.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 8),
                    const SizedBox(width: 2),
                    Text(
                      'OPEN',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.green.shade700, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 1,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
