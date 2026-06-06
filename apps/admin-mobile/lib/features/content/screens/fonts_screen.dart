import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class FontsScreen extends ConsumerWidget {
  const FontsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Fonts'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, i) => ContentCard(
          title: ['Inter', 'Roboto', 'Playfair Display', 'Space Grotesk', 'JetBrains Mono', 'Poppins', 'Merriweather', 'Fira Code', 'DM Sans', 'IBM Plex'][i],
          subtitle: i % 2 == 0 ? 'Sans-serif' : 'Serif',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(days: i * 3)),
          icon: Icons.text_fields,
        ),
      ),
    );
  }
}
