import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class TrimHintCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Trim Clips',
        description: 'Drag the edge handles of any clip to trim its duration. Yellow handles indicate trim points.',
        spotlight: const Rect.fromLTWH(100, 410, 200, 40),
      ),
      CoachMarkStep(
        title: 'Precision Edit',
        description: 'Switch between ripple edit and roll edit modes for frame-accurate trimming.',
        spotlight: const Rect.fromLTWH(160, 370, 80, 32),
      ),
    ]);
  }
}
