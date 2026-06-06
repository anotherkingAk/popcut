import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Payment Method',
      icon: Icons.credit_card_outlined,
      body: const PaymentMethodSheet(),
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
          Text('Select method', style: AppTypography.label),
          const SizedBox(height: 8),
          _MethodCard(Icons.apple, 'Apple Pay', 'Pay with Apple Pay'),
          const SizedBox(height: 8),
          _MethodCard(Icons.credit_card, 'Card', 'Credit or debit card'),
          const SizedBox(height: 8),
          _MethodCard(Icons.payment, 'PayPal', 'Pay with PayPal account'),
          const SizedBox(height: 20),
          Text('Saved Cards', style: AppTypography.label),
          const SizedBox(height: 8),
          _SavedCard('•••• 4242', 'Visa', 'Expires 12/26'),
          const SizedBox(height: 6),
          _SavedCard('•••• 8888', 'Mastercard', 'Expires 08/25'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticService.trigger(HapticLevel.light);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bgElevated,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 16, color: AppColors.brand500),
                  const SizedBox(width: 6),
                  const Text('Add new card', style: TextStyle(color: AppColors.brand500, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Confirm Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.textLow),
                const SizedBox(width: 6),
                const Text('Secured with SSL encryption', style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _MethodCard(this.icon, this.label, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.textHigh),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleSm),
                  Text(subtitle, style: AppTypography.bodySm),
                ],
              ),
            ),
            const Icon(Icons.radio_button_unchecked, size: 20, color: AppColors.textLow),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final String number;
  final String network;
  final String expiry;
  const _SavedCard(this.number, this.network, this.expiry);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 24,
              decoration: BoxDecoration(
                color: AppColors.bgOverlay,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(child: Text(network.substring(0, 2), style: const TextStyle(fontSize: 10, color: AppColors.textMedium))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(number, style: AppTypography.bodyMd)),
            Text(expiry, style: AppTypography.bodySm),
          ],
        ),
      ),
    );
  }
}
