import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class TransitionsScreen extends ConsumerWidget {
  const TransitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Transitions'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, i) => ContentCard(
          title: ['Fade', 'Slide', 'Zoom', 'Wipe', 'Blur', 'Cross'][i],
          subtitle: '${i + 1}x transition style',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(days: i * 2)),
          icon: Icons.swap_horiz,
        ),
      ),
    );
  }
}
