import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class AiTourCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'AI Studio',
        description: 'PopCut\'s AI-powered tools help you create professional videos with a single tap.',
        spotlight: const Rect.fromLTWH(16, 80, 72, 80),
      ),
      CoachMarkStep(
        title: 'Auto Captions',
        description: 'Automatically generate accurate captions in multiple languages with perfect timing.',
        spotlight: const Rect.fromLTWH(16, 200, 160, 80),
      ),
      CoachMarkStep(
        title: 'Voice Cloning',
        description: 'Clone any voice in seconds and generate realistic voiceovers for your videos.',
        spotlight: const Rect.fromLTWH(16, 300, 160, 80),
      ),
      CoachMarkStep(
        title: 'Text to Video',
        description: 'Generate complete videos from a text prompt. Just describe what you want and let AI do the rest.',
      ),
    ]);
  }
}
