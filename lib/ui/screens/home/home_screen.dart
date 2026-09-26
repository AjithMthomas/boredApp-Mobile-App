import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/ad_carousel.dart';
import '../../widgets/common.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final b = store.backend;
    final me = b.currentUser;
    final feed = b.feed;

    // An "active" task (confirmed/active) if any, for the status strip.
    final activeTasks = b.tasks
        .where((t) =>
            t.status == TaskStatus.active || t.status == TaskStatus.confirmed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // ── Ambient aurora wash at the top ─────────────────────────
          Positioned(
            top: -160,
            left: -60,
            right: -60,
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraMint.withValues(alpha: 0.20),
                    AppColors.auroraViolet.withValues(alpha: 0.10),
                    AppColors.canvas.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                // ── Header: Brand logo + points pill + avatar + actions ──────────
                Padding(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logo_icon.png',
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: AppDimens.sm),
                      GestureDetector(
                        onTap: () => context.push('/perks'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimens.rPill),
                            border: Border.all(color: AppColors.stroke),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F101323),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.diamond_rounded,
                                  size: 15, color: AppColors.auroraSky),
                              const SizedBox(width: 4),
                              Text(
                                '${me?.karma ?? 0} cr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/radar'),
                        tooltip: 'Bored Radar — who is free nearby',
                        icon: const Icon(Icons.radar_rounded),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: Badge(
                          isLabelVisible: b.unreadNotifications > 0,
                          backgroundColor: AppColors.auroraCoral,
                          child:
                              const Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: GradientAvatar(
                          name: me?.publicName ?? 'You',
                          photoUrl: me?.photoUrl,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // ── Greeting ─────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                          height: 1.15,
                        ),
                      )
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        'Madiwala · ${feed.length} things happening nearby',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                          .animate(delay: 160.ms)
                          .fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.lg),

                // ── "I'm Free Now" aurora hero ───────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: AuroraCard(
                    gradient: AppColors.deepSpace,
                    glowColor: AppColors.auroraViolet,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.auroraMint
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(
                                          AppDimens.rPill),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.circle,
                                            size: 6,
                                            color: AppColors.auroraMint),
                                        SizedBox(width: 5),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                            color: AppColors.auroraMint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.sm),
                              const Text(
                                'I\'m Free Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Broadcast 1–3 free hours to nearby members. Turn idle time into connection.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        _glowGo(context),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimens.lg),

                // ── Hub shortcuts (new verticals) ────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: Row(
                    children: [
                      _hubTile(context, PostKind.emergency,
                          live: true),
                      const SizedBox(width: AppDimens.sm),
                      _hubTile(context, PostKind.gig),
                      const SizedBox(width: AppDimens.sm),
                      _hubTile(context, PostKind.room),
                      const SizedBox(width: AppDimens.sm),
                      _hubTile(context, PostKind.team),
                    ],
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimens.lg),

                // ── Sponsored banners (business advertisements) ──────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.lg),
                  child: Row(
                    children: [
                      const Text(
                        'Sponsored',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.textFaint,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.rPill),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: const Text(
                          'Ad',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: AppColors.textFaint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: AdCarousel(height: 150),
                ),
                const SizedBox(height: AppDimens.lg),

                // ── Active task strip (if any confirmed/active) ──────
                if (activeTasks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.lg),
                    child: SectionHeader(
                        title: 'Your active task',
                        onViewAll: () => context.push('/activity')),
                  ),
                  SizedBox(
                    height: 148,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                          AppDimens.lg, 6, AppDimens.lg, AppDimens.md),
                      itemCount: activeTasks.length,
                      itemBuilder: (context, i) {
                        final t = activeTasks[i];
                        return Padding(
                          padding: EdgeInsets.only(
                              right: i == activeTasks.length - 1
                                  ? 0
                                  : AppDimens.md),
                          child: TaskCard(
                            task: t,
                            compact: true,
                            onTap: () => context.push(
                                t.status == TaskStatus.active
                                    ? '/task/${t.id}/session'
                                    : '/task/${t.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                ],

                // ── Upcoming nearby ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.lg),
                  child: SectionHeader(
                    title: 'Upcoming nearby',
                    onViewAll: () => context.push('/discover'),
                  ),
                ),
                SizedBox(
                  height: 168,
                  child: feed.isEmpty
                      ? const Center(
                          child: Text('Nothing scheduled yet.',
                              style: TextStyle(color: AppColors.textFaint)),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(
                              AppDimens.lg, 6, AppDimens.lg, AppDimens.md),
                          itemCount: feed.take(6).length,
                          itemBuilder: (context, i) {
                            final t = feed[i];
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: i == feed.length - 1
                                      ? 0
                                      : AppDimens.md),
                              child: TaskCard(
                                task: t,
                                compact: true,
                                animateIn: true,
                                index: i,
                                tint: AppColors.cardTints[i %
                                    AppColors.cardTints.length],
                                onTap: () => context.push('/task/${t.id}'),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppDimens.xl),

                // ── Recommendations (vertical list) ──────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.lg),
                  child: SectionHeader(
                    title: 'Recommended for you',
                    onViewAll: () => context.push('/discover'),
                  ),
                ),
                ...feed.skip(3).take(4).toList().asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0,
                            AppDimens.lg, AppDimens.md),
                        child: TaskCard(
                          task: e.value,
                          index: e.key,
                          animateIn: true,
                          saved: b.isSaved(e.value.id),
                          onSave: () => b.toggleSaved(e.value.id),
                          onTap: () => context.push('/task/${e.value.id}'),
                        ),
                      ),
                    ),
                if (feed.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppDimens.xxl),
                    child: EmptyState(
                      icon: Icons.local_florist_rounded,
                      title: 'Your feed is quiet',
                      message:
                          'Widen the radius, or be the first to post something in Madiwala.',
                    ),
                  ),

                // ── Safety shortcut ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.lg),
                  child: SoftCard(
                    color: AppColors.lavenderFaint,
                    borderColor: AppColors.lavenderSoft,
                    onTap: () => context.push('/safety'),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.violetDream,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.health_and_safety_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: AppDimens.md),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safety Center',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14),
                              ),
                              Text(
                                'SOS · check-ins · trusted contact',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textFaint),
                      ],
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 450.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowGo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.confirm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Free-Now beacon: coming in the pilot build — sets your status to "available".'),
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.aurora,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          boxShadow: [
            BoxShadow(
              color: AppColors.auroraMint.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          'Go',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textOnAurora,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Soft background colors per hub.
  static const _hubTileBgColors = {
    PostKind.emergency: Color(0xFFFFF0F3),
    PostKind.gig: Color(0xFFFFF8E7),
    PostKind.room: Color(0xFFF3E8FF),
    PostKind.team: Color(0xFFE6F4EA),
  };

  /// Gradient pair per hub for the tinted icon squircle.
  static const _hubGradients = {
    PostKind.emergency: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF4D6D), Color(0xFFE61C40)],
    ),
    PostKind.gig: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
    ),
    PostKind.room: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    PostKind.team: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
  };

  static const _hubIcons = {
    PostKind.emergency: Icons.notifications_active_rounded,
    PostKind.gig: Icons.storefront_rounded,
    PostKind.room: Icons.home_rounded,
    PostKind.team: Icons.groups_rounded,
  };

  static const _hubLabels = {
    PostKind.emergency: 'Emergency',
    PostKind.gig: 'Shop',
    PostKind.room: 'Room',
    PostKind.team: 'Make',
  };

  Widget _hubTile(BuildContext context, PostKind kind, {bool live = false}) {
    final route = switch (kind) {
      PostKind.emergency => '/emergency',
      PostKind.gig => '/gigs',
      PostKind.room => '/rooms',
      PostKind.team => '/team',
      _ => '/discover',
    };
    final bgColor = _hubTileBgColors[kind] ?? Colors.white;
    final iconData = _hubIcons[kind] ?? kind.icon;
    final label = _hubLabels[kind] ?? kind.hubTitle.split(' ').first;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient icon squircle with inner highlight + live dot.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _hubGradients[kind],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kind.colors.strong.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(iconData, size: 22, color: Colors.white),
                  ),
                  if (live)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
