import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class MultiSelectCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Select Multiple',
        description: 'Long press on a clip, then tap additional clips to select multiple items at once.',
        spotlight: const Rect.fromLTWH(80, 420, 80, 40),
      ),
      CoachMarkStep(
        title: 'Batch Actions',
        description: 'Move, delete, or apply effects to all selected clips simultaneously from this toolbar.',
        spotlight: const Rect.fromLTWH(0, 360, 400, 36),
      ),
    ]);
  }
}
