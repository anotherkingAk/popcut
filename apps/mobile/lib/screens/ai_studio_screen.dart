import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class AiStudioScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String route, {Map<String, dynamic>? args})? onNavigate;

  const AiStudioScreen({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final int _creditsRemaining = 15;

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
        title: const Text('AI Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              HapticService.trigger(HapticLevel.light);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 24),
            Text('AI Tools', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildToolGrid(),
            const SizedBox(height: 24),
            Text('Recent AI Generations', style: AppTypography.titleSm),
            const SizedBox(height: 12),
            _buildRecentList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brand500, AppColors.primary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.glassBase,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('BETA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textHigh, letterSpacing: 1)),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome, size: 20, color: AppColors.textHigh.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 16),
          Text('AI-Powered Creation', style: AppTypography.titleLg.copyWith(color: AppColors.textHigh)),
          const SizedBox(height: 4),
          Text(
            'Generate captions, music, and effects\nwith a single tap',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textHigh.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _creditChip('$_creditsRemaining credits left'),
              const SizedBox(width: 8),
              _creditChip('Pro: Unlimited'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creditChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHigh)),
    );
  }

  Widget _buildToolGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _aiTools.length,
      itemBuilder: (_, i) => _buildToolCard(_aiTools[i]),
    );
  }

  Widget _buildToolCard(_AiTool tool) {
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tool.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tool.icon, size: 18, color: tool.color),
                ),
                const Spacer(),
                if (tool.isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brand500, AppColors.brand300],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PRO', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppColors.textHigh, letterSpacing: 0.3)),
                  ),
              ],
            ),
            const Spacer(),
            Text(tool.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
            const SizedBox(height: 2),
            Text(tool.description, style: const TextStyle(fontSize: 10, color: AppColors.textLow), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${tool.usage}k uses', style: const TextStyle(fontSize: 9, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    final items = [
      {'name': 'Summer Edit - Captions', 'time': '2h ago'},
      {'name': 'Product Showcase - BG Music', 'time': '5h ago'},
      {'name': 'Travel Vlog - Narration', 'time': '1d ago'},
    ];
    return Column(
      children: items.map((item) => GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brand500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.brand500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name']!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textHigh),
                ),
              ),
              Text(
                item['time']!,
                style: const TextStyle(fontSize: 11, color: AppColors.textLow),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _AiTool {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPro;
  final int usage;

  const _AiTool({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isPro = false,
    this.usage = 0,
  });
}

const _aiTools = <_AiTool>[
  _AiTool(name: 'Auto Captions', description: 'Generate captions in 8 languages with perfect sync', icon: Icons.closed_caption, color: AppColors.textMedium, usage: 12),
  _AiTool(name: 'Voice Clone', description: 'Clone any voice in 3 seconds for realistic voiceovers', icon: Icons.record_voice_over, color: AppColors.textMedium, isPro: true, usage: 8),
  _AiTool(name: 'Text to Video', description: 'Generate complete videos from text descriptions', icon: Icons.text_fields, color: AppColors.textMedium, isPro: true, usage: 5),
  _AiTool(name: 'Beat Sync', description: 'Auto-sync clips to music beats perfectly', icon: Icons.music_note, color: AppColors.textMedium, usage: 9),
  _AiTool(name: 'Smart Crop', description: 'AI-powered auto reframe for any aspect ratio', icon: Icons.crop, color: AppColors.textMedium, usage: 6),
  _AiTool(name: 'Colorize', description: 'Auto color grade with cinematic LUT presets', icon: Icons.color_lens, color: AppColors.textMedium, usage: 7),
  _AiTool(name: 'Upscale', description: 'Enhance video resolution up to 4K with AI', icon: Icons.enhance_photo_translate, color: AppColors.textMedium, isPro: true, usage: 4),
  _AiTool(name: 'Remove Background', description: 'Auto green screen without a physical backdrop', icon: Icons.backup_table, color: AppColors.textMedium, usage: 3),
];
