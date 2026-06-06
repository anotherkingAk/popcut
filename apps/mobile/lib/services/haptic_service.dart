import 'package:flutter/services.dart';

enum HapticLevel {
  light,
  medium,
  heavy,
  selection,
  error,
  success,
}

class HapticService {
  static void trigger(HapticLevel level) {
    switch (level) {
      case HapticLevel.light:
        HapticFeedback.lightImpact();
      case HapticLevel.medium:
        HapticFeedback.mediumImpact();
      case HapticLevel.heavy:
        HapticFeedback.heavyImpact();
      case HapticLevel.selection:
        HapticFeedback.selectionClick();
      case HapticLevel.error:
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 50), () => HapticFeedback.heavyImpact());
        Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact());
      case HapticLevel.success:
        HapticFeedback.mediumImpact();
    }
  }

  static void snap() => trigger(HapticLevel.light);
  static void select() => trigger(HapticLevel.light);
  static void press() => trigger(HapticLevel.light);
  static void navSwitch() => trigger(HapticLevel.light);
  static void split() => trigger(HapticLevel.medium);
  static void delete() => trigger(HapticLevel.heavy);
  static void exportStart() => trigger(HapticLevel.medium);
  static void exportComplete() => trigger(HapticLevel.success);
  static void error() => trigger(HapticLevel.error);
  static void longPress() => trigger(HapticLevel.medium);
  static void newProject() => trigger(HapticLevel.medium);
  static void proUpsell() => trigger(HapticLevel.medium);
}
