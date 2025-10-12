import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/presentation/pages/user/feedback_page.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/providers/usecase_providers.dart';
import 'package:scheduling_app/presentation/widgets/common/error_widget.dart';
import 'package:scheduling_app/presentation/widgets/common/loading_widget.dart';

class ScheduleSelectionPage extends ConsumerStatefulWidget {
  const ScheduleSelectionPage({super.key});

  @override
  ConsumerState<ScheduleSelectionPage> createState() => _ScheduleSelectionPageState();
}

class _ScheduleSelectionPageState extends ConsumerState<ScheduleSelectionPage> {
  String? _selectedDate;

  DateTime _parseAppointmentTime(String appointmentTime) {
    try {
      return DateTime.parse(appointmentTime);
    } catch (e) {
      // Try alternative parsing if needed
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(slotsStreamProvider(AppConstants.defaultStoreId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
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

          // Group slots by date
          final Map<String, List<Slot>> slotsByDate = {};
          for (var slot in availableSlots) {
            final dateTime = _parseAppointmentTime(slot.appointmentTime);
            final dateKey = _formatDate(dateTime);
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
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                                                DateFormat('EEE').format(dateTime).toUpperCase(),
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
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                  height: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                DateFormat('MMM').format(dateTime).toUpperCase(),
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
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$slotCount',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: isSelected
                                                            ? Theme.of(context).colorScheme.primary
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
                          final slot = filteredSlots[index];
                          final dateTime = _parseAppointmentTime(slot.appointmentTime);
                          final timeStr = _formatTime(dateTime);

                          return _SlotTimeCard(
                            time: timeStr,
                            onTap: () => _bookSlot(context, ref, slot, currentUserId),
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
      ),
    );
  }

  Future<void> _bookSlot(
    BuildContext context,
    WidgetRef ref,
    Slot slot,
    String currentUserId,
  ) async {
    final bookSlot = ref.read(bookSlotProvider);

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
            builder: (context) =>
                FeedbackPage(slotId: slot.slotId, storeId: AppConstants.defaultStoreId),
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
