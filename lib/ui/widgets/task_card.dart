import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/haptics.dart';
import 'common.dart';

/// Feed card — redesigned with gradient type tile, cleaner hierarchy
/// and optional staggered entrance animation.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.compact = false,
    this.saved = false,
    this.onTap,
    this.onSave,
    this.footer,
    this.index = 0,
    this.animateIn = false,
    this.tint,
  });

  final Task task;
  final bool compact;
  final bool saved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final Widget? footer;
  final int index;
  final bool animateIn;

  /// Optional pastel gradient background (compact mode only) — used to
  /// tint "Upcoming nearby" carousel cards from AppColors.cardTints.
  final Gradient? tint;

  @override
  Widget build(BuildContext context) {
    final card = compact ? _compact(context) : _full(context);
    if (!animateIn) return card;
    return card
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Full card ────────────────────────────────────────────────────
  Widget _full(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: prominent title + optional save action.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
              ),
              if (onSave != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Haptics.select();
                    onSave!();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(saved),
                      color: saved ? AppColors.auroraCoral : AppColors.textFaint,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [
              ExchangeChip(mode: task.exchange, small: true),
              TintPill(
                label: task.durationLabel,
                bg: AppColors.surfaceMuted,
                fg: AppColors.textSecondary,
                icon: Icons.schedule_rounded,
                small: true,
              ),
              TintPill(
                label: task.distanceLabel,
                bg: AppColors.surfaceMuted,
                fg: AppColors.textSecondary,
                icon: Icons.near_me_rounded,
                small: true,
              ),
              if (task.genderPreference != GenderPreference.anyone)
                GenderPrefBadge(pref: task.genderPreference, small: true),
              RiskBadge(risk: task.risk, small: true),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TrustRow(
            name: task.creatorName,
            photoUrl: task.creatorPhotoUrl,
            verified: task.creatorVerified,
            rating: task.creatorRating,
            completed: task.creatorCompleted,
            trailing: Text(
              _whenLabel(task.scheduledAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppDimens.md),
            footer!,
          ],
        ],
      ),
    );
  }

  // ── Compact horizontal card ──────────────────────────────────────
  Widget _compact(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.md),
      gradient: tint,
      child: SizedBox(
        width: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('d MMM').format(task.scheduledAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              task.area,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                ExchangeChip(mode: task.exchange, small: true),
                const Spacer(),
                Text(
                  _whenLabel(task.scheduledAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _whenLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inDays == 0) {
      return 'Today ${DateFormat('h:mm a').format(dt)}';
    }
    if (diff.inDays == 1) return 'Tomorrow';
    return DateFormat('EEE, d MMM').format(dt);
  }
}

extension _TaskDist on Task {
  String get distanceLabel => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';
}
