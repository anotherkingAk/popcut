import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class TemplateDetailScreen extends StatefulWidget {
  final String templateId;
  final String templateName;
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args})? onNavigate;

  const TemplateDetailScreen({
    super.key,
    required this.templateId,
    required this.templateName,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  bool _isFavorited = false;
  double _rating = 4.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoPreview(),
                    const SizedBox(height: 16),
                    _buildTemplateInfo(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    _buildScenesSection(),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              widget.onBack();
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? AppColors.error : AppColors.textMedium,
            ),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
              setState(() => _isFavorited = !_isFavorited);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textMedium),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.movie, size: 64, color: AppColors.textDisabled),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 32, color: AppColors.brand500),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bgOverlay,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('0:15', style: TextStyle(fontSize: 11, color: AppColors.textHigh)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.templateName,
                  style: AppTypography.titleLg,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brand500, AppColors.brand300],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textHigh, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppColors.textLow),
              const SizedBox(width: 4),
              Text('By @creator_pro', style: TextStyle(fontSize: 13, color: AppColors.brand500)),
              const Spacer(),
              ...List.generate(5, (i) {
                final filled = i < _rating.floor();
                final half = !filled && i < _rating.ceil();
                return Icon(
                  half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
                  size: 16,
                  color: AppColors.warning,
                );
              }),
              const SizedBox(width: 4),
              Text(_rating.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textLow)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A professional-grade video template perfect for social media content, featuring dynamic transitions and motion graphics.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.timer_outlined, '0:15'),
              const SizedBox(width: 12),
              _infoChip(Icons.layers_outlined, '4 tracks'),
              const SizedBox(width: 12),
              _infoChip(Icons.favorite_border, '1.2k uses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgOverlay,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textLow),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.medium);
                widget.onNavigate?.call('/editor', args: {'templateId': widget.templateId});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Use Template', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textHigh,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticService.trigger(HapticLevel.light);
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textHigh,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Preview Scenes', style: AppTypography.titleSm),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final colors = [
                AppColors.trackVideo, AppColors.trackOverlay,
                AppColors.trackAudio, AppColors.trackText,
                AppColors.trackEffect, AppColors.trackGraphic,
              ];
              return GestureDetector(
                onTap: () {
                  HapticService.trigger(HapticLevel.light);
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: colors[i].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors[i].withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.image_outlined, size: 24, color: colors[i]),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 6,
                        child: Text(
                          'Scene ${i + 1}',
                          style: TextStyle(fontSize: 9, color: colors[i], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    final recs = ['Cinematic Opener', 'Vlog Intro', 'Tutorial Start', 'Travel Reel'];
    final recColors = [
      AppColors.trackVideo, AppColors.trackAudio,
      AppColors.trackEffect, AppColors.trackOverlay,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Recommended Templates', style: AppTypography.titleSm),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  HapticService.trigger(HapticLevel.light);
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: recColors[i].withValues(alpha: 0.15),
                          child: Center(
                            child: Icon(Icons.movie_outlined, size: 28, color: recColors[i]),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          recs[i],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textHigh),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
