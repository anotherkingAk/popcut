import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class KeyboardShortcutsCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Keyboard Shortcuts',
        description: 'Speed up your editing workflow with keyboard shortcuts. Press ? to view all shortcuts.',
        spotlight: const Rect.fromLTWH(0, 0, 400, 200),
      ),
      CoachMarkStep(
        title: 'Master Shortcuts',
        description: 'Essential shortcuts: Space to play/pause, I/O to set in/out points, S to split, Ctrl+Z to undo, Ctrl+C/V to copy/paste clips.',
      ),
    ]);
  }
}
