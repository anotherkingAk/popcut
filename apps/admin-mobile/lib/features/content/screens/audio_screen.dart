import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class AudioScreen extends ConsumerWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Audio'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (_, i) => ContentCard(
          title: ['Ambient', 'Upbeat', 'Cinematic', 'LoFi', 'Electronic', 'Acoustic', 'Synth'][i],
          subtitle: '${(i + 1) * 30}s audio track',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(days: i * 4)),
          icon: Icons.music_note,
        ),
      ),
    );
  }
}
