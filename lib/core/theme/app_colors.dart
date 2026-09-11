import 'package:flutter/material.dart';

/// TIME~NEED design tokens — Material 3 Expressive direction:
/// deep-ink base, aurora gradients (mint→sky, violet→lilac, coral→amber),
/// soft glows, generous radii. Single source of truth for the whole app.
abstract final class AppColors {
  // ── Canvas (light) ─────────────────────────────────────────────
  static const canvas = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEEF1F7);

  // ── Ink (deep) — used for hero sections, CTAs, text ────────────
  static const ink = Color(0xFF101323);
  static const inkSoft = Color(0xFF1B2036);
  static const inkContainer = Color(0xFF232A47);

  // ── Aurora palette (the brand gradients) ───────────────────────
  static const auroraMint = Color(0xFF5EEAD4); // teal-mint
  static const auroraSky = Color(0xFF60A5FA); // bright blue
  static const auroraViolet = Color(0xFF8B5CF6); // vivid violet
  static const auroraLilac = Color(0xFFC4B5FD); // soft lilac
  static const auroraCoral = Color(0xFFFB7185); // rose coral
  static const auroraAmber = Color(0xFFFBBF24); // warm amber

  /// Primary brand gradient: mint → sky (hero, CTAs, active states).
  static const aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [auroraMint, auroraSky],
  );

  /// Secondary gradient: violet → lilac (company posts, deals).
  static const violetDream = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [auroraViolet, auroraLilac],
  );

  /// Warm gradient: coral → amber (offers, treats, highlights).
  static const sunsetPop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [auroraCoral, auroraAmber],
  );

  /// Deep ink gradient for premium dark cards / splash.
  static const deepSpace = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0E1F), Color(0xFF1B2036), Color(0xFF2A1E4F)],
  );

  // ── Text ───────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F1222);
  static const textSecondary = Color(0xFF5A6072);
  static const textFaint = Color(0xFF9CA3B5);
  static const textOnInk = Color(0xFFFFFFFF);
  static const textOnAurora = Color(0xFF062B3A);

  // ── Status ─────────────────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const successSoft = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFEF3C7);
  static const danger = Color(0xFFF43F5E);
  static const dangerSoft = Color(0xFFFFE4E6);
  static const info = Color(0xFF3B82F6);
  static const infoSoft = Color(0xFFDBEAFE);

  // ── Strokes & glows ────────────────────────────────────────────
  static const stroke = Color(0xFFE4E8F0);
  static const strokeStrong = Color(0xFFCDD3E0);
  static const glow = Color(0x335EEAD4); // mint glow
  static const glassFill = Color(0xB3FFFFFF); // glass card fill
  static const scrim = Color(0x99000000);

  /// Ambient page background with soft aurora blobs.
  static const pageAmbient = BoxDecoration();

  // ── Legacy aliases (pre-revamp screens → new palette) ──────────
  static const mint = auroraMint;
  static const mintSoft = Color(0xFFCCFBF1);
  static const mintFaint = Color(0xFFF0FDFA);
  static const heroMint = Color(0xFF99F6E4);
  static const coral = auroraCoral;
  static const coralSoft = Color(0xFFFFE4E6);
  static const sky = auroraSky;
  static const skySoft = Color(0xFFDBEAFE);
  static const lavender = auroraLilac;
  static const lavenderSoft = Color(0xFFEDE9FE);
  static const lavenderFaint = Color(0xFFF5F3FF);
  static const butter = auroraAmber;
  static const butterSoft = Color(0xFFFEF3C7);
  static const peachSoft = Color(0xFFFFE4E6);
  static const pageGlow = Color(0x145EEAD4);

  /// Soft pastel gradients for tinted cards (carousels, upcoming rows).
  /// Cycle through them by index for a lively but harmonious feed.
  static const List<LinearGradient> cardTints = [
    // mint → sky
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFDFF6EF), Color(0xFFE3F0FD)],
    ),
    // violet → blush
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0EBFE), Color(0xFFFBEFFA)],
    ),
    // peach → butter
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFEDE4), Color(0xFFFFF7DB)],
    ),
    // emerald → mint
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE2F8EC), Color(0xFFF2FCF4)],
    ),
  ];
}
