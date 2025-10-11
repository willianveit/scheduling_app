import 'package:flutter/material.dart';
import 'package:scheduling_app/core/enums/appointment_status.dart';
import 'package:scheduling_app/domain/entities/slot.dart';

class SlotCard extends StatelessWidget {
  final Slot slot;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SlotCard({super.key, required this.slot, this.onTap, this.trailing});

  Color _getStatusColor() {
    switch (slot.status) {
      case AppointmentStatus.available:
        return Colors.green;
      case AppointmentStatus.scheduled:
        return Colors.orange;
      case AppointmentStatus.canceled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (slot.status) {
      case AppointmentStatus.available:
        return Icons.check_circle;
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.canceled:
        return Icons.cancel;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(_getStatusIcon(), color: _getStatusColor(), size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.appointmentTime,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slot.status.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (slot.clientId != null)
                      Text(
                        'Client: ${slot.clientId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (slot.mechanicId != null)
                      Text(
                        'Mechanic: ${slot.mechanicId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
