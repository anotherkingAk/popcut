import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class SubscriptionPlansSheet extends StatelessWidget {
  const SubscriptionPlansSheet({super.key});


  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Choose Plan',
      icon: Icons.workspace_premium,
      body: const SubscriptionPlansSheet(),
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
          Text('Unlock all features', style: AppTypography.bodyMd),
          const SizedBox(height: 16),
          _buildTierCard('Monthly', '\$9.99', '/mo', false, 'Basic editing, 1080p export'),
          const SizedBox(height: 10),
          _buildTierCard('Yearly', '\$69.99', '/yr', true, 'Everything + 4K export, Cloud backup',
              badge: 'Save 42%'),
          const SizedBox(height: 10),
          _buildTierCard('Lifetime', '\$149.99', ' once', false, 'All current & future features'),
          const SizedBox(height: 20),
          Text('All plans include:', style: AppTypography.label),
          const SizedBox(height: 8),
          ...['No watermarks', 'Priority support', 'All filters & effects', 'Unlimited projects']
              .map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(f, style: AppTypography.bodyMd),
                      ],
                    ),
                  )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue with Yearly', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Restore Purchase', style: TextStyle(color: AppColors.textLow)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(String name, String price, String period, bool isPopular, String desc,
      {String? badge}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [AppColors.brand500.withValues(alpha: 0.15), AppColors.bgElevated])
            : null,
        color: isPopular ? null : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? AppColors.brand500 : AppColors.border,
          width: isPopular ? 1.5 : 0.5,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: AppTypography.titleMd),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge, style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: AppTypography.displayMd),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(period, style: AppTypography.bodySm),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(desc, style: AppTypography.bodyMd),
            ],
          ),
        ],
      ),
    );
  }
}
