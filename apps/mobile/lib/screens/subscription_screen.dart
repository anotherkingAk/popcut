import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args})? onNavigate;

  const SubscriptionScreen({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'yearly';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticService.trigger(HapticLevel.light);
            widget.onBack();
          },
        ),
        title: const Text('Upgrade Plan'),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
            },
            child: const Text('Restore', style: TextStyle(color: AppColors.brand500)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildCurrentPlan(),
            const SizedBox(height: 20),
            _buildBillingToggle(),
            const SizedBox(height: 20),
            _buildPlanCard(
              keyValue: 'monthly',
              name: 'Pro Monthly',
              price: '\$9.99',
              period: '/month',
              color: AppColors.brand500,
              features: [
                'Unlimited exports up to 1080p',
                'AI captions (8 languages)',
                'Premium templates library',
                'No watermark',
                'Cloud sync (5GB)',
              ],
              isPopular: false,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              keyValue: 'yearly',
              name: 'Pro Yearly',
              price: '\$49.99',
              period: '/year',
              color: AppColors.primary,
              features: [
                'Everything in Pro Monthly',
                'AI voice cloning',
                '4K export',
                'Priority export queue',
                'Cloud sync (50GB)',
                'Early access features',
              ],
              isPopular: true,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              keyValue: 'lifetime',
              name: 'Lifetime',
              price: '\$149.99',
              period: ' one-time',
              color: AppColors.trackAudio,
              features: [
                'Everything in Pro Yearly',
                'Future premium features',
                'Unlimited cloud storage',
                'Priority support',
                'Beta access',
              ],
              isPopular: false,
            ),
            const SizedBox(height: 24),
            _buildFeatureComparison(),
            const SizedBox(height: 24),
            _buildPaymentSection(),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  HapticService.trigger(HapticLevel.light);
                },
                child: const Text('Terms of Service  •  Privacy Policy', style: TextStyle(fontSize: 12, color: AppColors.textLow)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgSurface, AppColors.bgElevated],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.textLow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline, size: 22, color: AppColors.textMedium),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Plan', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
                const SizedBox(height: 2),
                const Text('Free', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh)),
                const Text('10 exports/month, watermark', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticService.trigger(HapticLevel.light);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _billingOption('Monthly', 'monthly'),
          _billingOption('Yearly', 'yearly'),
          _billingOption('Lifetime', 'lifetime'),
        ],
      ),
    );
  }

  Widget _billingOption(String label, String value) {
    final isSelected = _selectedPlan == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selectedPlan = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brand500 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.textHigh : AppColors.textMedium,
                ),
              ),
              if (value == 'yearly') ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textHigh.withValues(alpha: 0.2) : AppColors.brand500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'SAVE 58%',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.textHigh : AppColors.brand500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String keyValue,
    required String name,
    required String price,
    required String period,
    required Color color,
    required List<String> features,
    required bool isPopular,
  }) {
    final isSelected = _selectedPlan == keyValue;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selectedPlan = keyValue);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPopular
                ? [color.withValues(alpha: 0.1), AppColors.bgSurface]
                : [AppColors.bgSurface, AppColors.bgSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                const Spacer(),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('BEST VALUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textHigh, letterSpacing: 0.5)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color)),
                Text(period, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: color),
                  const SizedBox(width: 10),
                  Text(f, style: const TextStyle(fontSize: 13, color: AppColors.textHigh)),
                ],
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  HapticService.trigger(HapticLevel.medium);
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppColors.textHigh,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textHigh))
                    : Text('Subscribe $price$period', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    final sections = [
      {
        'title': 'Export',
        'features': ['1080p export', '4K export', 'No watermark', 'Priority export'],
      },
      {
        'title': 'AI Tools',
        'features': ['Auto captions', 'Voice cloning', 'Text to video', 'Beat sync'],
      },
      {
        'title': 'Storage',
        'features': ['Cloud sync', 'Unlimited storage', 'Team workspace'],
      },
      {
        'title': 'Support',
        'features': ['Email support', 'Priority support', 'Dedicated manager'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feature Comparison', style: AppTypography.titleSm),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildComparisonHeader(),
              ...sections.map((s) => _buildComparisonSection(s['title'] as String, s['features'] as List<String>)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('Feature', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLow, letterSpacing: 0.5))),
          Expanded(child: Center(child: Text('Free', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLow)))),
          Expanded(child: Center(child: Text('Pro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand500)))),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String title, List<String> features) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: AppColors.bgElevated,
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        ),
        ...features.map((f) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textHigh))),
              Expanded(child: Center(child: Icon(Icons.close, size: 16, color: AppColors.textDisabled))),
              Expanded(child: Center(child: Icon(Icons.check, size: 16, color: AppColors.success))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accepted payment methods', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
          const SizedBox(height: 12),
          Row(
            children: [
              _paymentChip('Visa', Icons.credit_card),
              const SizedBox(width: 8),
              _paymentChip('MC', Icons.credit_card),
              const SizedBox(width: 8),
              _paymentChip('PayPal', Icons.payments_outlined),
              const SizedBox(width: 8),
              _paymentChip('Crypto', Icons.currency_bitcoin),
            ],
          ),
          const SizedBox(height: 12),
          const Text('All payments processed securely via Stripe', style: TextStyle(fontSize: 11, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMedium),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}
