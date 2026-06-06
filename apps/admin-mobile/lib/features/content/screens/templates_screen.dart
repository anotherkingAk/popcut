import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Templates'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => ContentCard(
          title: 'Template ${i + 1}',
          subtitle: 'Video template category',
          status: i % 2 == 0 ? 'active' : 'draft',
          createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
          icon: Icons.dashboard_customize,
        ),
      ),
    );
  }
}
