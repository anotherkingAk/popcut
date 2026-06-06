import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args}) onNavigate;

  const DeleteAccountScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  int _currentStep = 0;
  String? _selectedReason;
  final _confirmController = TextEditingController();
  bool _isDeleting = false;

  final _reasons = [
    'Privacy concerns',
    'Not using the app',
    'Found better alternatives',
    'Too expensive',
    'Technical issues',
    'Other',
  ];

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticService.trigger(HapticLevel.light);
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              widget.onBack();
            }
          },
        ),
        title: const Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 24),
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isCompleted = i < _currentStep;
        final isCurrent = i == _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? (isCurrent ? AppColors.brand500 : AppColors.error)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildReasonStep();
      case 1:
        return _buildConfirmationStep();
      case 2:
        return _buildFinalStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.sentiment_dissatisfied_outlined, size: 48, color: AppColors.textMedium),
        const SizedBox(height: 16),
        Text('We\'re sorry to see you go', style: AppTypography.titleLg),
        const SizedBox(height: 8),
        Text(
          'Please tell us why you\'re deleting your account so we can improve.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: 24),
        Text('Reason for leaving', style: AppTypography.titleSm),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () {
                HapticService.trigger(HapticLevel.light);
                setState(() => _selectedReason = reason);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.error.withValues(alpha: 0.15) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.error : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.error : AppColors.textHigh,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedReason == null
                ? null
                : () {
                    HapticService.trigger(HapticLevel.medium);
                    setState(() => _currentStep = 1);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              disabledBackgroundColor: AppColors.bgSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
        const SizedBox(height: 16),
        Text('Review Account Information', style: AppTypography.titleLg),
        const SizedBox(height: 8),
        Text(
          'Please review your account details before proceeding. This action cannot be undone.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _infoRow('Email', 'user@example.com'),
              const Divider(color: AppColors.border, height: 16),
              _infoRow('Member Since', 'January 2025'),
              const Divider(color: AppColors.border, height: 16),
              _infoRow('Projects', '12 projects'),
              const Divider(color: AppColors.border, height: 16),
              _infoRow('Subscription', 'Free plan'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All your projects, data, and subscription will be permanently deleted.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticService.trigger(HapticLevel.medium);
              setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('I Understand, Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    final isConfirmed = _confirmController.text.trim() == 'DELETE';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.dangerous_outlined, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text('Final Confirmation', style: AppTypography.titleLg),
        const SizedBox(height: 8),
        Text(
          'Type DELETE below to confirm you want to permanently remove your account.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _confirmController,
          autofocus: true,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Type DELETE',
            hintStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 4,
            ),
            filled: true,
            fillColor: AppColors.bgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isConfirmed ? AppColors.error : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isConfirmed ? AppColors.error : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This action is permanent and cannot be undone.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isConfirmed && !_isDeleting
                ? () {
                    HapticService.trigger(HapticLevel.heavy);
                    setState(() => _isDeleting = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() => _isDeleting = false);
                        widget.onNavigate('/home');
                      }
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              disabledBackgroundColor: AppColors.bgSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isDeleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textHigh))
                : const Text('Permanently Delete Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLow)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textHigh)),
      ],
    );
  }
}
