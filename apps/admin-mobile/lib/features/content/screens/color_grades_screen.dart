import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../content/widgets/content_card.dart';

class ColorGradesScreen extends ConsumerWidget {
  const ColorGradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('Color Grades'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())), actions: [IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {})]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => ContentCard(
          title: ['Warm Tone', 'Cool Tone', 'Teal & Orange', 'Monochrome', 'Vibrant'][i],
          subtitle: 'Color grading preset',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(days: i * 5)),
          icon: Icons.palette,
        ),
      ),
    );
  }
}
