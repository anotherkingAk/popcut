import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class ExportQualitySheet extends StatelessWidget {
  const ExportQualitySheet({super.key});

  static const _resolutions = ['1080p', '720p', '480p', '4K'];
  static const _formats = ['MP4', 'MOV'];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Export Quality',
      icon: Icons.settings_outlined,
      body: const ExportQualitySheet(),
      maxHeightFactor: 0.92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quality', style: AppTypography.label),
          const SizedBox(height: 8),
          _QualitySlider(),
          const SizedBox(height: 20),
          Text('Format', style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: _formats.map((f) => _FormatChip(label: f)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Resolution', style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _resolutions.map((r) => _ResolutionChip(label: r)).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textMedium),
                const SizedBox(width: 8),
                const Text('Estimated size: ', style: AppTypography.bodyMd),
                const Text('124 MB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                const Spacer(),
                const Text('~2 min', style: AppTypography.bodySm),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PulseExportButton(),
        ],
      ),
    );
  }
}

class _QualitySlider extends StatefulWidget {
  @override
  State<_QualitySlider> createState() => _QualitySliderState();
}

class _QualitySliderState extends State<_QualitySlider> {
  double _value = 85;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('${_value.round()}%', style: AppTypography.displaySm),
            const Spacer(),
            Text(_value < 50 ? 'Fast' : _value < 80 ? 'Balanced' : 'Best quality',
                style: AppTypography.bodySm),
          ],
        ),
        Slider(
          value: _value,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (v) => setState(() => _value = v),
          onChangeEnd: (_) => HapticService.trigger(HapticLevel.light),
        ),
      ],
    );
  }
}

class _FormatChip extends StatefulWidget {
  final String label;
  const _FormatChip({required this.label});

  @override
  State<_FormatChip> createState() => _FormatChipState();
}

class _FormatChipState extends State<_FormatChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticService.trigger(HapticLevel.light);
          setState(() => _selected = !_selected);
        },
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500 : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.brand500 : AppColors.border),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMedium,
          )),
        ),
      ),
    );
  }
}

class _ResolutionChip extends StatefulWidget {
  final String label;
  const _ResolutionChip({required this.label});

  @override
  State<_ResolutionChip> createState() => _ResolutionChipState();
}

class _ResolutionChipState extends State<_ResolutionChip> {
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
        child: Text(widget.label, style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.textHigh : AppColors.textMedium,
        )),
      ),
    );
  }
}

class _PulseExportButton extends StatefulWidget {
  @override
  State<_PulseExportButton> createState() => _PulseExportButtonState();
}

class _PulseExportButtonState extends State<_PulseExportButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(scale: _pulse.value, child: child),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticService.trigger(HapticLevel.light);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand500,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
