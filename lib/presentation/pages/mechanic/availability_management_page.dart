import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/domain/usecases/create_availability_slot.dart';
import 'package:scheduling_app/presentation/providers/repository_providers.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';

class AvailabilityManagementPage extends ConsumerStatefulWidget {
  const AvailabilityManagementPage({super.key});

  @override
  ConsumerState<AvailabilityManagementPage> createState() => _AvailabilityManagementPageState();
}

class _AvailabilityManagementPageState extends ConsumerState<AvailabilityManagementPage> {
  // Multi-step wizard state
  int currentStep = 0;

  // Step 1: Duration
  int selectedDurationMinutes = 60;

  // Step 2: Multiple dates
  Set<DateTime> selectedDates = {};

  // Step 3: Multiple time slots
  Set<String> selectedTimeSlots = {};

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentMechanicIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Wizard Steps
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(context, mechanicId),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  _buildNavigationButtons(context, mechanicId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, Icons.timer, 'Duration'),
          _buildStepConnector(0),
          _buildStepIndicator(1, Icons.calendar_month, 'Dates'),
          _buildStepConnector(1),
          _buildStepIndicator(2, Icons.access_time, 'Times'),
          _buildStepConnector(2),
          _buildStepIndicator(3, Icons.check_circle, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, IconData icon, String label) {
    final isActive = currentStep == step;
    final isCompleted = currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? Colors.green : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, String mechanicId) {
    switch (currentStep) {
      case 0:
        return _buildDurationStep(context);
      case 1:
        return _buildDatesStep(context);
      case 2:
        return _buildTimesStep(context);
      case 3:
        return _buildReviewStep(context, mechanicId);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDurationStep(BuildContext context) {
    final durations = [
      (30, '30 min', 'Quick service'),
      (60, '1 hour', 'Standard'),
      (90, '1.5 hours', 'Extended'),
      (120, '2 hours', 'Full service'),
    ];

    return Card(
      elevation: 4,
      key: const ValueKey(0),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.timer, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Select Appointment Duration',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how long each appointment should last',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ...durations.map((duration) {
              final minutes = duration.$1;
              final label = duration.$2;
              final description = duration.$3;
              final isSelected = selectedDurationMinutes == minutes;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => selectedDurationMinutes = minutes),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                description,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesStep(BuildContext context) {
    return Card(
      elevation: 4,
      key: const ValueKey(1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Select Dates',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose multiple days when you\'ll be available (${selectedDates.length} selected)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Quick select buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  label: 'Next 7 Days',
                  icon: Icons.calendar_today,
                  onPressed: _addNext7Days,
                ),
                _QuickActionChip(
                  label: 'This Week',
                  icon: Icons.date_range,
                  onPressed: _addThisWeek,
                ),
                _QuickActionChip(
                  label: 'Clear All',
                  icon: Icons.clear,
                  onPressed: () => setState(() => selectedDates.clear()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calendar grid - next 14 days
            _buildDateGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGrid(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      14,
      (index) => DateTime(today.year, today.month, today.day).add(Duration(days: index)),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dates.map((date) {
        final isSelected = selectedDates.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        );

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedDates.removeWhere(
                  (d) => d.year == date.year && d.month == date.month && d.day == date.day,
                );
              } else {
                selectedDates.add(date);
              }
            });
          },
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d').format(date),
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimesStep(BuildContext context) {
    final timeSlots = [
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
    ];

    return Card(
      elevation: 4,
      key: const ValueKey(2),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Select Time Slots',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose multiple times when you\'ll be available (${selectedTimeSlots.length} selected)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Quick select buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  label: 'Morning (8-12)',
                  icon: Icons.wb_sunny,
                  onPressed: _selectMorningSlots,
                ),
                _QuickActionChip(
                  label: 'Afternoon (12-17)',
                  icon: Icons.wb_sunny_outlined,
                  onPressed: _selectAfternoonSlots,
                ),
                _QuickActionChip(
                  label: 'Evening (17-20)',
                  icon: Icons.nights_stay,
                  onPressed: _selectEveningSlots,
                ),
                _QuickActionChip(
                  label: 'Clear All',
                  icon: Icons.clear,
                  onPressed: () => setState(() => selectedTimeSlots.clear()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time slots grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                final isSelected = selectedTimeSlots.contains(time);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedTimeSlots.remove(time);
                      } else {
                        selectedTimeSlots.add(time);
                      }
                    });
                  },
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      time,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context, String mechanicId) {
    final totalSlots = selectedDates.length * selectedTimeSlots.length;

    return Card(
      elevation: 4,
      key: const ValueKey(3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Review & Confirm',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Review your availability before adding',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Summary boxes
            _buildSummaryBox(
              context,
              'Duration',
              '$selectedDurationMinutes minutes',
              Icons.timer,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Dates Selected',
              '${selectedDates.length} days',
              Icons.calendar_month,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Time Slots',
              '${selectedTimeSlots.length} slots per day',
              Icons.access_time,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Total Availability',
              '$totalSlots time slots',
              Icons.event_available,
              Colors.purple,
            ),

            const SizedBox(height: 24),

            // Details
            if (selectedDates.isNotEmpty) ...[
              Text(
                'Selected Dates:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (selectedDates.toList()..sort())
                    .map(
                      (date) => Chip(
                        label: Text(
                          DateFormat('MMM d, EEE').format(date),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue[50],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            if (selectedTimeSlots.isNotEmpty) ...[
              Text(
                'Selected Times:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (selectedTimeSlots.toList()..sort())
                    .map(
                      (time) => Chip(
                        label: Text(time, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange[50],
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, String mechanicId) {
    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: currentStep == 0 ? 1 : 1,
          child: ElevatedButton.icon(
            onPressed: _getNextButtonAction(context, mechanicId),
            icon: Icon(currentStep == 3 ? Icons.check : Icons.arrow_forward),
            label: Text(_getNextButtonLabel()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  String _getNextButtonLabel() {
    switch (currentStep) {
      case 0:
        return 'Next: Select Dates';
      case 1:
        return selectedDates.isEmpty ? 'Skip to Times' : 'Next: Select Times';
      case 2:
        return 'Review';
      case 3:
        return isLoading ? 'Creating...' : 'Create Availability';
      default:
        return 'Next';
    }
  }

  VoidCallback? _getNextButtonAction(BuildContext context, String mechanicId) {
    if (isLoading) return null;

    switch (currentStep) {
      case 0:
        return () => setState(() => currentStep = 1);
      case 1:
        return () => setState(() => currentStep = 2);
      case 2:
        return () => setState(() => currentStep = 3);
      case 3:
        return selectedDates.isEmpty || selectedTimeSlots.isEmpty
            ? null
            : () => _createBulkAvailability(context, mechanicId);
      default:
        return null;
    }
  }

  // Date selection helpers
  void _addNext7Days() {
    setState(() {
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        selectedDates.add(DateTime(today.year, today.month, today.day).add(Duration(days: i)));
      }
    });
  }

  void _addThisWeek() {
    setState(() {
      final today = DateTime.now();
      final weekday = today.weekday;
      final startOfWeek = today.subtract(Duration(days: weekday - 1));

      for (int i = 0; i < 7; i++) {
        final date = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        ).add(Duration(days: i));

        if (!date.isBefore(DateTime(today.year, today.month, today.day))) {
          selectedDates.add(date);
        }
      }
    });
  }

  // Time slot selection helpers
  void _selectMorningSlots() {
    setState(() {
      selectedTimeSlots.addAll([
        '08:00',
        '08:30',
        '09:00',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '12:00',
      ]);
    });
  }

  void _selectAfternoonSlots() {
    setState(() {
      selectedTimeSlots.addAll([
        '12:00',
        '12:30',
        '13:00',
        '13:30',
        '14:00',
        '14:30',
        '15:00',
        '15:30',
        '16:00',
        '16:30',
        '17:00',
      ]);
    });
  }

  void _selectEveningSlots() {
    setState(() {
      selectedTimeSlots.addAll(['17:00', '17:30', '18:00', '18:30', '19:00', '19:30']);
    });
  }

  // Bulk create availability
  Future<void> _createBulkAvailability(BuildContext context, String mechanicId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final repository = ref.read(slotRepositoryProvider);
      final createSlot = CreateAvailabilitySlot(repository: repository);

      int successCount = 0;
      int failCount = 0;

      // Create slots for each date and time combination
      for (final date in selectedDates) {
        for (final timeStr in selectedTimeSlots) {
          try {
            final timeParts = timeStr.split(':');
            final dateTime = DateTime(
              date.year,
              date.month,
              date.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );

            final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

            await createSlot(
              storeId: AppConstants.defaultStoreId,
              mechanicId: mechanicId,
              appointmentTime: formattedTime,
            );

            successCount++;
          } catch (e) {
            failCount++;
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount == 0
                  ? '🎉 Successfully created $successCount availability slots!'
                  : 'Created $successCount slots ($failCount failed)',
            ),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Reset wizard
      setState(() {
        currentStep = 0;
        selectedDates.clear();
        selectedTimeSlots.clear();
        selectedDurationMinutes = 60;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating availability: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickActionChip({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
