import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final apps = b.myApplications();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('My applications'),
        leading: const UniformBackButton(),
      ),
      body: apps.isEmpty
          ? EmptyState(
              icon: Icons.front_hand_rounded,
              title: 'No applications yet',
              message:
                  'Find a task that fits your free time and tap "I\'m interested".',
              actions: [
                PrimaryButton(
                  label: 'Browse tasks',
                  icon: Icons.explore_rounded,
                  expanded: false,
                  onPressed: () => context.push('/discover'),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, AppDimens.sm, AppDimens.lg, AppDimens.xl),
              itemCount: apps.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.md),
              itemBuilder: (context, i) {
                final a = apps[i];
                final task = b.taskById(a.taskId);
                return SoftCard(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task?.title ?? 'Task',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5),
                            ),
                          ),
                          _AppStatusChip(status: a.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Applied ${_ago(a.createdAt)} · ${task?.area ?? ''}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          Expanded(
                            child: GhostButton(
                              label: 'Open chat',
                              icon: Icons.chat_bubble_outline_rounded,
                              onPressed: () =>
                                  context.push('/chat/${a.id}'),
                            ),
                          ),
                          if (a.status == ApplicationStatus.chatting) ...[
                            const SizedBox(width: AppDimens.sm),
                            Expanded(
                              child: GhostButton(
                                label: 'Withdraw',
                                onPressed: () {
                                  b.withdrawApplication(a.id);
                                  // store listener triggers rebuild via ref.watch
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class _AppStatusChip extends StatelessWidget {
  const _AppStatusChip({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ApplicationStatus.chatting =>
        ('IN CHAT', AppColors.infoSoft, AppColors.info),
      ApplicationStatus.selected =>
        ('SELECTED', AppColors.successSoft, AppColors.success),
      ApplicationStatus.declined =>
        ('NOT SELECTED', AppColors.dangerSoft, AppColors.danger),
      ApplicationStatus.withdrawn =>
        ('WITHDRAWN', AppColors.surfaceMuted, AppColors.textSecondary),
      _ => ('INTERESTED', AppColors.mintSoft, AppColors.textPrimary),
    };
    return TintPill(label: label, bg: bg, fg: fg, small: true);
  }
}
