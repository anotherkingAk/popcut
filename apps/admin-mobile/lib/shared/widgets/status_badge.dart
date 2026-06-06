import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.filled = false,
  });

  factory StatusBadge.active() => const StatusBadge(label: 'Active', color: AdminColors.success);
  factory StatusBadge.pending() => const StatusBadge(label: 'Pending', color: AdminColors.warning);
  factory StatusBadge.suspended() => const StatusBadge(label: 'Suspended', color: AdminColors.error);
  factory StatusBadge.banned() => const StatusBadge(label: 'Banned', color: AdminColors.error);
  factory StatusBadge.completed() => const StatusBadge(label: 'Completed', color: AdminColors.success);
  factory StatusBadge.failed() => const StatusBadge(label: 'Failed', color: AdminColors.error);
  factory StatusBadge.running() => const StatusBadge(label: 'Running', color: AdminColors.primary);
  factory StatusBadge.draft() => const StatusBadge(label: 'Draft', color: AdminColors.textMuted);
  factory StatusBadge.approved() => const StatusBadge(label: 'Approved', color: AdminColors.success);
  factory StatusBadge.rejected() => const StatusBadge(label: 'Rejected', color: AdminColors.error);

  static StatusBadge fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusBadge.active();
      case 'pending':
        return StatusBadge.pending();
      case 'suspended':
        return StatusBadge.suspended();
      case 'banned':
        return StatusBadge.banned();
      case 'completed':
      case 'done':
        return StatusBadge.completed();
      case 'failed':
      case 'error':
        return StatusBadge.failed();
      case 'running':
      case 'processing':
        return StatusBadge.running();
      case 'draft':
        return StatusBadge.draft();
      case 'approved':
        return StatusBadge.approved();
      case 'rejected':
        return StatusBadge.rejected();
      default:
        return StatusBadge(label: status, color: AdminColors.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!filled) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: filled ? color : color),
          ),
        ],
      ),
    );
  }
}
