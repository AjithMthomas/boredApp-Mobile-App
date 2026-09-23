// Phase 2 — Shop Gigs: small businesses hire temporary workers with
// clear payout terms (e.g. "2 sales reps · ₹1,000/day · 1 week").
// Phase 3 — Room Finder: urgent room/flat requirements where local
// scouts earn a finder's fee for leads.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

/// ── Phase 2 · Shop Gigs hub ──────────────────────────────────────
class GigsHubScreen extends ConsumerStatefulWidget {
  const GigsHubScreen({super.key, this.autoOpenCreate = false});

  /// When true (via `/gigs?create=1`) the create sheet opens on arrival.
  final bool autoOpenCreate;

  @override
  ConsumerState<GigsHubScreen> createState() => _GigsHubScreenState();
}

class _GigsHubScreenState extends ConsumerState<GigsHubScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCreateSheet(context, ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final gigs = b.gigFeed;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Shop Gigs'),
        leading: const UniformBackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context, ref),
        backgroundColor: AppColors.auroraAmber,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.storefront_rounded),
        label: const Text('Post a gig',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
        children: [
          // ── Poster hero ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auroraAmber.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/posters/poster_gigs.png',
                    width: double.infinity,
                    height: 186,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.lg),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xB392400E),
                            Color(0x3392400E),
                            Color(0x1492400E),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                  AppDimens.rPill),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.storefront_rounded,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'SHOP GIGS',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Hire a hand for\nyour shop',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Two reps for a week? Morning-rush help? Post with clear daily pay.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.lg),

          // ── How it works strip ──────────────────────────────────
          SoftCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: AppDimens.md),
            child: Row(
              children: [
                _StepChip(n: '1', label: 'Post with pay', tint: AppColors.butterSoft, fg: const Color(0xFF92400E)),
                _stepArrow(),
                _StepChip(n: '2', label: 'Neighbours apply', tint: AppColors.butterSoft, fg: const Color(0xFF92400E)),
                _stepArrow(),
                _StepChip(n: '3', label: 'Pick & confirm', tint: AppColors.butterSoft, fg: const Color(0xFF92400E)),
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.xl),
          SectionHeader(title: 'Open gigs nearby'),
          if (gigs.isEmpty)
            const EmptyState(
              icon: Icons.storefront_rounded,
              title: 'No gigs posted yet',
              message:
                  'Shop owners — post your first gig and reach the neighbourhood instantly.',
            )
          else
            ...gigs.asMap().entries.map((e) {
              final t = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: _GigCard(task: t),
              )
                  .animate(delay: (80 + e.key * 70).ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.08, end: 0);
            }),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _GigCreateSheet(),
    );
  }
}

class _GigCard extends StatelessWidget {
  const _GigCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => context.push('/task/${task.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.sunsetPop,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.creatorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(task.area,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TintPill(
                label: task.payoutNote,
                bg: AppColors.butterSoft,
                fg: const Color(0xFF92400E),
                icon: Icons.payments_rounded,
                small: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(task.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 16.5, letterSpacing: -0.2)),
          const SizedBox(height: 6),
          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              TintPill(
                label: '${task.capacity} worker${task.capacity > 1 ? 's' : ''} needed',
                bg: AppColors.infoSoft,
                fg: AppColors.info,
                icon: Icons.group_rounded,
                small: true,
              ),
              const SizedBox(width: 8),
              TintPill(
                label: 'Total ₹${task.rewardAmount.toStringAsFixed(0)}',
                bg: AppColors.successSoft,
                fg: AppColors.success,
                icon: Icons.currency_rupee_rounded,
                small: true,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.butterSoft.withValues(alpha: 0.6),
                  borderRadius:
                      BorderRadius.circular(AppDimens.rPill),
                ),
                child: Text(
                  '${task.applicantCount} applied',
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Numbered step chip for the "how it works" strip.
class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.n,
    required this.label,
    required this.tint,
    required this.fg,
  });

  final String n;
  final String label;
  final Color tint;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(n,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: fg)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _stepArrow() => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.chevron_right_rounded,
          size: 16, color: AppColors.textFaint),
    );

class _GigCreateSheet extends ConsumerStatefulWidget {
  const _GigCreateSheet();

  @override
  ConsumerState<_GigCreateSheet> createState() => _GigCreateSheetState();
}

class _GigCreateSheetState extends ConsumerState<_GigCreateSheet> {
  final _shopCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  double _dailyPay = 800;
  int _days = 7;
  int _workers = 2;

