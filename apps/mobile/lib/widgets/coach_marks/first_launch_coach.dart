import 'package:flutter/material.dart';
import '../common/coach_mark.dart';

class FirstLaunchCoach {
  static Future<void> show(BuildContext context) async {
    await CoachMarkOverlay.show(context, [
      CoachMarkStep(
        title: 'Welcome to PopCut',
        description: 'Create stunning videos with professional editing tools right at your fingertips.',
        spotlight: const Rect.fromLTWH(60, 8, 100, 36),
      ),
      CoachMarkStep(
        title: 'Your Projects',
        description: 'All your video projects live here. Tap any project to continue editing.',
        spotlight: const Rect.fromLTWH(16, 100, 160, 120),
      ),
      CoachMarkStep(
        title: 'Quick Actions',
        description: 'Tap the + button to create a new project, import media, or use AI tools.',
        spotlight: const Rect.fromLTWH(16, 80, 72, 80),
      ),
      CoachMarkStep(
        title: 'Get Started',
        description: 'Create your first project now and experience professional video editing.',
      ),
    ]);
  }
}
