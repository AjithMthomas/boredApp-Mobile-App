import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../widgets/common.dart';

/// Create hub — every posting flow in the app lives here:
///  • Quick posts   → Task / Company / Offer (guided wizard)
///  • Community     → SOS broadcast, Shop Gig, Room search, Team & trips
///  • Auction house → host an item or time-slot auction
///
/// Verticals deep-link with `?create=1` so the hub's create sheet opens
/// the moment you land — pick a card, fill the sheet, done.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Create'),
        leading: const UniformBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.xl, AppDimens.sm, AppDimens.xl, 40),
        children: [
          const Text(
            'What are you posting?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppDimens.sm),
          const Text(
            'Everything is guided — pick the closest match.',
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.xl),

          // ── Quick posts ───────────────────────────────────────────
          const _GroupLabel('QUICK POSTS'),
          for (final t in PostType.values) ...[
            ChoiceCard(
              icon: t.icon,
              iconGradient: switch (t) {
                PostType.task => AppColors.aurora,
                PostType.company => AppColors.violetDream,
                PostType.offer => AppColors.sunsetPop,
              },
              title: t.label,
              subtitle: t.tagline,
              selected: false,
              onTap: () => context.push('/create/wizard?type=${t.name}'),
            ),
            const SizedBox(height: AppDimens.md),
          ],

          // ── Community & work ─────────────────────────────────────
          const _GroupLabel('COMMUNITY & WORK'),
          _VerticalTile(
            icon: Icons.emergency_share_rounded,
            tint: AppColors.dangerSoft,
            iconColor: AppColors.danger,
            title: 'SOS — urgent help',
            subtitle:
                'Broadcast to on-call helpers & Guardians nearby right now',
            onTap: () => context.push('/emergency?create=1'),
          ),
          const SizedBox(height: AppDimens.md),
          _VerticalTile(
            icon: Icons.storefront_rounded,
            tint: AppColors.butterSoft,
            iconColor: AppColors.auroraAmber,
            title: 'Hire shop staff',
            subtitle: 'Post a short-term gig with daily pay for your shop',
            onTap: () => context.push('/gigs?create=1'),
          ),
          const SizedBox(height: AppDimens.md),
          _VerticalTile(
            icon: Icons.night_shelter_rounded,
            tint: AppColors.lavenderSoft,
            iconColor: AppColors.auroraViolet,
            title: 'Find a room or flat',
            subtitle: '1RK to 2BHK — local scouts hunt with your budget',
            onTap: () => context.push('/rooms?create=1'),
          ),
          const SizedBox(height: AppDimens.md),
          _VerticalTile(
            icon: Icons.diversity_3_rounded,
            tint: AppColors.mintSoft,
            iconColor: AppColors.success,
            title: 'Make a team or trip',
            subtitle: 'Gather heads for a game, event or outing — with UPI split',
            onTap: () => context.push('/team?create=1'),
          ),
          const SizedBox(height: AppDimens.xl),

          // ── Auction house ────────────────────────────────────────
          const _GroupLabel('AUCTION HOUSE'),
          _VerticalTile(
            icon: Icons.gavel_rounded,
            tint: AppColors.lavenderSoft,
            iconColor: AppColors.auroraViolet,
            title: 'Host a live auction',
            subtitle: 'Sell items or expert time slots to the highest bidder',
            onTap: () => context.push('/auctions/create'),
          ),
        ],
      ),
    );
  }
}

/// Small overline grouping label.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textFaint,
        ),
      ),
    );
  }
}

/// Full-width navigation tile for a posting vertical — same skeleton as
/// [ChoiceCard] but with a chevron instead of a radio, since it routes.
class _VerticalTile extends StatelessWidget {
  const _VerticalTile({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.rTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.rTile),
        onTap: () {
          Haptics.select();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rTile),
            border: Border.all(color: AppColors.stroke.withValues(alpha: 0.7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A101323),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(AppDimens.rSm + 2),
                ),
                child: Icon(icon, size: 22, color: iconColor),
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
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
