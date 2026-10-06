// White modern splash: full-screen NEEDY Lottie loading animation.
// Pairs with native launch screen for a seamless cold start.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';

/// Full-screen initial loading splash screen powered by the NEEDY Lottie animation.
/// Plays full-screen on cold start, then hands off to auth.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/auth/email');
    });
    // Session restore is handled by the router redirect;
    // splash screen displays the full-screen NEEDY brand animation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Soft ambient aurora background washes
          Positioned(
            top: -120,
            right: -100,
            child: _wash(340, AppColors.auroraMint.withValues(alpha: 0.12)),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _wash(380, AppColors.auroraSky.withValues(alpha: 0.10)),
          ),

          // Full-screen centered NEEDY Lottie loading animation
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 380,
                      maxHeight: 380,
                    ),
                    child: Lottie.asset(
                      'assets/animations/needy_loading.json',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/animations/needy_loading.gif',
                        width: 320,
                        height: 320,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
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
