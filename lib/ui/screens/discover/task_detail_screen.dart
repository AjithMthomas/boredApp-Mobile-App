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
import '../../widgets/task_card.dart';

/// Post detail — the "ticket" design: full-bleed aurora hero, floating
/// content sheet, colored meta grid, trust block and a related strip.
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
        backgroundColor: AppColors.canvas,
        body: Center(child: Text('Post not found')),
      );
    }

    final isMine = task.creatorId == (b.currentUser?.id ?? 'u_me');
    final applied = b.hasApplied(task.id);
    // Gender-restricted post: can the current member apply?
    final eligible = task.genderPreference.admits(b.currentUser?.gender);

    // Related: same category first, then same post type, exclude self.
    final related = b.tasks
        .where((t) =>
            t.id != task.id &&
            t.status == TaskStatus.published &&
            (t.category == task.category || t.type == task.type))
        .take(4)
        .toList();

    const bgAsset = 'assets/detailed_page_bg.jpg';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      // ── Sticky gradient CTA ──────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.rSheet),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppDimens.lg,
          AppDimens.md,
          AppDimens.lg,
          MediaQuery.of(context).padding.bottom + AppDimens.md,
        ),
        child: _Cta(
          isMine: isMine,
          applied: applied,
          eligible: eligible,
          task: task,
          applicantCount: task.applicantCount,
          onOpenChat: () {
            final mine =
                b.myApplications().where((a) => a.taskId == task.id).toList();
            if (mine.isNotEmpty) context.push('/chat/${mine.first.id}');
          },
          onApply: () => _showApplySheet(context, ref, task),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero ───────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.canvas,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppDimens.md),
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop(),
              ),
            ),
            actions: [
              _CircleIconButton(
                icon: b.isSaved(task.id)
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                iconColor: b.isSaved(task.id)
                    ? AppColors.coral
                    : AppColors.textPrimary,
                onTap: () {
                  b.toggleSaved(task.id);
                  setState(() {});
                },
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(right: AppDimens.md),
                child: _CircleIconButton(
                  icon: Icons.flag_rounded,
                  onTap: () => context.push('/report/${task.id}'),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimens.rSheet),
                    bottomRight: Radius.circular(AppDimens.rSheet),
                  ),
                  image: DecorationImage(
                    image: AssetImage(bgAsset),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.lg, 65, AppDimens.lg, AppDimens.sm),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A101323),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: AppColors.aurora,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.type.label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content sheet, overlapping the hero curve ────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.lg, AppDimens.lg, AppDimens.lg, AppDimens.sm),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Status chips
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

                  // ── Meta grid (2×2, reference ticket style) ──────
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
                                iconColor: AppColors.lavender,
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

                  // ── About ─────────────────────────────────────────
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

                  // ── Safety strip ──────────────────────────────────
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
                            switch (task.risk) {
                              TaskRisk.high =>
                                'High-risk activity: meet in public, tell your trusted contact, use check-ins.',
                              TaskRisk.medium =>
                                'Medium risk: meet in a public place. Check-ins available.',
                              TaskRisk.low =>
                                'Low risk. Safety tools still one tap away.',
                            },
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

                  // ── Creator trust block ───────────────────────────
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

                  // ── Meeting + capacity ────────────────────────────
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

                  // ── Related posts ─────────────────────────────────
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.xl),
                    SectionHeader(
                      title: 'More like this',
                      onViewAll: () => context.go('/discover'),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: related.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppDimens.md),
                        itemBuilder: (context, i) {
                          final t = related[i];
                          return SizedBox(
                            width: 200,
                            child: TaskCard(
                              task: t,
                              compact: true,
                              tint: AppColors
                                  .cardTints[(i + 1) % AppColors.cardTints.length],
                              onTap: () => context.push('/task/${t.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimens.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Apply bottom sheet ───────────────────────────────────────────
  void _showApplySheet(
      BuildContext context, WidgetRef ref, Task task) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        var sending = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.rSheet),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  AppDimens.xl,
                  AppDimens.lg,
                  AppDimens.xl,
                  MediaQuery.of(ctx).viewInsets.bottom == 0
                      ? MediaQuery.of(ctx).padding.bottom + AppDimens.xl
                      : AppDimens.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.strokeStrong,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    const Text(
                      'Express interest',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      'A private chat opens with ${task.creatorName}. '
                      'They\'ll compare applicants and pick one — being '
                      'interested isn\'t being selected.',
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
                        hintText:
                            'Short intro — why you? (visible to creator only)',
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
                              final app =
                                  b.applyToTask(task.id, ctrl.text.trim());
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
              ),
            );
          },
        );
      },
    );
  }
}

// ── Floating circular action buttons (hero corners) ────────────────
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.ink),
          ),
        ),
      ),
    );
  }
}

// ── Sticky CTA — single gradient pill ──────────────────────────────
class _Cta extends StatelessWidget {
  const _Cta({
    required this.isMine,
    required this.applied,
    required this.eligible,
    required this.task,
    required this.applicantCount,
    required this.onOpenChat,
    required this.onApply,
  });

  final bool isMine;
  final bool applied;
  final bool eligible;
  final Task task;
  final int applicantCount;
  final VoidCallback onOpenChat;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final (label, icon, onPressed) = switch ((
      isMine,
      applied,
      task.status,
    )) {
      (true, _, _) => (
          applicantCount > 0
              ? 'View $applicantCount applicants'
              : 'Manage post',
          Icons.people_alt_rounded,
          () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Applicant list opens from Activity → My posts (demo).'),
                ),
              ),
        ),
      (_, true, _) => (
          'Application sent — open chat',
          Icons.chat_bubble_rounded,
          onOpenChat,
        ),
      (_, _, TaskStatus.confirmed) => (
          'Confirmed — open chat',
          Icons.chat_bubble_rounded,
          onOpenChat,
        ),
      (_, _, TaskStatus.active) => (
          'Active — open session',
          Icons.play_circle_fill_rounded,
          onOpenChat,
        ),
      (_, _, TaskStatus.completed) => (
          'Completed',
          Icons.check_circle_rounded,
          null,
        ),
      (_, _, _) => (
          eligible ? "I'm interested" : task.genderPreference.longLabel,
          eligible ? Icons.front_hand_rounded : Icons.lock_rounded,
          eligible ? onApply : null,
        ),
    };

    return PrimaryButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
