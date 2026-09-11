import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  bool _checkedIn = false;
  int _elapsedMin = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _elapsedMin += 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkIn() {
    setState(() => _checkedIn = true);
    Haptics.confirm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in recorded — stay safe out there 💚'),
      ),
    );
  }

  void _sos() {
    Haptics.danger();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trigger SOS?'),
        content: const Text(
          'This opens emergency call options, alerts your trusted contact, '
          'and notifies platform safety (if configured). Location is shared '
          'only with your explicit tap — never automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.danger,
                  content: Text(
                      'SOS flow (demo): would call emergency services + alert Amma.'),
                ),
              );
            },
            child: const Text('Yes, SOS now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final task = b.taskById(widget.taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Active session')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            // ── Status hero ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppDimens.xl),
              decoration: BoxDecoration(
                gradient: AppColors.aurora,
                borderRadius: BorderRadius.circular(AppDimens.rCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.rPill),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.play_circle_rounded,
                                size: 15, color: AppColors.success),
                            SizedBox(width: 5),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_elapsedMin + 12} min',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${task.area} · with ${task.creatorName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // ── Check-in timeline (if enabled) ─────────────────────
            if (task.hasCheckin) ...[
              SoftCard(
                color: _checkedIn
                    ? AppColors.successSoft
                    : AppColors.surface,
                borderColor:
                    _checkedIn ? AppColors.successSoft : AppColors.stroke,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _checkedIn
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          color: _checkedIn
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Text(
                            _checkedIn
                                ? 'Checked in — safe'
                                : 'Check in to confirm you\'re safe',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      _checkedIn
                          ? 'Missed check-ins escalate to your trusted contact after 30 minutes.'
                          : 'A quick tap — your trusted contact is not notified unless a check-in is missed.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (!_checkedIn) ...[
                      const SizedBox(height: AppDimens.md),
                      PrimaryButton(
                        label: "I'm safe",
                        icon: Icons.favorite_rounded,
                        color: AppColors.success,
                        onPressed: _checkIn,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),
            ],

            // ── Session actions ────────────────────────────────────
            const SectionHeader(title: 'Session actions'),
            SoftCard(
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_rounded),
                    title: const Text('Open task chat',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      final mine = b.myApplications();
                      if (mine.isNotEmpty) {
                        context.push('/chat/${mine.first.id}');
                      } else {
                        context.push('/messages');
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.place_rounded),
                    title: const Text('View meeting point',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(task.meetingPreference,
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Meeting point: ${task.meetingPreference} (map view in pilot build).')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.flag_rounded, color: AppColors.danger),
                    title: const Text('Report member',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.danger)),
                    onTap: () =>
                        context.push('/report/${task.id}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // ── Complete / cancel ──────────────────────────────────
            PrimaryButton(
              label: 'Mark completed',
              icon: Icons.task_alt_rounded,
              color: AppColors.success,
              onPressed: () {
                b.completeTask(task.id);
                context.push('/task/${task.id}/complete');
              },
            ),
            const SizedBox(height: AppDimens.md),
            GhostButton(
              label: 'Cancel task',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel this task?'),
                    content: const Text(
                      'Cancellation is recorded and affects reliability. '
                      'The other member is notified immediately.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Keep task'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.danger),
                        onPressed: () {
                          b.cancelTask(task.id);
                          Navigator.pop(ctx);
                          context.go('/home');
                        },
                        child: const Text('Cancel task'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.xl),

            // ── SOS (big, obvious, hard to accidentally trigger) ──
            SizedBox(
              width: double.infinity,
              height: 62,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dangerSoft,
                  foregroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.rCard),
                  ),
                ),
                onPressed: _sos,
                icon: const Icon(Icons.emergency_rounded, size: 26),
                label: const Text(
                  'SOS — Emergency',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            const Center(
              child: Text(
                'Platform safety ≠ emergency services. In immediate danger, call 112.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textFaint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
