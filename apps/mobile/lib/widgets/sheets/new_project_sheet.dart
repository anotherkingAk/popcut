import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class NewProjectSheet extends StatelessWidget {
  const NewProjectSheet({super.key});

  static const _aspectRatios = [
    ('16:9', 16 / 9),
    ('9:16', 9 / 16),
    ('1:1', 1.0),
    ('4:3', 4 / 3),
    ('21:9', 21 / 9),
  ];

  static const _templates = ['Vlog', 'Gaming', 'Tutorial', 'Travel', 'Music Video', 'Story'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'New Project',
      icon: Icons.add_circle_outline,
      body: const NewProjectSheet(),
      maxHeightFactor: 0.95,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: 'Untitled Project');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aspect Ratio', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _aspectRatios.map((ar) => _AspectRatioChip(label: ar.$1, ratio: ar.$2)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Project Name', style: AppTypography.label),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: nameController,
              style: AppTypography.bodyLg,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'Project name',
                hintStyle: TextStyle(color: AppColors.textLow),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Templates', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _templates.map((t) => _TemplateChip(label: t)).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Create Project'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AspectRatioChip extends StatefulWidget {
  final String label;
  final double ratio;
  const _AspectRatioChip({required this.label, required this.ratio});

  @override
  State<_AspectRatioChip> createState() => _AspectRatioChipState();
}

class _AspectRatioChipState extends State<_AspectRatioChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selected = !_selected);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500.withValues(alpha: 0.15) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.brand500 : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: widget.ratio > 1 ? 24 : 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.brand500 : AppColors.textLow,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Text(widget.label, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.textHigh : AppColors.textMedium,
            )),
          ],
        ),
      ),
    );
  }
}

class _TemplateChip extends StatefulWidget {
  final String label;
  const _TemplateChip({required this.label});

  @override
  State<_TemplateChip> createState() => _TemplateChipState();
}

class _TemplateChipState extends State<_TemplateChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return GestureDetector(
      onTap: () {
        HapticService.trigger(HapticLevel.light);
        setState(() => _selected = !_selected);
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500 : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
        ),
        child: Text(widget.label, style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? AppColors.textHigh : AppColors.textMedium,
        )),
      ),
    );
  }
}
