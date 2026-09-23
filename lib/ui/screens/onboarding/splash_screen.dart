// White modern splash: brand name front and center, clean and airy.
// Pairs with the native white launch screen for a seamless cold start.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Clean white splash. A tiny mint/sky aurora breath keeps it alive without
/// clutter; the wordmark is the hero, exactly as a 5s-glance brand moment
/// should be. 1.6s total, then hands off to auth.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/auth/email');
    });
    // Real session restore happens in the router redirect (signedIn flag);
    // the splash is purely the brand moment.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Whisper-soft aurora washes — barely-there color on white.
          Positioned(
            top: -140,
            right: -110,
            child: _wash(320, AppColors.auroraMint.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: -160,
            left: -120,
            child: _wash(360, AppColors.auroraSky.withValues(alpha: 0.09)),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Wordmark: the hero ──────────────────────────────
                // "nuv" in ink + "ra" in brand blue — a single accent that
                // makes the name memorable without extra decoration.
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'nuv',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'ra',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.auroraMint, AppColors.auroraSky],
                            ).createShader(
                              // "ra" is roughly 60px wide at this size.
                              const Rect.fromLTWH(0, 0, 62, 70),
                            ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 450.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.35,
                      end: 0,
                      duration: 550.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 10),

                // ── Shimmer underline ────────────────────────────────
                // A mint→sky bar sweeps in under the name, then keeps a
                // gentle pulse — modern, minimal, alive.
                Container(
                  height: 4,
                  width: 118,
                  decoration: BoxDecoration(
                    gradient: AppColors.aurora,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                    .animate(
                      delay: 400.ms,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fadeIn(duration: 350.ms)
                    .scaleX(
                      begin: 0.15,
                      end: 1,
                      alignment: Alignment.center,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .then(delay: 200.ms)
                    .scaleX(
                      begin: 1,
                      end: 0.82,
                      duration: 1100.ms,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 18),

                // ── Tagline ─────────────────────────────────────────
                Text(
                  'Time for needs. Needs for time.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate(delay: 650.ms)
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.25, end: 0, duration: 450.ms),

                const SizedBox(height: 72),

                // ── Loading indicator ───────────────────────────────
                // Three brand-colored dots breathing in sequence instead of
                // a plain spinner — lighter and more on-brand.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.auroraSky,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeOut(delay: (i * 160).ms, duration: 420.ms);
                  }),
                ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wash(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
