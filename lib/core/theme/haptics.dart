import 'package:flutter/services.dart';

/// Haptics kept in one place so a reduced-motion accessibility
/// setting can disable them app-wide later.
abstract final class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void select() => HapticFeedback.selectionClick();
  static void confirm() => HapticFeedback.mediumImpact();
  static void danger() => HapticFeedback.heavyImpact();
}

typedef Haptics = AppHaptics;

