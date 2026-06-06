import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AdminColors.textMuted),
        prefixIcon: const Icon(Icons.search, size: 18, color: AdminColors.textMuted),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16, color: AdminColors.textMuted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: AdminColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
