// Phase 4 — Make Team: gather people for needs/events (head-count
// reservation) and community trips with a UPI split calculator.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class TeamHubScreen extends ConsumerStatefulWidget {
  const TeamHubScreen({super.key, this.autoOpenCreate = false});

  /// When true (via `/team?create=1`) the create sheet opens on arrival.
  final bool autoOpenCreate;

  @override
  ConsumerState<TeamHubScreen> createState() => _TeamHubScreenState();
}

class _TeamHubScreenState extends ConsumerState<TeamHubScreen> {
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
    final posts = b.teamFeed;
    final trips = posts.where((t) => t.kind == PostKind.trip).toList();
    final teams = posts.where((t) => t.kind == PostKind.team).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Make Team'),
        leading: const UniformBackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context, ref),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.diversity_3_rounded),
        label: const Text('Gather people',
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
                  color: AppColors.success.withValues(alpha: 0.28),
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
                    'assets/posters/poster_team.png',
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
                            Color(0xB3065F46),
                            Color(0x33065F46),
                            Color(0x14065F46),
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
                                Icon(Icons.diversity_3_rounded,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'MAKE TEAM · TRIPS',
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
                            'Gather your\ncrowd',
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
                            '10 for a reel shoot, 50 for a cafe launch, a Nandi Hills trip — heads reserve live.',
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

          const SizedBox(height: AppDimens.xl),
          if (trips.isNotEmpty) ...[
            SectionHeader(title: 'Community trips'),
            ...trips.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: _TeamCard(task: e.value),
                )
                    .animate(delay: (60 + e.key * 70).ms)
                    .fadeIn(duration: 320.ms)),
            const SizedBox(height: AppDimens.md),
          ],
          SectionHeader(title: 'Team gatherings'),
          if (teams.isEmpty)
            const EmptyState(
              icon: Icons.diversity_3_rounded,
              title: 'No teams forming yet',
              message: 'Be the first — post what you need people for.',
            )
          else
            ...teams.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: _TeamCard(task: e.value),
                )
                    .animate(delay: (60 + e.key * 70).ms)
                    .fadeIn(duration: 320.ms)),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TeamCreateSheet(),
    );
  }
}

