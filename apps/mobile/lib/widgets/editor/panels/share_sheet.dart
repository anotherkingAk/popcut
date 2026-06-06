import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_motion.dart';
import '../../../services/haptic_service.dart';

class ShareSheet extends StatelessWidget {
  final AnimationController staggerController;
  const ShareSheet({super.key, required this.staggerController});

  final _methods = const [
    _ShareMethod('Camera Roll', Icons.photo_library),
    _ShareMethod('Instagram', Icons.camera_alt),
    _ShareMethod('TikTok', Icons.music_note),
    _ShareMethod('YouTube', Icons.play_circle_outline),
    _ShareMethod('WhatsApp', Icons.chat),
    _ShareMethod('Copy Link', Icons.link),
    _ShareMethod('More...', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMethodRow(),
                const SizedBox(height: 16),
                _buildVideoInfo(),
                const SizedBox(height: 16),
                _buildToggleRow('Include Project File', false),
                _buildToggleRow('High Quality Preview', true),
                const SizedBox(height: 16),
                _buildExpirationPicker(),
                const SizedBox(height: 16),
                _buildAnalytics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: const Text('Share', style: AppTypography.titleSm),
    );
  }

  Widget _buildMethodRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Share to', style: AppTypography.bodySm),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _methods.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => HapticService.trigger(HapticLevel.light),
              child: Container(
                width: 64,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_methods[i].icon, size: 22, color: AppColors.textHigh),
                    const SizedBox(height: 4),
                    Text(_methods[i].name, style: const TextStyle(fontSize: 8, color: AppColors.textLow), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _InfoRow('Resolution', '1920 x 1080'),
          _InfoRow('Duration', '2:30'),
          _InfoRow('File Size', '245 MB'),
          _InfoRow('Codec', 'H.264'),
        ],
      ),
    );
  }

  Widget _buildExpirationPicker() {
    final durations = ['Never', '1 Day', '3 Days', '7 Days', '30 Days'];
    return Row(
      children: [
        const Text('Expiration', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticService.trigger(HapticLevel.light),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(durations[0], style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
                const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textLow),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalytics() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.analytics, size: 16, color: AppColors.info),
          SizedBox(width: 8),
          Text('Share Analytics', style: TextStyle(fontSize: 11, color: AppColors.info)),
          Spacer(),
          Text('Coming Soon', style: TextStyle(fontSize: 10, color: AppColors.textLow)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodySm),
        const Spacer(),
        Switch(value: value, onChanged: (_) => HapticService.trigger(HapticLevel.light)),
      ],
    );
  }
}

class _ShareMethod {
  final String name;
  final IconData icon;
  const _ShareMethod(this.name, this.icon);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLow)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
        ],
      ),
    );
  }
}
