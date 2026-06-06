import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FeatureFlagsScreen extends ConsumerWidget {
  const FeatureFlagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Feature Flags'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FlagTile(label: 'AI Video Generation', description: 'Enable AI-powered video creation', enabled: true),
          _FlagTile(label: 'Collaborative Editing', description: 'Multiple users can edit simultaneously', enabled: true),
          _FlagTile(label: 'Cloud Sync', description: 'Sync projects across devices', enabled: true),
          _FlagTile(label: 'Advanced Analytics', description: 'Detailed user behavior tracking', enabled: false),
          _FlagTile(label: 'Social Sharing', description: 'Direct share to social platforms', enabled: true),
          _FlagTile(label: 'API Access', description: 'Allow third-party API integration', enabled: false),
          _FlagTile(label: 'Beta Features', description: 'Enable experimental features', enabled: false),
        ],
      ),
    );
  }
}

class _FlagTile extends StatefulWidget {
  final String label;
  final String description;
  final bool enabled;
  const _FlagTile({required this.label, required this.description, required this.enabled});

  @override
  State<_FlagTile> createState() => _FlagTileState();
}

class _FlagTileState extends State<_FlagTile> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AdminColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border.withValues(alpha: 0.5))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label, style: AppTypography.titleMedium.copyWith(color: AdminColors.textPrimary)),
            const SizedBox(height: 2),
            Text(widget.description, style: AppTypography.caption.copyWith(color: AdminColors.textMuted)),
          ]),
        ),
        Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
      ]),
    );
  }
}
