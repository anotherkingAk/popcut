import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class EffectsScreen extends ConsumerWidget {
  const EffectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Effects'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, i) => ContentCard(
          title: 'Effect ${i + 1}',
          subtitle: i % 2 == 0 ? 'Video effect' : 'Transition effect',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(days: i)),
          icon: Icons.auto_fix_high,
        ),
      ),
    );
  }
}
