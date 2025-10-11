import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/core/enums/user_role.dart';
import 'package:scheduling_app/domain/entities/slot.dart';
import 'package:scheduling_app/presentation/pages/user/feedback_page.dart';
import 'package:scheduling_app/presentation/providers/slot_providers.dart';
import 'package:scheduling_app/presentation/providers/usecase_providers.dart';

class AppointmentDetailsPage extends ConsumerStatefulWidget {
  final Slot slot;

  const AppointmentDetailsPage({
    super.key,
    required this.slot,
  });

  @override
  ConsumerState<AppointmentDetailsPage> createState() =>
      _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState
    extends ConsumerState<AppointmentDetailsPage> {
  bool _isProcessing = false;

  Future<void> _acceptAppointment() async {
    setState(() => _isProcessing = true);

    try {
      final mechanicId = ref.read(currentMechanicIdProvider);
      final acceptAppointment = ref.read(acceptAppointmentProvider);

      await acceptAppointment(
        storeId: widget.slot.storeId,
        slotId: widget.slot.slotId,
        mechanicId: mechanicId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment accepted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _declineAppointment() async {
    setState(() => _isProcessing = true);

    try {
      final declineAppointment = ref.read(declineAppointmentProvider);

      await declineAppointment(
        storeId: widget.slot.storeId,
        slotId: widget.slot.slotId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment declined'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeAppointment() async {
    setState(() => _isProcessing = true);

    try {
      final completeAppointment = ref.read(completeAppointmentProvider);

      await completeAppointment(
        storeId: widget.slot.storeId,
        slotId: widget.slot.slotId,
      );

      if (mounted) {
        // Navigate to feedback page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackPage(
              slotId: widget.slot.slotId,
              storeId: widget.slot.storeId,
              userRole: UserRole.mechanic,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentMechanicIdProvider);
    final isMyAppointment = widget.slot.mechanicId == mechanicId;
    final isPending = widget.slot.mechanicId == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Icon
            Center(
              child: Icon(
                widget.slot.status == AppointmentStatus.completed
                    ? Icons.check_circle
                    : Icons.schedule,
                size: 80,
                color: widget.slot.status == AppointmentStatus.completed
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time Slot',
                      value: widget.slot.appointmentTime,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: widget.slot.status.name.toUpperCase(),
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Client ID',
                      value: widget.slot.clientId ?? 'N/A',
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.build,
                      label: 'Mechanic ID',
                      value: widget.slot.mechanicId ?? 'Not assigned',
                    ),
                  ],
                ),
              ),
            ),

            // Feedback Section
            if (widget.slot.clientFeedback != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rate_review, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Client Feedback',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.slot.clientFeedback!),
                    ],
                  ),
                ),
              ),
            ],

            if (widget.slot.mechanicFeedback != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Mechanic Notes',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.slot.mechanicFeedback!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            if (isPending && widget.slot.status == AppointmentStatus.scheduled) ...[
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _acceptAppointment,
                icon: const Icon(Icons.check),
                label: const Text('Accept Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isProcessing ? null : _declineAppointment,
                icon: const Icon(Icons.close),
                label: const Text('Decline Appointment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ] else if (isMyAppointment &&
                widget.slot.status == AppointmentStatus.scheduled) ...[
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _completeAppointment,
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

