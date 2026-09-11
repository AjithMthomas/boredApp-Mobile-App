import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/mock_backend.dart'
    show MockApplication, MockMessage, MockBackend;
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(MockBackend b, MockApplication app) {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    b.sendMessage(app.id, text);
    _inputCtrl.clear();
    setState(() {});
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectApplicant(MockBackend b, MockApplication app, Task task) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select this applicant?'),
        content: Text(
          'This confirms ${task.creatorName == 'You' ? 'them' : 'this member'} for '
          '"${task.title}". Other applicants will be declined and their '
          'rooms become read-only. You can cancel later, but cancellations '
          'affect reliability.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not yet'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            onPressed: () {
              b.selectApplicant(app.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applicant selected — task is confirmed.'),
                ),
              );
            },
            child: const Text('Confirm selection'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final meId = b.currentUser?.id ?? 'u_me';
    // (guarding against rebuild loops: markRoomRead only fires once per room open)

    // Application might not involve me (mock: any app is openable, but
    // a real backend enforces room membership strictly).
    MockApplication? app;
    for (final a in b.applications) {
      if (a.id == widget.applicationId) {
        app = a;
        break;
      }
    }
    if (app == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.meeting_room_rounded,
          title: 'Room unavailable',
          message: 'This conversation is closed or you are not a participant.',
        ),
      );
    }

    final task = b.taskById(app.taskId);
    final msgs = b.messagesFor(app.id);
    final iAmCreator = task?.creatorId == meId;
    final isApplicant = app.memberId == meId;

    // Mark read AFTER first frame; only when unread>0 so the
    // notify-rebuild settles instead of looping.
    final room = app;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && room.unreadForApplicant > 0) {
        b.markRoomRead(room.id);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            GradientAvatar(
              name: task?.creatorName ?? 'Member',
              photoUrl: task?.creatorPhotoUrl,
              size: 36,
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task?.title ?? 'Task chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    app.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: app.status == ApplicationStatus.selected
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Report or block',
              onPressed: () => _showSafetyActions(context, b, app!),
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Safety strip ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(
                AppDimens.lg, AppDimens.sm, AppDimens.lg, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mintFaint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded,
                    size: 16, color: AppColors.success),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Never share OTPs, UPI PINs or financial details. '
                    'Payment happens in person, never in chat.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ────────────────────────────────────────────
          Expanded(
            child: msgs.isEmpty
                ? const Center(
                    child: Text(
                      'Say hi — introduce yourself.',
                      style: TextStyle(
                          color: AppColors.textFaint,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(AppDimens.lg),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[i];
                      final mine = m.senderId == meId ||
                          (!isApplicant && !iAmCreator);
                      return _bubble(m, mine);
                    },
                  ),
          ),

          // ── Creator: select applicant CTA ───────────────────────
          if (iAmCreator && app.status == ApplicationStatus.chatting) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg),
              child: PrimaryButton(
                label: 'Select this applicant',
                icon: Icons.check_circle_rounded,
                onPressed: () =>
                    _selectApplicant(b, app!, task!),
              ),
            ),
            const SizedBox(height: AppDimens.sm),
          ],

          // ── Input row ───────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, AppDimens.sm, AppDimens.lg, AppDimens.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(b, app!),
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  GestureDetector(
                    onTap: () => _send(b, app!),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.aurora,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.auroraSky.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(MockMessage m, bool mine) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: mine
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.auroraSky, AppColors.auroraViolet],
                )
              : null,
          color: mine ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
          border: mine
              ? null
              : Border.all(color: AppColors.stroke),
          boxShadow: mine
              ? [
                  BoxShadow(
                    color: AppColors.auroraViolet.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m.body,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: mine
                    ? AppColors.textOnInk
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              DateFormat('h:mm a').format(m.createdAt),
              style: TextStyle(
                fontSize: 9.5,
                color: mine
                    ? Colors.white70
                    : AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSafetyActions(
      BuildContext context, MockBackend b, MockApplication app) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_rounded, color: AppColors.danger),
              title: const Text('Report member',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text(
                  'Goes to moderation with chat context',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                b.reportTask(app.taskId, 'Member conduct', 'From chat room');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Report filed — safety team reviews within 24h.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: AppColors.textPrimary),
              title: const Text('Block member',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text(
                  'No future tasks or chats between you two',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member blocked.')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