/// Head-count card with live reservation progress.
class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final filled = task.applicantCount.clamp(0, task.capacity);
    final progress = task.capacity == 0 ? 0.0 : filled / task.capacity;
    final full = filled >= task.capacity;

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
                  gradient: task.kind == PostKind.trip
                      ? AppColors.sunsetPop
                      : AppColors.aurora,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  task.kind == PostKind.trip
                      ? Icons.luggage_rounded
                      : Icons.diversity_3_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 3),
                    Text(
                      '${DateFormat('EEE d MMM · h:mm a').format(task.scheduledAt)} · ${task.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.payoutNote.isNotEmpty) ...[
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                Icon(
                  task.kind == PostKind.trip
                      ? Icons.luggage_rounded
                      : Icons.flag_rounded,
                  size: 14,
                  color: AppColors.textFaint,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(task.payoutNote,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.md),
          // Head-count reservation meter.
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.rPill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation(
                        full ? AppColors.success : AppColors.auroraSky,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Text(
                full ? 'FULL' : '$filled / ${task.capacity} joined',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: full ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              if (task.rewardAmount > 0)
                TintPill(
                  label: '₹${task.rewardAmount.toStringAsFixed(0)} per head',
                  bg: AppColors.infoSoft,
                  fg: AppColors.info,
                  icon: Icons.currency_rupee_rounded,
                  small: true,
                )
              else
                TintPill(
                  label: 'Free to join',
                  bg: AppColors.successSoft,
                  fg: AppColors.success,
                  icon: Icons.volunteer_activism_rounded,
                  small: true,
                ),
              if (task.genderPreference != GenderPreference.anyone) ...[
                const SizedBox(width: 8),
                GenderPrefBadge(pref: task.genderPreference, small: true),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: full
                      ? AppColors.successSoft
                      : AppColors.mintSoft.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimens.rPill),
                ),
                child: Text(
                  full ? 'TEAM FULL' : '${task.capacity - filled} spots left',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color: full ? AppColors.success : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamCreateSheet extends ConsumerStatefulWidget {
  const _TeamCreateSheet();

  @override
  ConsumerState<_TeamCreateSheet> createState() => _TeamCreateSheetState();
}

class _TeamCreateSheetState extends ConsumerState<_TeamCreateSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  PostKind _kind = PostKind.team;
  int _headcount = 10;
  DateTime _when = DateTime.now().add(const Duration(days: 2));
  bool _splitCosts = false;
  double _totalCost = 2000;
  GenderPreference _genderPref = GenderPreference.anyone;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _titleCtrl.text.trim().length >= 4 &&
      _areaCtrl.text.trim().isNotEmpty;

  void _publish() {
    if (!_valid) return;
    final b = ref.read(storeProvider).backend;
    Haptics.confirm();
    final t = b.postTeamPost(
      kind: _kind,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? 'Join in — details in chat.'
          : _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      when: _when,
      headcount: _headcount,
      destination: _kind == PostKind.trip ? _destCtrl.text.trim() : '',
      exchange:
          _splitCosts ? ExchangeMode.expensesCovered : ExchangeMode.free,
      splitPerHead:
          _splitCosts ? _totalCost / _headcount : 0,
      genderPref: _genderPref,
    );
    Navigator.pop(context);
    context.push('/task/${t.id}');
  }

  @override
  Widget build(BuildContext context) {
    final perHead = _splitCosts && _headcount > 0
        ? _totalCost / _headcount
        : 0.0;

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
              Icon(Icons.diversity_3_rounded, color: AppColors.success),
              SizedBox(width: 10),
              Text('Gather people',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          SegmentedButton<PostKind>(
            segments: const [
              ButtonSegment(
                value: PostKind.team,
                icon: Icon(Icons.diversity_3_rounded, size: 18),
                label: Text('Team'),
              ),
              ButtonSegment(
                value: PostKind.trip,
                icon: Icon(Icons.luggage_rounded, size: 18),
                label: Text('Trip'),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.selectionActive,
              selectedForegroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          TextField(
            controller: _titleCtrl,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: _kind == PostKind.trip
                  ? 'e.g. \"Girls trip to Nandi Hills — sunrise\"'
                  : 'e.g. \"Need 10 men for reel shoot\"',
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'What, when, who pays for what…'),
          ),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _areaCtrl,
            decoration: const InputDecoration(
              hintText: 'Meeting area (e.g. \"Madiwala · Metro Gate B\")',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          if (_kind == PostKind.trip) ...[
            const SizedBox(height: AppDimens.sm),
            TextField(
              controller: _destCtrl,
              decoration: const InputDecoration(
                hintText: 'Destination (e.g. \"Nandi Hills\")',
                prefixIcon: Icon(Icons.luggage_rounded),
              ),
            ),
          ],
          const SizedBox(height: AppDimens.lg),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.strokeStrong),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _when,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (d == null || !context.mounted) return;
              final tt = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_when),
              );
              if (tt == null || !context.mounted) return;
              setState(() {
                _when = DateTime(d.year, d.month, d.day, tt.hour, tt.minute);
              });
            },
            icon: const Icon(Icons.event_rounded,
                size: 18, color: AppColors.textSecondary),
            label: Text(
              DateFormat('EEE d MMM · h:mm a').format(_when),
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          _stepper(
            label: 'Heads needed',
            value: '$_headcount',
            onMinus: () =>
                setState(() => _headcount = (_headcount - 1).clamp(2, 200)),
            onPlus: () =>
                setState(() => _headcount = (_headcount + 1).clamp(2, 200)),
          ),
          const SizedBox(height: AppDimens.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Split venue costs',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: const Text(
                'UPI split — every member pays their share directly',
                style: TextStyle(fontSize: 12)),
            value: _splitCosts,
            activeThumbColor: AppColors.success,
            onChanged: (v) => setState(() => _splitCosts = v),
          ),
          if (_splitCosts) ...[
            _stepper(
              label: 'Total venue cost',
              value: '₹${_totalCost.toStringAsFixed(0)}',
              onMinus: () => setState(
                  () => _totalCost = (_totalCost - 500).clamp(500, 100000)),
              onPlus: () => setState(
                  () => _totalCost = (_totalCost + 500).clamp(500, 100000)),
            ),
            const SizedBox(height: AppDimens.sm),
            SoftCard(
              color: AppColors.infoSoft,
              borderColor: AppColors.infoSoft,
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.info),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(
                      '₹${perHead.toStringAsFixed(0)} per head × $_headcount heads\n'
                      'Settled over UPI — one tap deep-link in chat after confirm.',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimens.md),
          const Text('Who can join?',
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
              label: _kind == PostKind.trip
                  ? 'Post trip'
                  : 'Post team request',
              icon: _kind == PostKind.trip
                  ? Icons.luggage_rounded
                  : Icons.diversity_3_rounded,
              onPressed: _valid ? _publish : null,
              color: AppColors.success,
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
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13.5))),
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
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 13.5)),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}
