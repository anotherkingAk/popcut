import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../models/project.dart';
import '../../services/haptic_service.dart';

class ContextualToolbar extends StatelessWidget {
  final SelectionState selectionState;
  final String? selectedClipName;
  final VoidCallback onBack;
  final VoidCallback onExport;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const ContextualToolbar({
    super.key,
    required this.selectionState,
    this.selectedClipName,
    required this.onBack,
    required this.onExport,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          _ToolbarBtn(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 4),
          Container(width: 1, height: 22, color: AppColors.border),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: AppMotion.clipSelect,
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: selectionState == SelectionState.editing && selectedClipName != null
                ? _EditingTitle(name: selectedClipName!)
                : const _ProjectTitle(),
          ),
          const Spacer(),
          _ToolbarBtn(icon: Icons.undo, onTap: onUndo),
          _ToolbarBtn(icon: Icons.redo, onTap: onRedo),
          const SizedBox(width: 4),
          Container(width: 1, height: 22, color: AppColors.border),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () { HapticService.trigger(HapticLevel.medium); onExport(); },
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_upload_outlined, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolbarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34, height: 34,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () { HapticService.trigger(HapticLevel.light); onTap(); },
          child: Center(child: Icon(icon, size: 18, color: AppColors.foregroundSecondary)),
        ),
      ),
    );
  }
}

class _ProjectTitle extends StatelessWidget {
  const _ProjectTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('Untitled Project', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
    );
  }
}

class _EditingTitle extends StatelessWidget {
  final String name;
  const _EditingTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
        ],
      ),
    );
  }
}
