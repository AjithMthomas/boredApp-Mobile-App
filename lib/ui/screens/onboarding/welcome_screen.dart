import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../widgets/common.dart';

/// Post-signup celebration: aurora hero ring + four gradient value cards.
/// Every icon is a Material symbol on a gradient tile — no emoji anywhere.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3F0FF), AppColors.canvas],
            stops: [0, 0.4],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.xl),
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/logo_icon.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              // Celebration ring
              Center(
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    gradient: AppColors.violetDream,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.auroraViolet.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: AppDimens.xl),
              const Text(
                'You\'re in!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),
              const SizedBox(height: AppDimens.sm),
              const Text(
                'Madiwala is your micro-market. Here\'s what you can do:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: AppDimens.xl),
              _card(
                gradient: AppColors.aurora,
                icon: Icons.volunteer_activism_rounded,
                title: 'Help someone',
                sub: 'Small tasks nearby — earn from help, or do it free.',
                delay: 420,
              ),
              _card(
                gradient: AppColors.violetDream,
                icon: Icons.emoji_food_beverage_rounded,
                title: 'Spend time together',
                sub: 'Tea, walks, gyms, movies — company without transaction.',
                delay: 520,
              ),
              _card(
                gradient: AppColors.sunsetPop,
                icon: Icons.redeem_rounded,
                title: 'Share & offer',
                sub: 'Extra ticket, trip seat, free lunch — generosity, structured.',
                delay: 620,
              ),
              _card(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFFA7F3D0)],
                ),
                icon: Icons.diversity_3_rounded,
                title: 'Find company',
                sub: 'Not every interaction needs money. Just presence.',
                delay: 720,
              ),
              const SizedBox(height: AppDimens.xl),
              PrimaryButton(
                label: 'Explore Madiwala',
                icon: Icons.explore_rounded,
                onPressed: () => context.go('/home'),
              ).animate(delay: 850.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppDimens.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String sub,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: SoftCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppDimens.rSm + 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auroraSky.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: delay.ms)
          .fadeIn(duration: 450.ms)
          .slideX(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
