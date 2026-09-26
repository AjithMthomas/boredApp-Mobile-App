// Phase 1 — On-Demand Emergency Helpers & Guardian Network.
// SOS broadcast, live helper roster, Available-Now / Guardian toggles.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_avatar.dart';

class EmergencyHubScreen extends ConsumerStatefulWidget {
  const EmergencyHubScreen({super.key, this.autoOpenCreate = false});

  /// When true (via `/emergency?create=1`) the SOS sheet opens on arrival.
  final bool autoOpenCreate;

  @override
  ConsumerState<EmergencyHubScreen> createState() => _EmergencyHubScreenState();
}

class _EmergencyHubScreenState extends ConsumerState<EmergencyHubScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  GenderPreference _genderPref = GenderPreference.anyone;

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSosSheet();
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _broadcast() {
    final b = ref.read(storeProvider).backend;
    if (_titleCtrl.text.trim().length < 4 ||
        _areaCtrl.text.trim().isEmpty) {
      return;
    }
    Haptics.confirm();
    final t = b.broadcastEmergency(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? 'Urgent help needed — details in chat.'
          : _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      genderPref: _genderPref,
    );
    _titleCtrl.clear();
    _descCtrl.clear();
    _areaCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        content: const Row(
          children: [
            Icon(Icons.emergency_share_rounded, color: AppColors.danger),
            SizedBox(width: 12),
            Expanded(child: Text('SOS broadcast — nearby helpers alerted.')),
          ],
        ),
      ),
    );
    context.push('/task/${t.id}');
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final me = b.currentUser;
    final feed = b.emergencyFeed;
    final helpers = b.availableHelpers;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Emergency Helpers'),
        leading: const UniformBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 40),
        children: [
          // ── Poster hero with live glass stats + SOS ─────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/posters/poster_emergency.png',
                    width: double.infinity,
                    height: 196,
                    fit: BoxFit.cover,
                  ),

                  // Live count chips (top-right, glass).
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius:
                            BorderRadius.circular(AppDimens.rPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        '${b.availableNowCount} on-call · ${b.guardianCount} Guardians',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // SOS button floating on the poster.
                  Positioned(
                    left: AppDimens.lg,
                    bottom: 14,
                    child: _SosButton(onTap: _openSosSheet),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.lg),

          // ── My roster toggles ───────────────────────────────────
          SoftCard(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.aurora,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.access_time_filled_rounded,
                        color: Colors.white, size: 22),
                  ),
                  title: const Text('Available Now',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text(
                      'Appear on the on-call roster for sudden requests',
                      style: TextStyle(fontSize: 12)),
                  value: me?.availableNow ?? false,
                  activeThumbColor: AppColors.success,
                  onChanged: (_) => b.toggleAvailableNow(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.violetDream,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 22),
                  ),
                  title: const Text('Guardian Shield',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text(
                      'ID-verified responder — gets priority SOS dispatch',
                      style: TextStyle(fontSize: 12)),
                  value: me?.isGuardian ?? false,
                  activeThumbColor: AppColors.auroraViolet,
                  onChanged: (_) => b.toggleGuardianShield(),
                ),
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.xl),

          // ── Roster ──────────────────────────────────────────────
          SectionHeader(title: 'On-call right now'),
          if (helpers.isEmpty)
            const EmptyState(
              icon: Icons.emergency_share_rounded,
              title: 'No helpers on call',
              message: 'Flip \"Available Now\" on to be the first responder.',
            )
          else
            ...helpers.asMap().entries.map((e) {
              final m = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sm),
                child: SoftCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      // Avatar with live on-call halo.
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GradientAvatar(
                              name: m.publicName,
                              photoUrl: m.photoUrl,
                              size: 46),
                          if (m.availableNow)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.surface, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(m.publicName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14)),
                                ),
                                if (m.isGuardian) ...[
                                  const SizedBox(width: 6),
                                  TintPill(
                                    label: 'Guardian',
                                    bg: AppColors.lavenderSoft,
                                    fg: AppColors.auroraViolet,
                                    icon: Icons.shield_rounded,
                                    small: true,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Rating + completed + response chips.
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 13,
                                    color: AppColors.auroraAmber),
                                const SizedBox(width: 3),
                                Text(m.ratingLabel,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                Text(
                                    '${m.completedCount} completed',
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600)),
                                if (m.availableNow) ...[
                                  const SizedBox(width: 8),
                                  TintPill(
                                    label: 'ON-CALL',
                                    bg: AppColors.successSoft,
                                    fg: AppColors.success,
                                    small: true,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: (120 + e.key * 60).ms)
                  .fadeIn(duration: 320.ms)
                  .slideX(begin: 0.06, end: 0);
            }),

          const SizedBox(height: AppDimens.xl),

          // ── Live SOS feed ───────────────────────────────────────
          SectionHeader(title: 'Live SOS requests'),
          if (feed.isEmpty)
            const EmptyState(
              icon: Icons.volunteer_activism_rounded,
              title: 'All quiet',
              message: 'No active emergencies in Madiwala right now.',
            )
          else
            ...feed.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.sm),
                  child: SoftCard(
                    color: AppColors.dangerSoft.withValues(alpha: 0.35),
                    borderColor: AppColors.dangerSoft,
                    onTap: () => context.push('/task/${t.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const TintPill(
                              label: 'SOS',
                              bg: AppColors.danger,
                              fg: Colors.white,
                              icon: Icons.emergency_rounded,
                              small: true,
                            ),
                            const SizedBox(width: 8),
                            if (t.genderPreference !=
                                GenderPreference.anyone)
                              GenderPrefBadge(
                                  pref: t.genderPreference, small: true),
                            const Spacer(),
                            Text(
                              '${t.applicantCount} responding',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(t.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(t.area,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _openSosSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppDimens.xl,
                right: AppDimens.xl,
                top: AppDimens.md,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.strokeStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Row(
                children: [
                  Icon(Icons.emergency_share_rounded, color: AppColors.danger),
                  SizedBox(width: 10),
                  Text('Broadcast SOS',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Only for genuine urgent needs. Misuse costs trust level.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.lg),
              TextField(
                controller: _titleCtrl,
                maxLength: 60,
                decoration: const InputDecoration(
                  hintText: 'What do you need? (e.g. \"Drive grandma to hospital\")',
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Key details helpers should know…',
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _areaCtrl,
                decoration: const InputDecoration(
                  hintText: 'Area (e.g. \"Madiwala · 5th Block\")',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              const Text('Who should respond?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppDimens.sm),
              Wrap(
                spacing: AppDimens.sm,
                children: GenderPreference.values.map((g) {
                  final on = _genderPref == g;
                  return GestureDetector(
                    onTap: () => setSheet(() => _genderPref = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        color: on ? AppColors.selectionActive : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimens.rPill),
                        border: Border.all(
                          color:
                              on ? AppColors.selectionActive : AppColors.stroke,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(g.icon,
                              size: 15,
                              color: on
                                  ? Colors.white
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(g.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: on
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimens.xl),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Alert nearby helpers',
                  icon: Icons.emergency_share_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _broadcast();
                  },
                  gradient: const LinearGradient(
                      colors: [Color(0xFFB91C4B), Color(0xFFE11D48)]),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}

/// Pulsing SOS trigger button.
class _SosButton extends StatelessWidget {
  const _SosButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.confirm();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.rPill + 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emergency_share_rounded,
                color: AppColors.danger, size: 20),
            SizedBox(width: 8),
            Text(
              'Broadcast SOS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.04, 1.04),
            duration: 1100.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
