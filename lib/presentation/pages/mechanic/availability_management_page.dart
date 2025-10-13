import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scheduling_app/core/constants/app_constants.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart' as entity;
import 'package:scheduling_app/presentation/providers/mechanic_availability_providers.dart';
import 'package:scheduling_app/presentation/providers/mechanic_providers.dart';

class AvailabilityManagementPage extends ConsumerStatefulWidget {
  const AvailabilityManagementPage({super.key});

  @override
  ConsumerState<AvailabilityManagementPage> createState() => _AvailabilityManagementPageState();
}

// Class to represent a work period
class WorkPeriod {
  TimeOfDay startTime;
  TimeOfDay endTime;

  WorkPeriod({required this.startTime, required this.endTime});

  String get startTimeString =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  String get endTimeString =>
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  bool get isValid => _toMinutes(endTime) > _toMinutes(startTime);

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  int get durationInMinutes => _toMinutes(endTime) - _toMinutes(startTime);
}

class _AvailabilityManagementPageState extends ConsumerState<AvailabilityManagementPage> {
  // Multi-step wizard state
  int currentStep = 0;

  // Step 0: Selected mechanic
  Mechanic? selectedMechanic;

  // Step 1: Multiple dates
  Set<DateTime> selectedDates = {};

  // Step 2: Work periods (start and end times)
  List<WorkPeriod> workPeriods = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with one empty period
    workPeriods.add(
      WorkPeriod(
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: _buildCurrentStep(context),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  _buildNavigationButtons(context),
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
          _buildStepIndicator(0, Icons.person, 'Mechanic'),
          _buildStepConnector(0),
          _buildStepIndicator(1, Icons.calendar_month, 'Dates'),
          _buildStepConnector(1),
          _buildStepIndicator(2, Icons.access_time, 'Work Hours'),
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

  Widget _buildCurrentStep(BuildContext context) {
    switch (currentStep) {
      case 0:
        return _buildMechanicSelectionStep(context);
      case 1:
        return _buildDatesStep(context);
      case 2:
        return _buildWorkPeriodsStep(context);
      case 3:
        return _buildReviewStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMechanicSelectionStep(BuildContext context) {
    final mechanicsAsync = ref.watch(mechanicsProvider);

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
                Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Select Mechanic',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the mechanic for whom you want to set availability',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            mechanicsAsync.when(
              data: (mechanics) {
                if (mechanics.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No mechanics found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please add mechanics to the system first',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: mechanics.map((mechanic) {
                    final isSelected = selectedMechanic?.id == mechanic.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => setState(() => selectedMechanic = mechanic),
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
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mechanic.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (mechanic.specialty != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        mechanic.specialty!,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                    if (mechanic.email != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        mechanic.email!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading mechanics',
                      style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
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
                  label: 'Next 30 Days',
                  icon: Icons.date_range,
                  onPressed: _addNext30Days,
                ),
                _QuickActionChip(
                  label: 'This Month',
                  icon: Icons.calendar_month,
                  onPressed: _addThisMonth,
                ),
                _QuickActionChip(
                  label: 'Weekdays Only',
                  icon: Icons.work,
                  onPressed: _addWeekdaysOnly,
                ),
                _QuickActionChip(
                  label: 'Clear All',
                  icon: Icons.clear,
                  onPressed: () => setState(() => selectedDates.clear()),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calendar grid - next 90 days
            _buildDateGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGrid(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      90,
      (index) => DateTime(today.year, today.month, today.day).add(Duration(days: index)),
    );

    // Group dates by month
    final Map<String, List<DateTime>> datesByMonth = {};
    for (final date in dates) {
      final monthKey = DateFormat('MMMM yyyy').format(date);
      datesByMonth.putIfAbsent(monthKey, () => []).add(date);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: datesByMonth.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dates grid for this month
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((date) {
                    final isSelected = selectedDates.any(
                      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
                    );
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDates.removeWhere(
                              (d) =>
                                  d.year == date.year && d.month == date.month && d.day == date.day,
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
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : isToday
                              ? Colors.blue[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isToday
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: isSelected || isToday ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue[700]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 18,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue[900]
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
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
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWorkPeriodsStep(BuildContext context) {
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
                  'Define Work Hours',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set your work periods for each day (${workPeriods.length} period${workPeriods.length != 1 ? 's' : ''})',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                        children: [
                          const TextSpan(
                            text: 'Important: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'These work periods will be applied to '),
                          TextSpan(
                            text: 'ALL ${selectedDates.length} selected days',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text:
                                '. You can add multiple periods to handle breaks (e.g., 8am-12pm and 2pm-6pm).',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Work Periods List
            ...workPeriods.asMap().entries.map((entry) {
              final index = entry.key;
              final period = entry.value;
              return _buildWorkPeriodCard(context, period, index);
            }),

            const SizedBox(height: 16),

            // Add Period Button
            OutlinedButton.icon(
              onPressed: _addWorkPeriod,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Period'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),

            const SizedBox(height: 16),

            // Quick presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  label: 'Full Day (8-17)',
                  icon: Icons.wb_sunny,
                  onPressed: () => _setPreset(8, 0, 17, 0),
                ),
                _QuickActionChip(
                  label: 'Morning (8-12)',
                  icon: Icons.wb_sunny_outlined,
                  onPressed: () => _setPreset(8, 0, 12, 0),
                ),
                _QuickActionChip(
                  label: 'Afternoon (14-18)',
                  icon: Icons.nights_stay,
                  onPressed: () => _setPreset(14, 0, 18, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkPeriodCard(BuildContext context, WorkPeriod period, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Period ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (workPeriods.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeWorkPeriod(index),
                  tooltip: 'Remove period',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Time', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context, period, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              period.startTimeString,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('End Time', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context, period, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              period.endTimeString,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!period.isValid) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  'End time must be after start time',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.green[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${period.durationInMinutes} minutes (${(period.durationInMinutes / 60).toStringAsFixed(1)} hours)',
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context) {
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
              'Review your availability before confirming',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Clear explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.purple[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'How it works',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your work periods will be saved to your profile and applied to all selected days. '
                    'Customers will be able to book appointments during these times.',
                    style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedDates.length} day${selectedDates.length != 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${workPeriods.length} period${workPeriods.length != 1 ? 's' : ''} per day',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary boxes
            _buildSummaryBox(
              context,
              'Mechanic',
              selectedMechanic?.name ?? 'Not selected',
              Icons.person,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Dates Selected',
              '${selectedDates.length} day${selectedDates.length != 1 ? 's' : ''}',
              Icons.calendar_month,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Work Periods',
              '${workPeriods.length} period${workPeriods.length != 1 ? 's' : ''} per day',
              Icons.access_time,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSummaryBox(
              context,
              'Total Coverage',
              '${selectedDates.length * workPeriods.length} period-day combinations',
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

            if (workPeriods.isNotEmpty) ...[
              Text(
                'Work Periods:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...workPeriods.asMap().entries.map((entry) {
                final index = entry.key;
                final period = entry.value;
                final durationHours = (period.durationInMinutes / 60).toStringAsFixed(1);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Period ${index + 1}: ${period.startTimeString} - ${period.endTimeString}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '$durationHours hours',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              }),
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

  Widget _buildNavigationButtons(BuildContext context) {
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
            onPressed: _getNextButtonAction(context),
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
        return selectedMechanic == null ? 'Select Mechanic' : 'Next: Select Dates';
      case 1:
        return selectedDates.isEmpty ? 'Skip to Work Hours' : 'Next: Set Work Hours';
      case 2:
        return 'Review';
      case 3:
        return isLoading ? 'Saving...' : 'Save Availability';
      default:
        return 'Next';
    }
  }

  VoidCallback? _getNextButtonAction(BuildContext context) {
    if (isLoading) return null;

    switch (currentStep) {
      case 0:
        return selectedMechanic != null ? () => setState(() => currentStep = 1) : null;
      case 1:
        return () => setState(() => currentStep = 2);
      case 2:
        // Check if all periods are valid
        final allValid = workPeriods.every((p) => p.isValid);
        return allValid ? () => setState(() => currentStep = 3) : null;
      case 3:
        return selectedDates.isEmpty || workPeriods.isEmpty || selectedMechanic == null
            ? null
            : () => _createBulkAvailability(context);
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

  void _addNext30Days() {
    setState(() {
      final today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        selectedDates.add(DateTime(today.year, today.month, today.day).add(Duration(days: i)));
      }
    });
  }

  void _addThisMonth() {
    setState(() {
      final today = DateTime.now();
      final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

      for (int i = today.day; i <= daysInMonth; i++) {
        final date = DateTime(today.year, today.month, i);
        selectedDates.add(date);
      }
    });
  }

  void _addWeekdaysOnly() {
    setState(() {
      final today = DateTime.now();
      for (int i = 0; i < 90; i++) {
        final date = DateTime(today.year, today.month, today.day).add(Duration(days: i));
        // Monday = 1, Friday = 5
        if (date.weekday >= 1 && date.weekday <= 5) {
          selectedDates.add(date);
        }
      }
    });
  }

  // Work period helpers
  void _addWorkPeriod() {
    setState(() {
      workPeriods.add(
        WorkPeriod(
          startTime: const TimeOfDay(hour: 8, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
        ),
      );
    });
  }

  void _removeWorkPeriod(int index) {
    setState(() {
      if (workPeriods.length > 1) {
        workPeriods.removeAt(index);
      }
    });
  }

  Future<void> _selectTime(BuildContext context, WorkPeriod period, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? period.startTime : period.endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          period.startTime = picked;
        } else {
          period.endTime = picked;
        }
      });
    }
  }

  void _setPreset(int startHour, int startMinute, int endHour, int endMinute) {
    setState(() {
      if (workPeriods.isEmpty) {
        workPeriods.add(
          WorkPeriod(
            startTime: TimeOfDay(hour: startHour, minute: startMinute),
            endTime: TimeOfDay(hour: endHour, minute: endMinute),
          ),
        );
      } else {
        workPeriods[0].startTime = TimeOfDay(hour: startHour, minute: startMinute);
        workPeriods[0].endTime = TimeOfDay(hour: endHour, minute: endMinute);
      }
    });
  }

  // Save availability to mechanic profile
  Future<void> _createBulkAvailability(BuildContext context) async {
    if (selectedMechanic == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final repository = ref.read(mechanicAvailabilityRepositoryProvider);

      // Convert WorkPeriod (TimeOfDay) to entity.WorkPeriod (String)
      final List<entity.DayAvailability> availability = selectedDates.map((date) {
        final periods = workPeriods.map((wp) {
          return entity.WorkPeriod(startTime: wp.startTimeString, endTime: wp.endTimeString);
        }).toList();

        return entity.DayAvailability(date: date, workPeriods: periods);
      }).toList();

      // Create the mechanic availability entity
      final mechanicAvailability = entity.MechanicAvailability(
        mechanicId: selectedMechanic!.id,
        storeId: AppConstants.defaultStoreId,
        availability: availability,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await repository.saveMechanicAvailability(mechanicAvailability);

      if (context.mounted) {
        final totalDays = selectedDates.length;
        final totalPeriods = workPeriods.length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Successfully saved availability for ${selectedMechanic!.name}!\n$totalDays days with $totalPeriods period${totalPeriods != 1 ? 's' : ''} each.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving availability: $e'), backgroundColor: Colors.red),
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
