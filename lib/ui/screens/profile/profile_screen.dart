import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final me = b.currentUser;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: me == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
              children: [
                // ── Identity card ──────────────────────────────────
                SoftCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GradientAvatar(
                            name: me.publicName,
                            photoUrl: me.photoUrl,
                            size: 64,
                          ),
                          const SizedBox(width: AppDimens.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'You',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    if (me.verifiedBadge) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded,
                                          size: 20, color: AppColors.info),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TintPill(
                                    label: me.gender.label,
                                    bg: AppColors.surfaceMuted,
                                    fg: AppColors.textSecondary,
                                    icon: me.gender.icon,
                                    small: true,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  me.bio.isEmpty
                                      ? 'No bio yet'
                                      : me.bio,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.lg),

                      // Trust stats
                      Row(
                        children: [
                          StatTile(
                            value: '${me.completedCount}',
                            label: 'Completed',
                          ),
                          const SizedBox(width: AppDimens.sm),
                          StatTile(
                            value: me.ratingLabel,
                            label: 'Rating (${me.ratingCount})',
                          ),
                          const SizedBox(width: AppDimens.sm),
                          StatTile(
                            value: '${me.reliabilityPercent}%',
                            label: 'Reliability',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // ── Karma wallet (Time Credits) ───────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.deepSpace,
                    borderRadius: BorderRadius.circular(AppDimens.rTile),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.auroraViolet.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.diamond_rounded,
                            color: AppColors.auroraMint, size: 24),
                      ),
                      const SizedBox(width: AppDimens.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Time Credits',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${me.karma} credits — earn by helping, spend on perks',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // ── Earned trust badges (Phase 8) ─────────────────
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trust badges',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: AppDimens.md),
                      if (me.badges.isEmpty)
                        const Text(
                          'Complete activities and receive mutual reviews to earn badges like Punctual, Friendly and Safe Helper.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.45),
                        )
                      else
                        Wrap(
                          spacing: AppDimens.sm,
                          runSpacing: AppDimens.sm,
                          children: TrustBadge.values
                              .where((b) => me.badges.contains(b))
                              .map(
                                (b) => TintPill(
                                  label: b.label,
                                  bg: b.soft,
                                  fg: b.color,
                                  icon: b.icon,
                                  small: true,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // ── Emergency roster toggles ─────────────────────
                SoftCard(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.aurora,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.access_time_filled_rounded,
                              color: Colors.white, size: 20),
                        ),
                        title: const Text('Available Now',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        subtitle: const Text(
                            'On the emergency helpers roster',
                            style: TextStyle(fontSize: 12)),
                        value: me.availableNow,
                        activeThumbColor: AppColors.success,
                        onChanged: (_) => b.toggleAvailableNow(),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.violetDream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: Colors.white, size: 20),
                        ),
                        title: const Text('Guardian Shield',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                        subtitle: const Text(
                            'ID-verified priority responder',
                            style: TextStyle(fontSize: 12)),
                        value: me.isGuardian,
                        activeThumbColor: AppColors.auroraViolet,
                        onChanged: (_) => b.toggleGuardianShield(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // ── Trust ladder ───────────────────────────────────
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trust level',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: AppDimens.md),
                      _trustRow('Email verified', true, AppColors.success),
                      _trustRow('Identity verified', me.verifiedBadge,
                          AppColors.info),
                      _trustRow(
                          'Established member', me.isEstablished,
                          AppColors.coral),
                      const SizedBox(height: AppDimens.sm),
                      const Text(
                        'Established = 40+ completed activities with strong ratings. Verification never required to browse or apply.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.md),

                // ── Preferences & safety links ─────────────────────
                SoftCard(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule_rounded),
                        title: const Text('Availability',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(me.availabilityHours,
                            style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.health_and_safety_rounded),
                        title: const Text('Safety Center',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(
                          'Contact: ${me.safetyContactName ?? "not set"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/safety'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.diamond_rounded),
                        title: const Text('Play & Earn',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('Games that bank Time Credits',
                            style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/play'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.redeem_rounded),
                        title: const Text('Partner Perks',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('Spend credits at local shops',
                            style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/perks'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.forum_rounded),
                        title: const Text('Community Board',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('Suggest & upvote ideas',
                            style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/community'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_rounded),
                        title: const Text('Settings',
                            style:
                                TextStyle(fontWeight: FontWeight.w800)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _trustRow(String label, bool ok, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
            size: 18,
            color: ok ? color : AppColors.strokeStrong,
          ),
          const SizedBox(width: AppDimens.md),
          Text(label,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
