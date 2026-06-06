import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class KeyframeIntroCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'What are Keyframes',
        description: 'Keyframes let you animate properties like position, scale, and rotation over time for stunning motion effects.',
      ),
      CoachMarkStep(
        title: 'Add Keyframe',
        description: 'Tap the diamond icon to add a keyframe at the current playhead position on the selected clip.',
        spotlight: const Rect.fromLTWH(180, 340, 40, 32),
      ),
      CoachMarkStep(
        title: 'Animate Properties',
        description: 'Adjust position, scale, rotation, or opacity at different keyframes to create smooth animations.',
        spotlight: const Rect.fromLTWH(40, 300, 320, 48),
      ),
    ]);
  }
}
