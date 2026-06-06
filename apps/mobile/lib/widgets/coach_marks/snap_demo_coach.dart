import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class SnapDemoCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Snap Guides',
        description: 'Clips automatically snap to the timeline ruler markers for precise alignment.',
        spotlight: const Rect.fromLTWH(0, 390, 400, 20),
      ),
      CoachMarkStep(
        title: 'Snap Points',
        description: 'Drag clips near the playhead or markers and they will snap into place automatically.',
        spotlight: const Rect.fromLTWH(120, 420, 80, 40),
      ),
    ]);
  }
}
