/// Layout tokens — expressive radii scale (M3 Expressive uses larger,
/// more organic corner treatments).
abstract final class AppDimens {
  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double huge = 36;

  // Radii — expressive scale
  static const double rSm = 12;
  static const double rMd = 16;
  static const double rCard = 24;
  static const double rTile = 20;
  static const double rField = 16;
  static const double rSheet = 32;
  static const double rPill = 999;

  // Legacy aliases (compat)
  static const double rChip = 24;

  // Component sizes
  static const double navBarHeight = 76;
  static const double fabSize = 60;
  static const double tapTarget = 48;
}
