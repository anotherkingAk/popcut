import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class ProTeaserCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Unlock Pro',
        description: 'Upgrade to PopCut and unlock premium features for professional video creation.',
        spotlight: const Rect.fromLTWH(260, 48, 100, 32),
      ),
      CoachMarkStep(
        title: 'Premium Tools',
        description: 'Get access to AI tools, 4K export, premium templates, unlimited cloud storage, and no watermark.',
      ),
    ]);
  }
}
