import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../data/mock_backend.dart' show TaskDraft;
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class CreateWizardScreen extends ConsumerStatefulWidget {
  const CreateWizardScreen({super.key});

  @override
  ConsumerState<CreateWizardScreen> createState() =>
      _CreateWizardScreenState();
}

class _CreateWizardScreenState extends ConsumerState<CreateWizardScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  int _step = 0;
  bool _publishing = false;

  final TaskDraft _draft = TaskDraft();

  static const _stepTitles = ['Type', 'Details', 'Exchange', 'Review'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _titleCtrl.text.trim().length >= 4 &&
            _descCtrl.text.trim().length >= 10;
      case 2:
        return _draft.exchange == ExchangeMode.paid
            ? _draft.rewardAmount > 0
            : true;
      case 3:
        return true;
    }
    return false;
  }

  Future<void> _next() async {
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    // Publish: simulated SAFETY_CHECK state (server-side in Stage 2).
    setState(() => _publishing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final b = ref.read(storeProvider).backend;
    _draft.title = _titleCtrl.text.trim();
    _draft.description = _descCtrl.text.trim();
    if (_areaCtrl.text.trim().isNotEmpty) {
      _draft.area = _areaCtrl.text.trim();
    }
    b.postTask(_draft);
    Haptics.confirm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Published after safety check — visible in Madiwala now.'),
        ),
      );
      context.go('/home');
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final typeParam =
        GoRouterState.of(context).uri.queryParameters['type'];
    if (_step == 0 && typeParam != null) {
      _draft.type = PostType.values.byName(typeParam);
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: UniformBackButton(onTap: _back),
        title: Text('Create · ${_stepTitles[_step]}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.xl),
              child: Row(
                children: [
                  const SizedBox(width: AppDimens.md),
                  Text(
                    'Step ${_step + 1} of 4',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  ProgressDots(total: 4, current: _step),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.xl, 10, AppDimens.xl, 10),
                children: [_buildStep()],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppDimens.xl, 0, AppDimens.xl,
                  MediaQuery.of(context).padding.bottom + 12),
              child: PrimaryButton(
                label: _publishing
                    ? 'Publishing…'
                    : (_step == 3 ? 'Publish' : 'Continue'),
                icon: _step == 3 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                loading: _publishing,
                onPressed: _stepValid ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepType();
      case 1:
        return _stepDetails();
      case 2:
        return _stepExchange();
      case 3:
        return _stepReview();
    }
    return const SizedBox.shrink();
  }

  // ── Step 0: Type ────────────────────────────────────────────────
  Widget _stepType() {
    return Column(
      children: [
        for (final t in PostType.values) ...[
          ChoiceCard(
            icon: t.icon,
            iconGradient: switch (t) {
              PostType.task => AppColors.aurora,
              PostType.company => AppColors.violetDream,
              PostType.offer => AppColors.sunsetPop,
            },
            title: t.label,
            subtitle: t.tagline,
            selected: _draft.type == t,
            onTap: () => setState(() => _draft.type = t),
          ),
          const SizedBox(height: AppDimens.md),
        ],
      ],
    );
  }

  // ── Step 1: Details ────────────────────────────────────────────
  Widget _stepDetails() {
    final b = ref.read(storeProvider).backend;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          maxLength: 60,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Title (e.g. "Help carry groceries")',
          ),
        ),
        const SizedBox(height: AppDimens.sm),
        TextField(
          controller: _descCtrl,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Describe what you need, when, where (area only!)…',
          ),
        ),
        const SizedBox(height: AppDimens.md),
          _sectionLabel(title: 'Category', note: null).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: b.categories
                .where((c) => c != 'All')
                .map((c) => _selectPill(
                      label: c,
                      selected: _draft.category == c,
                      onTap: () => setState(() => _draft.category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppDimens.md),
          _sectionLabel(title: 'When', note: 'Pick when & how long the activity runs.').animate(delay: 260.ms).fadeIn(),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              Expanded(
                child: _dateTimeChip(
                  label: 'When',
                  icon: Icons.event_rounded,
                  value: DateFormat('d MMM, h:mm a').format(_draft.scheduledAt),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _draft.scheduledAt,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 30)),
                    );
                    if (!mounted) return;
                    if (d == null) return;
                    final t = _draft.scheduledAt;
                    final n = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(t),
                    );
                    if (!mounted || n == null) return;
                    setState(() {
                      _draft.scheduledAt = DateTime(
                        d.year, d.month, d.day, n.hour, n.minute,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: _dateTimeChip(
                  label: 'Duration',
                  icon: Icons.timer_outlined,
                  value:
                      _draft.durationMinutes < 60
                          ? '${_draft.durationMinutes} min'
                          : '${(_draft.durationMinutes ~/ 60)} hr',
                  onTap: () {
                    final chips = [30, 60, 120, 180];
                    int next;
                    if (_draft.durationMinutes >= chips.last) {
                      next = chips.first;
                    } else {
                      final i = chips.indexOf(_draft.durationMinutes);
                      next = chips[i + 1];
                    }
                    setState(() => _draft.durationMinutes = next);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          _sectionLabel(
            title: 'Where',
            note: 'Area only — never exact addresses here.',
          ).animate(delay: 320.ms).fadeIn(),
          const SizedBox(height: AppDimens.sm),
          TextField(
            controller: _areaCtrl,
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. "Madiwala · 5th Block"',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          _sectionLabel(
            title: 'People needed',
            note: 'How many can join this activity.',
          ).animate(delay: 380.ms).fadeIn(),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [1, 2, 3, 4, 6].map((n) {
              final on = _draft.capacity == n;
              return _selectPill(
                label: '$n (${n == 1 ? 'person' : 'people'})',
                selected: on,
                onTap: () => setState(() => _draft.capacity = n),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.md),
          _sectionLabel(
            title: 'Who can join?',
            note: 'Safety first — many members prefer same-gender company for travel, nights out or home visits.',
          ).animate(delay: 440.ms).fadeIn(),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: GenderPreference.values.map((g) {
              final on = _draft.genderPreference == g;
              return _selectPill(
                label: g.label,
                icon: g.icon,
                selected: on,
                onTap: () => setState(() => _draft.genderPreference = g),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Step 2: Exchange ───────────────────────────────────────────
  Widget _stepExchange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How is this exchanged?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppDimens.sm),
        const Text(
          'Free and treats are the community glue — choose them proudly.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),        const SizedBox(height: AppDimens.lg),
        for (final m in ExchangeMode.values) ...[
          ChoiceCard(
            icon: switch (m) {
              ExchangeMode.paid => Icons.currency_rupee_rounded,
              ExchangeMode.free => Icons.volunteer_activism_rounded,
              ExchangeMode.treat => Icons.emoji_food_beverage_rounded,
              ExchangeMode.expensesCovered => Icons.local_gas_station_rounded,
              ExchangeMode.negotiable => Icons.forum_rounded,
              ExchangeMode.barter => Icons.sync_alt_rounded,
            },
            iconGradient: switch (m) {
              ExchangeMode.free => AppColors.aurora,
              ExchangeMode.treat => AppColors.sunsetPop,
              ExchangeMode.barter => AppColors.violetDream,
              _ => AppColors.aurora,
            },
            title: m.label,
            subtitle: switch (m) {
              ExchangeMode.paid => 'Cash or UPI settled directly between members',
              ExchangeMode.free => 'No money involved at all',
              ExchangeMode.treat => 'You provide food/coffee/entry',
              ExchangeMode.expensesCovered => 'Travel, tickets, materials on you',
              ExchangeMode.negotiable => 'Decide together in chat',
              ExchangeMode.barter => 'Trade time or skills instead of money',
            },
            selected: _draft.exchange == m,
            onTap: () => setState(() => _draft.exchange = m),
          ),
          const SizedBox(height: AppDimens.md),
        ],
        if (_draft.exchange == ExchangeMode.paid) ...[
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Text('₹',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      _draft.rewardAmount = double.tryParse(v) ?? 0,
                  decoration: const InputDecoration(
                    hintText: 'Amount (e.g. 150)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          const SoftCard(
            color: AppColors.butterSoft,
            borderColor: AppColors.butter,
            child: Text(
              'MVP note: money is settled directly between members (cash/UPI). '
              'The platform holds no funds and makes no payment guarantees.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

// ── Step 3: Review + safety ────────────────────────────────────
  Widget _stepReview() {
    final risk = _previewRisk();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review before publish',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppDimens.lg),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExchangeChip(mode: _draft.exchange),
                  const Spacer(),
                  RiskBadge(risk: risk),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                _titleCtrl.text.isEmpty
                    ? '(untitled)'
                    : _titleCtrl.text,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                _descCtrl.text.isEmpty ? '(no description)' : _descCtrl.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Divider(height: AppDimens.xl),
              InfoTile(
                icon: Icons.schedule_rounded,
                label: 'When',
                value:
                    '${DateFormat('EEE d MMM').format(_draft.scheduledAt)} · ${DateFormat('h:mm a').format(_draft.scheduledAt)} · ${_draft.durationMinutes < 60 ? '${_draft.durationMinutes} min' : '${_draft.durationMinutes ~/ 60} hr'}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.md),
        const Text('Safety & privacy',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppDimens.sm),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Public meeting point',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: const Text(
              'Recommended for first-time meetings',
              style: TextStyle(fontSize: 12)),
          value: _draft.meetingPreference == 'Public meeting point',
          activeThumbColor: AppColors.success,
          onChanged: (v) => setState(() {
            _draft.meetingPreference =
                v ? 'Public meeting point' : 'Decided in chat';
          }),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable check-ins',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: const Text(
              '"I\'m safe" prompts for this activity',
              style: TextStyle(fontSize: 12)),
          value: _draft.hasCheckin,
          activeThumbColor: AppColors.success,
          onChanged: (v) => setState(() => _draft.hasCheckin = v),
        ),
        if (risk == TaskRisk.high) ...[
          const SizedBox(height: AppDimens.sm),
          const SoftCard(
            color: AppColors.dangerSoft,
            borderColor: AppColors.dangerSoft,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger),
                SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text(
                    'Night-time activities get high-risk labels automatically. Stronger verification and check-ins apply.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  TaskRisk _previewRisk() {
    final h = _draft.scheduledAt.hour;
    if (h >= 21 || h <= 5) return TaskRisk.high;
    if (_draft.durationMinutes > 180) return TaskRisk.medium;
    return TaskRisk.low;
  }

  /// Minimal section label used across wizard steps.
  Widget _sectionLabel({required String title, String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 3),
          Text(
            note,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textFaint,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  /// Single-select pill with optional icon, consistent across steps.
  Widget _selectPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () {
        Haptics.select();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.aurora : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.stroke,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.auroraMint.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.textOnAurora : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected
                    ? AppColors.textOnAurora
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Outlined pill with a live value + setter (date/time, duration).
  Widget _dateTimeChip({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.strokeStrong),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(
        value,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

