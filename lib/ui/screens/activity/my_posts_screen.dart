import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final posts = b.myPosts();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('My posts'),
        leading: const UniformBackButton(),
      ),
      body: posts.isEmpty
          ? EmptyState(
              icon: Icons.mark_email_unread_rounded,
              title: 'No posts yet',
              message:
                  'Create a task, company or offer — it takes under a minute.',
              actions: [
                PrimaryButton(
                  label: 'Create now',
                  icon: Icons.add_rounded,
                  expanded: false,
                  onPressed: () => context.push('/create'),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppDimens.lg,
                  AppDimens.sm, AppDimens.lg, AppDimens.xl),
              itemCount: posts.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.md),
              itemBuilder: (context, i) {
                final t = posts[i];
                final apps = b.applicationsForTask(t.id);
                return SoftCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5),
                            ),
                          ),
                          _StatusChip(status: t.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${t.area} · ${t.rewardLabel} · ${t.applicantCount} interested',
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          Expanded(
                            child: GhostButton(
                              label: apps.isEmpty
                                  ? 'No applicants yet'
                                  : '${apps.length} applicant${apps.length > 1 ? 's' : ''}',
                              onPressed: apps.isEmpty
                                  ? null
                                  : () => context.push('/chat/${apps.first.id}'),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: PrimaryButton(
                              label: switch (t.status) {
                                TaskStatus.published => 'Start',
                                TaskStatus.confirmed => 'Start session',
                                TaskStatus.active => 'Complete',
                                _ => 'View',
                              },
                              expanded: false,
                              onPressed: () {
                                switch (t.status) {
                                  case TaskStatus.published:
                                  case TaskStatus.confirmed:
                                    b.startTask(t.id);
                                    context.push('/task/${t.id}/session');
                                  case TaskStatus.active:
                                    b.completeTask(t.id);
                                    context.push('/task/${t.id}/complete');
                                  default:
                                    context.push('/task/${t.id}');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      TaskStatus.published => ('LIVE', AppColors.infoSoft, AppColors.info),
      TaskStatus.confirmed => ('CONFIRMED', AppColors.mintSoft, AppColors.success),
      TaskStatus.active => ('ACTIVE', AppColors.successSoft, AppColors.success),
      TaskStatus.completed => ('DONE', AppColors.surfaceMuted, AppColors.textSecondary),
      TaskStatus.cancelled => ('CANCELLED', AppColors.dangerSoft, AppColors.danger),
      _ => (status.name.toUpperCase(), AppColors.surfaceMuted, AppColors.textSecondary),
    };
    return TintPill(label: label, bg: bg, fg: fg, small: true);
  }
}
