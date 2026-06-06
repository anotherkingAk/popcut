import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';
import '../../widgets/redesign/popcut_card.dart';
import '../../widgets/redesign/popcut_grid.dart';
import '../../widgets/redesign/popcut_section_header.dart';

class AiStudioScreenRedesign extends StatefulWidget {
  final VoidCallback onBack;

  const AiStudioScreenRedesign({super.key, required this.onBack});

  @override
  State<AiStudioScreenRedesign> createState() => _AiStudioScreenRedesignState();
}

class _AiStudioScreenRedesignState extends State<AiStudioScreenRedesign> {
  int _credits = 15;
  String? _activePrompt;
  bool _isGenerating = false;
  bool _showPreview = false;

  final _promptControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final tool in _aiTools) {
      _promptControllers[tool.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _promptControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PopCutColors.background,
      appBar: AppBar(
        backgroundColor: PopCutColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: PopCutColors.textPrimary,
          onPressed: widget.onBack,
        ),
        title: const Text('AI Studio'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: PopCutColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PopCutColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 12, color: PopCutColors.primary),
                const SizedBox(width: 6),
                Text('$_credits credits',
                    style: PopCutTypography.captionBold.copyWith(
                      color: PopCutColors.primary,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PopCutSectionHeader(title: 'AI Tools'),
            ),
            const SizedBox(height: 14),
            _buildToolGrid(),
            const SizedBox(height: 24),
            if (_showPreview) _buildPreviewSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00D4FF),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: PopCutShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('BETA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    )),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome_rounded,
                  size: 20, color: Colors.white.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('AI-Powered Creation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
          const SizedBox(height: 6),
          Text(
            'Generate videos, templates, effects, and\nmore with a single prompt',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _heroChip('$_credits credits left', Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              _heroChip('Pro: Unlimited',
                  const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildToolGrid() {
    return PopCutGrid(
      itemCount: _aiTools.length,
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, i) => _buildToolCard(_aiTools[i]),
    );
  }

  Widget _buildToolCard(_AiTool tool) {
    final hasPrompt = _promptControllers[tool.name]?.text.isNotEmpty ?? false;

    return PopCutCard(
      padding: const EdgeInsets.all(14),
      hasGlow: true,
      glowColor: tool.color,
      backgroundColor: tool.color.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool.icon, size: 20, color: tool.color),
              ),
              const Spacer(),
              if (tool.isPro)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PRO',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(tool.name,
              style: PopCutTypography.captionBold.copyWith(fontSize: 13)),
          const SizedBox(height: 3),
          Text(tool.description,
              style: PopCutTypography.caption.copyWith(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          // Prompt input
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: PopCutColors.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PopCutColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _promptControllers[tool.name],
              style: PopCutTypography.caption.copyWith(fontSize: 10),
              decoration: InputDecoration(
                hintText: 'Enter prompt...',
                hintStyle: PopCutTypography.caption.copyWith(fontSize: 10),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: hasPrompt ? () => _generate(tool) : null,
            child: Container(
              width: double.infinity,
              height: 28,
              decoration: BoxDecoration(
                gradient: hasPrompt
                    ? LinearGradient(
                        colors: [tool.color, tool.color.withValues(alpha: 0.7)])
                    : null,
                color: hasPrompt ? null : PopCutColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isGenerating && _activePrompt == tool.name
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Generate',
                        style: PopCutTypography.captionBold.copyWith(
                          fontSize: 10,
                          color: hasPrompt
                              ? Colors.white
                              : PopCutColors.textMuted,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate(_AiTool tool) async {
    setState(() {
      _isGenerating = true;
      _activePrompt = tool.name;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _showPreview = true;
        _credits--;
      });
    }
  }

  Widget _buildPreviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopCutSectionHeader(
            title: 'Preview',
            actionLabel: 'Edit',
            onActionTap: () {},
          ),
          const SizedBox(height: 12),
          PopCutCard(
            padding: EdgeInsets.zero,
            hasGlow: true,
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: PopCutColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: PopCutColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 28, color: PopCutColors.primary),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Generated Preview',
                                style: PopCutTypography.captionBold),
                            Text('Tap to view full result',
                                style: PopCutTypography.caption),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PopCutColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PopCutColors.primary,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTool {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPro;

  const _AiTool({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isPro = false,
  });
}

final _aiTools = <_AiTool>[
  _AiTool(name: 'AI Video Generator', description: 'Create videos from text prompts with AI', icon: Icons.auto_awesome_rounded, color: PopCutColors.primary),
  _AiTool(name: 'AI Template Generator', description: 'Generate custom templates from descriptions', icon: Icons.dashboard_customize_rounded, color: PopCutColors.secondary, isPro: true),
  _AiTool(name: 'AI Effect Generator', description: 'Auto-generate video effects and transitions', icon: Icons.bolt_rounded, color: PopCutColors.success),
  _AiTool(name: 'AI Voice Generator', description: 'Synthesize realistic voiceovers in any style', icon: Icons.record_voice_over_rounded, color: PopCutColors.warning),
  _AiTool(name: 'AI Caption Generator', description: 'Auto-generate captions in multiple languages', icon: Icons.closed_caption_rounded, color: PopCutColors.error),
  _AiTool(name: 'AI Thumbnail Generator', description: 'Design stunning thumbnails with AI', icon: Icons.image_rounded, color: PopCutColors.primary, isPro: true),
];
