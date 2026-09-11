import 'package:flutter/services.dart';

/// Haptics kept in one place so a reduced-motion accessibility
/// setting can disable them app-wide later.
abstract final class Haptics {
  static void select() => HapticFeedback.selectionClick();
  static void confirm() => HapticFeedback.mediumImpact();
  static void danger() => HapticFeedback.heavyImpact();
}
