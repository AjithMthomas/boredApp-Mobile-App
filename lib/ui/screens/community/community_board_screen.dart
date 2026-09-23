// Phase 9 — Community wishlist & feature requests board.
// Submit ideas, upvote neighbours' ideas; top ideas get scheduled as
// official neighbourhood events.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_avatar.dart';

class CommunityBoardScreen extends ConsumerStatefulWidget {
  const CommunityBoardScreen({super.key});

  @override
  ConsumerState<CommunityBoardScreen> createState() =>
      _CommunityBoardScreenState();
}

class _CommunityBoardScreenState extends ConsumerState<CommunityBoardScreen> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  String _tag = 'Meetup';

  static const _tags = ['Meetup', 'Walk', 'Sports', 'Feature', 'Help'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().length < 4) return;
    final b = ref.read(storeProvider).backend;
    Haptics.confirm();
    b.submitIdea(_titleCtrl.text.trim(), _detailsCtrl.text.trim(), _tag);
    _titleCtrl.clear();
    _detailsCtrl.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        content: Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: AppColors.auroraAmber),
            SizedBox(width: 12),
            Expanded(
              child: Text('Idea posted +15 credits — rally the upvotes!'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final ideas = b.boardIdeas;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Community Board'),
        leading: const UniformBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              gradient: AppColors.violetDream,
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auroraViolet.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.forum_rounded, color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'What should nuvra do next?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Suggest meetups, events, features. The neighbourhood upvotes — '
                  'top ideas get scheduled as official events.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.lg),

          // ── Submit composer ──────────────────────────────────
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleCtrl,
                  maxLength: 70,
                  decoration: const InputDecoration(
                      hintText: 'Your idea in one line…'),
                ),
                const SizedBox(height: AppDimens.sm),
                TextField(
                  controller: _detailsCtrl,
                  maxLines: 2,
                  maxLength: 240,
                  decoration: const InputDecoration(
                      hintText: 'Details — when, where, why it matters…'),
                ),
                const SizedBox(height: AppDimens.sm),
                Wrap(
                  spacing: AppDimens.sm,
                  children: _tags.map((t) {
                    final on = _tag == t;
                    return GestureDetector(
                      onTap: () => setState(() => _tag = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: on
                              ? AppColors.selectionActive
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.rPill),
                          border: Border.all(
                              color: on
                                  ? AppColors.selectionActive
                                  : AppColors.stroke),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: on
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimens.lg),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Post idea (+15 credits)',
                    icon: Icons.lightbulb_rounded,
                    onPressed: _submit,
                    color: AppColors.auroraViolet,
                  ),
                ),
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.xl),
          SectionHeader(title: 'Top ideas'),
          ...ideas.asMap().entries.map((e) {
            final idea = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: SoftCard(
                color: idea.scheduled
                    ? AppColors.successSoft.withValues(alpha: 0.30)
                    : AppColors.surface,
                borderColor: idea.scheduled ? AppColors.successSoft : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upvote column.
                    GestureDetector(
                      onTap: () {
                        Haptics.select();
                        b.toggleIdeaVote(idea.id);
                      },
                      child: Container(
                        width: 52,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: idea.votedByMe
                              ? AppColors.selectionActive
                              : AppColors.surfaceMuted,
                          borderRadius:
                              BorderRadius.circular(AppDimens.rSm + 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 18,
                              color: idea.votedByMe
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${idea.upvotes}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: idea.votedByMe
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TintPill(
                                label: idea.tag,
                                bg: AppColors.infoSoft,
                                fg: AppColors.info,
                                small: true,
                              ),
                              if (idea.scheduled) ...[
                                const SizedBox(width: 6),
                                const TintPill(
                                  label: 'Scheduled ✓',
                                  bg: AppColors.success,
                                  fg: Colors.white,
                                  small: true,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(idea.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(idea.details,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.45)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GradientAvatar(
                                  name: idea.authorName,
                                  photoUrl: idea.authorPhotoUrl,
                                  size: 20),
                              const SizedBox(width: 6),
                              Text(idea.authorName,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: (120 + e.key * 60).ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.06, end: 0),
            );
          }),
        ],
      ),
    );
  }
}
