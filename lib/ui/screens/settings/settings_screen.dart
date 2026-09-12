import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifs = true;
  bool _quietHours = false;
  bool _showAreaPublic = true;

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: [
          const SectionHeader(title: 'Privacy'),
          SoftCard(
            padding: const EdgeInsets.all(AppDimens.sm),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show my area on posts',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text(
                      'Approximate area only — never exact address',
                      style: TextStyle(fontSize: 12)),
                  value: _showAreaPublic,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => setState(() => _showAreaPublic = v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.block_rounded),
                  title: const Text('Blocked members',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('None',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          const SectionHeader(title: 'Notifications'),
          SoftCard(
            padding: const EdgeInsets.all(AppDimens.sm),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push notifications',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  value: _pushNotifs,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => setState(() => _pushNotifs = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Quiet hours (10 PM – 7 AM)',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  value: _quietHours,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => setState(() => _quietHours = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          const SectionHeader(title: 'Account'),
          SoftCard(
            padding: const EdgeInsets.all(AppDimens.sm),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Download my data',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('DPDP right to access',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Data export will be emailed when the API lands.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever_rounded,
                          color: AppColors.danger),
                  title: const Text('Delete account',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger)),
                  subtitle: const Text(
                      'Anonymized after moderation retention window',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete account?'),
                        content: const Text(
                          'Your posts and chats are anonymized; safety records '
                          'are retained per policy. This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Keep account'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.danger),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Account deletion runs with the real backend.')),
                              );
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          GhostButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            onPressed: () {
              b.signOut();
              context.go('/auth/email');
            },
          ),
          const SizedBox(height: AppDimens.xl),
          const Center(
            child: Text(
              'nuvra v0.1.0 · Madiwala pilot\nMinimum data · maximum trust',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textFaint,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
