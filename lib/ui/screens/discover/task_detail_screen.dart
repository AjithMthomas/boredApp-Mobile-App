import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final task = b.taskById(widget.taskId);

    if (task == null) {
      return const Scaffold(
        body: Center(child: Text('Task not found')),
      );
    }

    final isMine = task.creatorId == (b.currentUser?.id ?? 'u_me');
    final applied = b.hasApplied(task.id);
    // Gender-restricted post: can the current member apply?
    final eligible = task.genderPreference.admits(b.currentUser?.gender);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 190,
            backgroundColor: AppColors.canvas,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  b.toggleSaved(task.id);
                  setState(() {});
                },
                icon: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: Icon(
                    b.isSaved(task.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                    color: b.isSaved(task.id)
                        ? AppColors.coral
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/report/${task.id}'),
                icon: const CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.flag_rounded, size: 19),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.aurora,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimens.rSheet),
                    bottomRight: Radius.circular(AppDimens.rSheet),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.xl, 90, AppDimens.xl, AppDimens.lg),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(task.type.icon, size: 26),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.type.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // ── Exchange chip row ─────────────────────────────
                  Wrap(
                    spacing: AppDimens.sm,
                    runSpacing: AppDimens.sm,
                    children: [
                      ExchangeChip(mode: task.exchange),
                      if (task.genderPreference != GenderPreference.anyone)
                        GenderPrefBadge(pref: task.genderPreference),
                      RiskBadge(risk: task.risk),
                      TintPill(
                        label: '${task.applicantCount} interested',
                        bg: AppColors.infoSoft,
                        fg: AppColors.info,
                        icon: Icons.groups_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // ── Meta grid (2×2 like the reference ticket) ────
                  SoftCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InfoTile(
                                icon: Icons.schedule_rounded,
                                label: 'When',
                                value: DateFormat('EEE, d MMM')
                                    .format(task.scheduledAt),
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: InfoTile(
                                icon: Icons.timelapse_rounded,
                                label: 'Duration',
                                value: task.durationLabel,
                                tint: AppColors.lavenderSoft,
                                iconColor: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),
                        Row(
                          children: [
                            Expanded(
                              child: InfoTile(
                                icon: Icons.place_rounded,
                                label: 'Area',
                                value: task.area,
                                tint: AppColors.peachSoft,
                                iconColor: AppColors.coral,
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: InfoTile(
                                icon: Icons.handshake_rounded,
                                label: 'Exchange',
                                value: task.rewardLabel,
                                tint: AppColors.butterSoft,
                                iconColor: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // ── Description ──────────────────────────────────
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          task.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // ── Safety strip ─────────────────────────────────
                  SoftCard(
                    color: task.risk == TaskRisk.high
                        ? AppColors.dangerSoft
                        : AppColors.mintFaint,
                    borderColor: task.risk == TaskRisk.high
                        ? AppColors.dangerSoft
                        : AppColors.mintSoft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.health_and_safety_rounded,
                          color: task.risk.color,
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Text(
                            task.risk == TaskRisk.high
                                ? 'High-risk activity: meet in public, tell your trusted contact, use check-ins.'
                                : task.risk == TaskRisk.medium
                                    ? 'Medium risk: meet in a public place. Check-ins available.'
                                    : 'Low risk. Safety tools still one tap away.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // ── Creator trust block ─────────────────────────
                  const SectionHeader(title: 'Posted by'),
                  SoftCard(
                    child: TrustRow(
                      photoUrl: task.creatorPhotoUrl,
                      name: task.creatorName,
                      verified: task.creatorVerified,
                      rating: task.creatorRating,
                      completed: task.creatorCompleted,
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // ── Meeting + capacity ──────────────────────────
                  SoftCard(
                    child: Column(
                      children: [
                        InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Meet at',
                          value: task.meetingPreference,
                          tint: AppColors.skySoft,
                          iconColor: AppColors.info,
                        ),
                        const SizedBox(height: AppDimens.md),
                        InfoTile(
                          icon: Icons.group_rounded,
                          label: 'Spots',
                          value: task.capacity > 1
                              ? '${task.capacity} people can join'
                              : '1 person needed',
                          tint: AppColors.mintSoft,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ─────────────────────────────────────────────
      bottomSheet: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.rSheet)),
          border: Border(top: BorderSide(color: AppColors.stroke)),
        ),
        padding: EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.md, AppDimens.lg,
            MediaQuery.of(context).padding.bottom + AppDimens.md),
        child: isMine
            ? Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: task.applicantCount > 0
                          ? 'View ${task.applicantCount} applicants'
                          : 'Manage post',
                      icon: Icons.people_alt_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Applicant list opens from Activity → My posts (demo).'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : applied || task.status != TaskStatus.published
                ? Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: applied
                              ? 'Application sent — open chat'
                              : _statusCta(task.status),
                          icon: Icons.chat_bubble_rounded,
                          onPressed: () {
                            final mine = b.myApplications().where(
                                (a) => a.taskId == task.id).toList();
                            if (mine.isNotEmpty) {
                              context.push('/chat/${mine.first.id}');
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: eligible
                              ? 'I\'m interested'
                              : task.genderPreference.longLabel,
                          icon: eligible
                              ? Icons.front_hand_rounded
                              : Icons.lock_rounded,
                          onPressed: eligible
                              ? () => _showApplySheet(context, ref, task)
                              : null,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _statusCta(TaskStatus s) => switch (s) {
        TaskStatus.confirmed => 'Confirmed — open chat',
        TaskStatus.active => 'Active — open session',
        TaskStatus.completed => 'Completed',
        _ => 'Closed',
      };

  void _showApplySheet(
      BuildContext context, WidgetRef ref, Task task) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        var sending = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
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
                  const Text(
                    'Express interest',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'A private chat opens with ${task.creatorName}. '
                    'They\'ll compare applicants and pick one — being interested '
                    'isn\'t being selected.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextField(
                    controller: ctrl,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      hintText: 'Short intro — why you? (visible to creator only)',
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  PrimaryButton(
                    label: sending ? 'Sending…' : 'Send interest',
                    icon: Icons.send_rounded,
                    onPressed: sending
                        ? null
                        : () async {
                            if (ctrl.text.trim().length < 10) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Write at least a short line (10+ chars).')),
                              );
                              return;
                            }
                            setSheet(() => sending = true);
                            final b = ref.read(storeProvider).backend;
                            if (!task.genderPreference
                                .admits(b.currentUser?.gender)) {
                              setSheet(() => sending = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'This post is ${task.genderPreference.longLabel.toLowerCase()}.')),
                              );
                              return;
                            }
                            final app = b.applyToTask(task.id, ctrl.text.trim());
                            await Future<void>.delayed(
                                const Duration(milliseconds: 600));
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (app != null) {
                              unawaited(context.push('/chat/${app.id}'));
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
