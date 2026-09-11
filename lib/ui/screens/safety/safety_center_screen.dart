import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class SafetyCenterScreen extends ConsumerWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final me = b.currentUser;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: [
          // ── SOS block ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimens.xl),
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(AppDimens.rCard),
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency_rounded,
                    size: 44, color: AppColors.danger),
                const SizedBox(height: AppDimens.md),
                const Text(
                  'Emergency SOS',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger),
                ),
                const SizedBox(height: AppDimens.sm),
                const Text(
                  'Opens emergency call, alerts your trusted contact. Location shared only with your explicit tap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _showSosSheet(context);
                    },
                    icon: const Icon(Icons.emergency_rounded),
                    label: const Text('Open SOS',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // ── Trusted contact ──────────────────────────────────────
          const SectionHeader(title: 'Trusted contact'),
          SoftCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.violetDream,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.contact_phone_rounded,
                    color: Colors.white, size: 22),
              ),
              title: Text(
                me?.safetyContactName ?? 'Set a trusted contact',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: Text(
                me?.safetyContactPhone ?? 'Alerted on missed check-ins',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // ── Safety guidance ──────────────────────────────────────
          const SectionHeader(title: 'Safety guidance'),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tip(Icons.coffee_rounded, AppColors.aurora,
                    'Meet in public first',
                    'Cafes, markets, metro areas. Home visits only after trust is built.'),
                _tip(Icons.location_on_rounded, AppColors.aurora,
                    'Share live location sparingly',
                    'Opt-in, task-bound only — never automatic.'),
                _tip(Icons.password_rounded, AppColors.sunsetPop,
                    'Never share OTPs or PINs',
                    'No real task ever needs your bank credentials.'),
                _tip(Icons.currency_rupee_rounded, AppColors.sunsetPop,
                    'Settle money in person',
                    'UPI/cash directly. The platform holds no funds.'),
                _tip(Icons.directions_walk_rounded, AppColors.violetDream,
                    'You can always walk away',
                    'End any task instantly. Cancel if you feel unsafe — safety beats reliability score.'),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          // ── Moderation transparency ──────────────────────────────
          const SoftCard(
            color: AppColors.infoSoft,
            borderColor: AppColors.infoSoft,
            child: Row(
              children: [
                Icon(Icons.policy_rounded, color: AppColors.info),
                SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text(
                    'Reports are reviewed within 24 hours. Serious cases (threats, fraud, minors) are escalated immediately.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(IconData icon, Gradient gradient, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSosSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Emergency options',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppDimens.lg),
              ListTile(
                leading: const Icon(Icons.call_rounded,
                    color: AppColors.danger),
                title: const Text('Call 112 (India emergency)',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading:
                    const Icon(Icons.share_location_rounded),
                title: const Text('Share live location with Amma',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('One hour, opt-in',
                    style: TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.report_rounded),
                title: const Text('Report this task/member',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: AppDimens.sm),
              GhostButton(
                label: 'Close',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
