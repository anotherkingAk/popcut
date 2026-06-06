import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
  });

  factory StatusBadge.active() =>
      StatusBadge(label: 'Active', color: AdminColors.success);

  factory StatusBadge.suspended() =>
      StatusBadge(label: 'Suspended', color: AdminColors.warning);

  factory StatusBadge.banned() =>
      StatusBadge(label: 'Banned', color: AdminColors.error);

  factory StatusBadge.pending() =>
      StatusBadge(label: 'Pending', color: AdminColors.warning);

  factory StatusBadge.completed() =>
      StatusBadge(label: 'Completed', color: AdminColors.success);

  factory StatusBadge.failed() =>
      StatusBadge(label: 'Failed', color: AdminColors.error);

  factory StatusBadge.running() =>
      StatusBadge(label: 'Running', color: AdminColors.info);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'approved':
        return AdminColors.success;
      case 'suspended':
      case 'pending':
        return AdminColors.warning;
      case 'banned':
      case 'failed':
      case 'rejected':
        return AdminColors.error;
      case 'running':
      case 'processing':
        return AdminColors.info;
      default:
        return AdminColors.textMedium;
    }
  }

  factory StatusBadge.fromStatus(String status) {
    return StatusBadge(
      label: status[0].toUpperCase() + status.substring(1),
      color: statusColor(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminColors.textMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
    );
  }
}
