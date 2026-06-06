import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class TimelineGestureCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Timeline Overview',
        description: 'The timeline is where you arrange and edit your video clips, audio, and effects.',
        spotlight: const Rect.fromLTWH(0, 400, 400, 200),
      ),
      CoachMarkStep(
        title: 'Scrub & Seek',
        description: 'Drag the playhead to quickly preview any part of your video.',
        spotlight: const Rect.fromLTWH(60, 390, 300, 16),
      ),
      CoachMarkStep(
        title: 'Zoom Timeline',
        description: 'Pinch to zoom in and out for precise frame-by-frame editing.',
        pointerLabel: 'Pinch to zoom',
      ),
    ]);
  }
}