  @override
  void dispose() {
    _shopCtrl.dispose();
    _roleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _shopCtrl.text.trim().length >= 2 &&
      _roleCtrl.text.trim().length >= 3 &&
      _areaCtrl.text.trim().isNotEmpty;

  void _publish() {
    if (!_valid) return;
    final b = ref.read(storeProvider).backend;
    Haptics.confirm();
    final t = b.postGig(
      shopName: _shopCtrl.text.trim(),
      role: _roleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? 'Daily helper needed at the shop. Walk in or message.'
          : _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      dailyPay: _dailyPay,
      days: _days,
      workers: _workers,
    );
    Navigator.pop(context);
    context.push('/task/${t.id}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppDimens.xl,
        right: AppDimens.xl,
        top: AppDimens.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_rounded, color: AppColors.auroraAmber),
              SizedBox(width: 10),
              Text('Post a shop gig',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          TextField(
            controller: _shopCtrl,
            decoration: const InputDecoration(
                hintText: 'Shop name (e.g. \"Sri Ganesh Stores\")'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _roleCtrl,
            decoration: const InputDecoration(
                hintText: 'Role (e.g. \"Sales rep — evening shift\")'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'What should the worker do? Timings, tone, tips…'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _areaCtrl,
            decoration: const InputDecoration(
              hintText: 'Area (e.g. \"Madiwala · Market Rd\")',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          _stepper(
            label: 'Daily pay',
            value: '₹${_dailyPay.toStringAsFixed(0)}',
            onMinus: () => setState(
                () => _dailyPay = (_dailyPay - 100).clamp(100, 5000)),
            onPlus: () =>
                setState(() => _dailyPay = (_dailyPay + 100).clamp(100, 5000)),
          ),
          const SizedBox(height: AppDimens.sm),
          _stepper(
            label: 'Days needed',
            value: '$_days',
            onMinus: () => setState(() => _days = (_days - 1).clamp(1, 30)),
            onPlus: () => setState(() => _days = (_days + 1).clamp(1, 30)),
          ),
          const SizedBox(height: AppDimens.sm),
          _stepper(
            label: 'Workers',
            value: '$_workers',
            onMinus: () => setState(() => _workers = (_workers - 1).clamp(1, 10)),
            onPlus: () => setState(() => _workers = (_workers + 1).clamp(1, 10)),
          ),
          const SizedBox(height: AppDimens.lg),
          SoftCard(
            color: AppColors.butterSoft,
            borderColor: AppColors.butterSoft,
            child: Row(
              children: [
                const Icon(Icons.payments_rounded, color: Color(0xFF92400E)),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text(
                    'Total payout: ₹${(_dailyPay * _days * _workers).toStringAsFixed(0)} '
                    '(₹${_dailyPay.toStringAsFixed(0)}/day × $_days days × $_workers workers)',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Publish gig',
              icon: Icons.storefront_rounded,
              onPressed: _valid ? _publish : null,
              color: AppColors.auroraAmber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5))),
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Container(
          width: 74,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.rSm),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}

/// ── Phase 3 · Room Finder hub ────────────────────────────────────
class RoomFinderScreen extends ConsumerStatefulWidget {
  const RoomFinderScreen({super.key, this.autoOpenCreate = false});

  /// When true (via `/rooms?create=1`) the create sheet opens on arrival.
  final bool autoOpenCreate;

  @override
  ConsumerState<RoomFinderScreen> createState() => _RoomFinderScreenState();
}

class _RoomFinderScreenState extends ConsumerState<RoomFinderScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCreateSheet(context, ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final rooms = b.roomFeed;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Room Finder'),
        leading: const UniformBackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context, ref),
        backgroundColor: AppColors.auroraViolet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.night_shelter_rounded),
        label: const Text('Post requirement',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
        children: [
          // ── Poster hero ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auroraViolet.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/posters/poster_rooms.png',
                    width: double.infinity,
                    height: 186,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.lg),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xB34C1D95),
                            Color(0x334C1D95),
                            Color(0x144C1D95),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                  AppDimens.rPill),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.night_shelter_rounded,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'ROOM FINDER',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Hunting for a\nroom nearby?',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Post your requirement — local scouts hunt for you and earn a finder fee.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.lg),

          // ── Room type quick chips ───────────────────────────────
          SoftCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: AppDimens.md),
            child: Row(
              children: [
                for (final rt in const ['1RK', '1BHK', '2BHK', 'PG']) ...[
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.lavenderSoft,
                            borderRadius: BorderRadius.circular(
                                AppDimens.rPill),
                          ),
                          child: Text(
                            rt,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.auroraViolet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.xl),
          SectionHeader(title: 'Active requirements'),
          if (rooms.isEmpty)
            const EmptyState(
              icon: Icons.night_shelter_rounded,
              title: 'No requirements yet',
              message: 'Post what you need — 1RK, 1BHK, PG — and let scouts hunt.',
            )
          else
            ...rooms.asMap().entries.map((e) {
              final t = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: SoftCard(
                  onTap: () => context.push('/task/${t.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta row — first badge can flex & ellipsize, the
                      // finder-fee pill never wraps onto the title area.
                      Row(
                        children: [
                          Flexible(
                            child: TintPill(
                              label: t.payoutNote,
                              bg: AppColors.lavenderSoft,
                              fg: AppColors.auroraViolet,
                              icon: Icons.home_work_rounded,
                              small: true,
                            ),
                          ),
                          if (t.genderPreference != GenderPreference.anyone) ...[
                            const SizedBox(width: 6),
                            GenderPrefBadge(
                                pref: t.genderPreference, small: true),
                          ],
                          const Spacer(),
                          TintPill(
                            label:
                                '₹${t.rewardAmount.toStringAsFixed(0)} fee',
                            bg: AppColors.successSoft,
                            fg: AppColors.success,
                            icon: Icons.currency_rupee_rounded,
                            small: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text(t.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 6),
                      Text(
                        t.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.textFaint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(t.area,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text(
                            '${t.applicantCount} scout leads',
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textFaint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: (80 + e.key * 70).ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.08, end: 0);
            }),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _RoomCreateSheet(),
    );
  }
}

class _RoomCreateSheet extends ConsumerStatefulWidget {
  const _RoomCreateSheet();

  @override
  ConsumerState<_RoomCreateSheet> createState() => _RoomCreateSheetState();
}

class _RoomCreateSheetState extends ConsumerState<_RoomCreateSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  double _budget = 10000;
  String _roomType = '1RK';
  double _fee = 500;
  GenderPreference _genderPref = GenderPreference.anyone;

  static const _types = ['1RK', '1BHK', '2BHK', 'PG', 'Shared'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _titleCtrl.text.trim().length >= 4 && _areaCtrl.text.trim().isNotEmpty;

  void _publish() {
    if (!_valid) return;
    final b = ref.read(storeProvider).backend;
    Haptics.confirm();
    final t = b.postRoomRequest(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? 'Looking for a place urgently. Message me with any leads.'
          : _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      budget: _budget,
      roomType: _roomType,
      finderFee: _fee,
      genderPref: _genderPref,
    );
    Navigator.pop(context);
    context.push('/task/${t.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.xl,
        right: AppDimens.xl,
        top: AppDimens.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.xl,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Row(
            children: [
              Icon(Icons.night_shelter_rounded, color: AppColors.auroraViolet),
              SizedBox(width: 10),
              Text('Post room requirement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Area only — never share your exact address publicly.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.lg),
          TextField(
            controller: _titleCtrl,
            maxLength: 60,
            decoration: const InputDecoration(
                hintText: 'Headline (e.g. \"Urgent: 1RK near Madiwala market\")'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Must-haves: ventilation, ground floor, near bus stop…'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _areaCtrl,
            decoration: const InputDecoration(
              hintText: 'Preferred area (e.g. \"Madiwala / BTM border\")',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          const Text('Room type',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            children: _types.map((ty) {
              final on = _roomType == ty;
              return GestureDetector(
                onTap: () => setState(() => _roomType = ty),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color:
                        on ? AppColors.selectionActive : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                    border: Border.all(
                        color:
                            on ? AppColors.selectionActive : AppColors.stroke),
                  ),
                  child: Text(ty,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: on
                              ? Colors.white
                              : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.lg),
          _slider(
            label: 'Monthly budget',
            value: '₹${_budget.toStringAsFixed(0)}',
            min: 3000,
            max: 40000,
            divisions: 37,
            current: _budget,
            onChanged: (v) => setState(() => _budget = v),
          ),
          _slider(
            label: "Finder's fee",
            value: '₹${_fee.toStringAsFixed(0)}',
            min: 0,
            max: 2000,
            divisions: 20,
            current: _fee,
            onChanged: (v) => setState(() => _fee = v),
          ),
          const SizedBox(height: AppDimens.sm),
          const Text('Scout gender preference',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            children: GenderPreference.values.map((g) {
              final on = _genderPref == g;
              return GestureDetector(
                onTap: () => setState(() => _genderPref = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color:
                        on ? AppColors.selectionActive : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                    border: Border.all(
                        color:
                            on ? AppColors.selectionActive : AppColors.stroke),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(g.icon,
                          size: 15,
                          color: on
                              ? Colors.white
                              : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(g.label,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: on
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Post requirement',
              icon: Icons.travel_explore_rounded,
              onPressed: _valid ? _publish : null,
              color: AppColors.auroraViolet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required String value,
    required double min,
    required double max,
    required int divisions,
    required double current,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13.5)),
              Slider(
                value: current.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppColors.selectionActive,
                label: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        Container(
          width: 86,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.rSm),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 13)),
        ),
      ],
    );
  }
}
