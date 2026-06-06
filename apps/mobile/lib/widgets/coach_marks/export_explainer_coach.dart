import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class ExportExplainerCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Export Your Project',
        description: 'Ready to share? Tap the Export button to render your video in your preferred format.',
        spotlight: const Rect.fromLTWH(300, 340, 80, 36),
      ),
      CoachMarkStep(
        title: 'Export Settings',
        description: 'Choose resolution, frame rate, bitrate, and format. Pro users can export up to 4K.',
        spotlight: const Rect.fromLTWH(16, 200, 360, 160),
      ),
      CoachMarkStep(
        title: 'Share',
        description: 'Share your video directly to social media, save to gallery, or copy the share link.',
      ),
    ]);
  }
}
