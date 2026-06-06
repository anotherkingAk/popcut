import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';

class TextEditorPanel extends StatelessWidget {
  final AnimationController staggerController;
  const TextEditorPanel({super.key, required this.staggerController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
            child: Row(
              children: [
                const Text('Text Editor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                const Spacer(),
                _styleChip('B'),
                _styleChip('I'),
                _styleChip('U'),
                const SizedBox(width: 12),
                _styleChip('Aa'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _section('Content', [
                  _textField('Enter your text here...'),
                ]),
                _section('Font', [
                  _row('Font', 'Inter'),
                  _row('Size', '48'),
                  _row('Color', '#FFFFFF'),
                  _row('Alignment', 'Center'),
                ]),
                _section('Animation', [
                  _row('Style', 'Fade In'),
                  _row('Duration', '0.5s'),
                  _row('Delay', '0s'),
                ]),
                _section('Background', [
                  _row('Fill', 'None'),
                  _row('Padding', '8px'),
                  _row('Opacity', '80%'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styleChip(String label) {
    return GestureDetector(
      onTap: () { HapticService.trigger(HapticLevel.light); },
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 28, height: 28,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.foreground))),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.foregroundSecondary, letterSpacing: 0.5)),
        ),
        ...children,
      ],
    );
  }

  Widget _textField(String hint) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 14, color: AppColors.foreground),
        decoration: InputDecoration.collapsed(hintText: 'Enter your text here...', hintStyle: TextStyle(color: AppColors.foregroundMuted)),
        maxLines: 3,
      ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.foregroundSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 14, color: AppColors.foregroundMuted),
        ],
      ),
    );
  }
}
