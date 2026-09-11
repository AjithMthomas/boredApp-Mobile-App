import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final apps = b.applications
        .where((a) => a.status != ApplicationStatus.withdrawn)
        .toList()
      ..sort((a, b2) => b2.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Messages')),
      body: apps.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              message:
                  'When you express interest in a task — or someone expresses interest in yours — private rooms appear here.',
              actions: [
                PrimaryButton(
                  label: 'Discover tasks',
                  icon: Icons.explore_rounded,
                  expanded: false,
                  onPressed: () => context.go('/discover'),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
              itemCount: apps.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.sm),
              itemBuilder: (context, i) {
                final a = apps[i];
                final task = b.taskById(a.taskId);
                final unread = a.unreadForApplicant;
                final lastMsg = b.messagesFor(a.id).isNotEmpty
                    ? b.messagesFor(a.id).last
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.sm),
                  child: SoftCard(
                    onTap: () => context.push('/chat/${a.id}'),
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Row(
                      children: [
                        GradientAvatar(
                          name: task?.creatorName ?? 'Member',
                          photoUrl: task?.creatorPhotoUrl,
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task?.title ?? 'Task',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (unread > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.coral,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$unread',
                                      style: const TextStyle(
                                        color: AppColors.textOnInk,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              lastMsg?.body ?? a.introMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: switch (a.status) {
                                  ApplicationStatus.selected =>
                                    AppColors.success,
                                  ApplicationStatus.declined =>
                                    AppColors.danger,
                                  _ => AppColors.textSecondary,
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: (45 * i).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 350.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
    );
  }
}
