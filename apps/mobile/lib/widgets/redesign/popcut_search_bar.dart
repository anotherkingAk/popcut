import 'package:flutter/material.dart';
import '../../theme/popcut_theme.dart';

class PopCutSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;

  const PopCutSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hintText = 'Search templates, effects...',
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: PopCutColors.glass(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PopCutColors.glassBorder(),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: PopCutColors.primary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        autofocus: autofocus,
        focusNode: focusNode,
        style: PopCutTypography.bodySmall.copyWith(
          color: PopCutColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: PopCutTypography.bodySmall.copyWith(
            color: PopCutColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: PopCutColors.textMuted,
            size: 20,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PopCutColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: PopCutColors.primary,
              size: 16,
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
