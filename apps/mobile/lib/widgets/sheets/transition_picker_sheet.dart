import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../services/haptic_service.dart';
import '../../widgets/common/app_bottom_sheet.dart';

class TransitionPickerSheet extends StatelessWidget {
  const TransitionPickerSheet({super.key});

  static const _categories = ['Basic', 'Smooth', 'Glitch', '3D', 'Light', 'Creative'];

  static const _transitions = [
    ('Cross Fade', Icons.blur_on),
    ('Fade to Black', Icons.dark_mode),
    ('Slide Left', Icons.arrow_left),
    ('Slide Right', Icons.arrow_right),
    ('Slide Up', Icons.arrow_upward),
    ('Slide Down', Icons.arrow_downward),
    ('Zoom In', Icons.zoom_in),
    ('Zoom Out', Icons.zoom_out),
    ('Wipe', Icons. swipe),
    ('Glitch', Icons.flash_on),
    ('Spin', Icons.rotate_right),
    ('Cube', Icons.view_in_ar),
  ];

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: 'Transition',
      icon: Icons.animation,
      body: const TransitionPickerSheet(),
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
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((c) => _CategoryChip(label: c)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _transitions.length,
            itemBuilder: (_, i) => _TransitionTile(
              icon: _transitions[i].$2,
              label: _transitions[i].$1,
            ),
          ),
          const SizedBox(height: 16),
          Text('Duration', style: AppTypography.label),
          Row(
            children: [
              const Text('0.3s', style: AppTypography.bodySm),
              Expanded(
                child: Slider(value: 0.5, min: 0.1, max: 2.0, divisions: 19, onChanged: (_) {}),
              ),
              const Text('2.0s', style: AppTypography.bodySm),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ToggleRow('Apply to all'),
              const Spacer(),
              _ToggleRow('Favorite'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticService.trigger(HapticLevel.light);
                Navigator.pop(context);
              },
              child: const Text('Apply Transition'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand500 : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMedium,
          )),
        ),
      ),
    );
  }
}

class _TransitionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TransitionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticService.trigger(HapticLevel.light),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgOverlay,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 20, color: AppColors.textMedium),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  final String label;
  const _ToggleRow(this.label);

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        const SizedBox(width: 6),
        Switch(
          value: _value,
          onChanged: (v) {
            HapticService.trigger(HapticLevel.light);
            setState(() => _value = v);
          },
        ),
      ],
    );
  }
}
