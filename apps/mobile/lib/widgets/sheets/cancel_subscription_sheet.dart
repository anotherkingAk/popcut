import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class CancelSubscriptionSheet extends StatelessWidget {
  const CancelSubscriptionSheet({super.key});

  static const _reasons = ['Too expensive', 'Not using enough', 'Missing features', 'Other'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Cancel Subscription',
      icon: Icons.cancel_outlined,
      body: const CancelSubscriptionSheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you leaving?', style: AppTypography.titleSm),
          const SizedBox(height: 4),
          Text('Your feedback helps us improve', style: AppTypography.bodySm),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((r) => _ReasonChip(label: r)).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You will lose access to:', style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                const SizedBox(height: 8),
                ...['4K Export & high bitrate', 'Cloud backup & sync', 'Premium filters & effects',
                     'Priority customer support', 'No watermarks']
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.remove_circle_outline, size: 14, color: AppColors.error),
                              const SizedBox(width: 6),
                              Text(item, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                            ],
                          ),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm Cancellation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Keep Subscription',
                  style: TextStyle(color: AppColors.brand500, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatefulWidget {
  final String label;
  const _ReasonChip({required this.label});

  @override
  State<_ReasonChip> createState() => _ReasonChipState();
}

class _ReasonChipState extends State<_ReasonChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selected = !_selected);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.error.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.error : AppColors.border,
          ),
        ),
        child: Text(widget.label, style: TextStyle(
          fontSize: 13,
          color: selected ? AppColors.error : AppColors.textMedium,
        )),
      ),
    );
  }
}
