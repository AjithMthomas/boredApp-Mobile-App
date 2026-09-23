import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final items = b.notifications;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: const UniformBackButton(),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: b.unreadNotifications > 0
                ? b.markAllNotificationsRead
                : null,
            child: const Text('Mark all read',
                style: TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All caught up',
              message: 'Applications, selections and safety events land here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimens.lg),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.sm),
              itemBuilder: (context, i) {
                final n = items[i];
                return SoftCard(
                  padding: const EdgeInsets.all(AppDimens.md),
                  color: n.read
                      ? AppColors.surface
                      : AppColors.mintFaint,
                  borderColor: n.read
                      ? AppColors.stroke
                      : AppColors.mintSoft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: n.read
                              ? AppColors.surfaceMuted
                              : AppColors.mintSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          n.title.contains('Report')
                              ? Icons.flag_rounded
                              : Icons.notifications_rounded,
                          size: 17,
                          color: n.title.contains('Report')
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              n.body,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!n.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin:
                              const EdgeInsets.only(top: 6, left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
