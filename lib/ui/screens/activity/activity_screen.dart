import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/task_card.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final myPosts = b.myPosts();
    final myApps = b.myApplications();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: AppDimens.lg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
        children: [
          // ── Stats strip ─────────────────────────────────────────
          Row(
            children: [
              StatTile(value: '${myPosts.length}', label: 'My posts'),
              const SizedBox(width: AppDimens.sm),
              StatTile(
                  value: '${myApps.length}', label: 'Applications'),
              const SizedBox(width: AppDimens.sm),
              const StatTile(value: '7', label: 'Completed'),
            ],
          ),
          const SizedBox(height: AppDimens.xl),

          // ── Quick links ─────────────────────────────────────────
          SoftCard(
            onTap: () => context.push('/activity/my-posts'),
            padding: const EdgeInsets.all(AppDimens.md),
            child: const Row(
              children: [
                Icon(Icons.post_add_rounded, color: AppColors.info),
                SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text('My posts — manage applicants & lifecycle',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textFaint),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          SoftCard(
            onTap: () => context.push('/activity/my-applications'),
            padding: const EdgeInsets.all(AppDimens.md),
            child: const Row(
              children: [
                Icon(Icons.front_hand_rounded, color: AppColors.coral),
                SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text('My applications — sent interest & status',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textFaint),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),

          // ── Recent posts preview ────────────────────────────────
          SectionHeader(
            title: 'My recent posts',
            onViewAll: () => context.push('/activity/my-posts'),
          ),
          if (myPosts.isEmpty)
            const SoftCard(
              child: Text(
                'You haven\'t posted yet. Tap + to create your first task, company or offer.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          else
            ...myPosts.take(3).map(
                  (t) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimens.md),
                    child: TaskCard(
                      task: t,
                      onTap: () => context.push('/task/${t.id}'),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
