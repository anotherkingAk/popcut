import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/ai_factory_provider.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  final _promptController = TextEditingController();
  String _selectedType = 'text_to_video';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_promptController.text.trim().isEmpty) return;
    final success = await ref.read(aiFactoryProvider.notifier).generate({
      'type': _selectedType,
      'prompt': _promptController.text.trim(),
    });
    if (success && mounted) {
      _promptController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiFactoryProvider);
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(title: const Text('AI Generate'), leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Create with AI', style: AppTypography.headlineMedium.copyWith(color: AdminColors.textPrimary)),
          const SizedBox(height: 24),
          Text('Generation Type', style: AppTypography.titleSmall.copyWith(color: AdminColors.textSecondary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: InputDecoration(filled: true, fillColor: AdminColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.border))),
            dropdownColor: AdminColors.surface,
            items: const [
              DropdownMenuItem(value: 'text_to_video', child: Text('Text to Video', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'image_to_video', child: Text('Image to Video', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'video_editing', child: Text('Video Editing', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'audio_generation', child: Text('Audio Generation', style: TextStyle(color: Colors.white))),
            ],
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 20),
          Text('Prompt', style: AppTypography.titleSmall.copyWith(color: AdminColors.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _promptController,
            maxLines: 5,
            style: const TextStyle(color: AdminColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Describe what you want to create...',
              hintStyle: const TextStyle(color: AdminColors.textMuted),
              filled: true, fillColor: AdminColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.isGenerating ? null : _generate,
            child: state.isGenerating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Generate'),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 16),
            AppErrorWidget(message: state.error!),
          ],
        ]),
      ),
    );
  }
}
