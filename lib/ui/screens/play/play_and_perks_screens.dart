// Phase 6 — Play & Earn: micro skill games that pay Time Credits.
// Phase 7 — Partner Perks: local merchants accept credits for vouchers.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../data/mock_backend.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

/// ── Phase 6 · Play & Earn hub — the arcade lobby ───────────────────
class PlayEarnScreen extends ConsumerWidget {
  const PlayEarnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final me = b.currentUser;
    final playedCount = kSeedChallenges.where((c) => b.hasPlayedToday(c.id)).length;
    final allDone = playedCount == kSeedChallenges.length;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: const Text('Play & Earn',
            style: TextStyle(color: Colors.white)),
        leading: const UniformBackButton.dark(),
        backgroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 40),
        children: [
          // ── Wallet strip — credits + daily progress ────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg, vertical: AppDimens.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimens.rTile),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.aurora,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.diamond_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${me?.karma ?? 0} Time Credits',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Daily progress: challenges played today.
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.rPill),
                              child: LinearProgressIndicator(
                                value: playedCount / kSeedChallenges.length,
                                minHeight: 5,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.12),
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                        AppColors.auroraMint),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$playedCount/${kSeedChallenges.length} played today',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: AppDimens.xl),

          // ── Arcade cabinet cards — one per game ────────────────
          ...kSeedChallenges.asMap().entries.map((e) {
            final c = e.value;
            final played = b.hasPlayedToday(c.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.lg),
              child: _ArcadeCard(
                challenge: c,
                played: played,
                onPlay: () => _play(context, c),
              ),
            )
                .animate(delay: (100 + e.key * 100).ms)
                .fadeIn(duration: 360.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
          }),

          // ── How earning works ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimens.rTile),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.diamond_rounded,
                        size: 15, color: AppColors.auroraMint),
                    const SizedBox(width: 6),
                    Text(
                      'HOW EARNING WORKS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _EarnRow(
                    n: '1',
                    text:
                        'Beat a challenge target → full ${kSeedChallenges.first.rewardKarma}–${kSeedChallenges.last.rewardKarma} credits'),
                _EarnRow(
                    n: '2',
                    text: 'Every play pays at least +10 credits — never zero'),
                _EarnRow(
                    n: '3',
                    text: 'Spend credits at partner cafes in Partner Perks'),
              ],
            ),
          ).animate(delay: 320.ms).fadeIn(duration: 360.ms),

          if (allDone) ...[
            const SizedBox(height: AppDimens.lg),
            Center(
              child: Text(
                'All challenges played — fresh ones land tomorrow',
                style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _play(BuildContext context, PlayChallenge c) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) =>
          c.id == 'memory' ? _ColourEchoGame(challenge: c) : _ReflexRushGame(challenge: c),
    ));
  }
}

/// One-row earning explainer.
class _EarnRow extends StatelessWidget {
  const _EarnRow({required this.n, required this.text});

  final String n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.auroraMint,
              shape: BoxShape.circle,
            ),
            child: Text(n,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arcade cabinet card — gradient art face + play CTA.
class _ArcadeCard extends StatelessWidget {
  const _ArcadeCard({
    required this.challenge,
    required this.played,
    required this.onPlay,
  });

  final PlayChallenge challenge;
  final bool played;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: c.gradient.first.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Art face: gradient banner with big glyph + reward pill ──
          Container(
            height: 108,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.gradient,
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.rTile + 4)),
            ),
            child: Stack(
              children: [
                // Decorative rings.
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: -34,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // Big game glyph.
                Positioned(
                  right: 22,
                  bottom: 12,
                  child: Icon(c.icon,
                      size: 52,
                      color: Colors.white.withValues(alpha: 0.9)),
                ),
                // Reward pill.
                Positioned(
                  left: AppDimens.lg,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius:
                          BorderRadius.circular(AppDimens.rPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'WIN +${c.rewardKarma} credits',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Played state.
                if (played)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimens.rPill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 13, color: AppColors.success),
                          SizedBox(width: 3),
                          Text(
                            'PLAYED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Title.
                Positioned(
                  left: AppDimens.lg,
                  bottom: 12,
                  child: Text(
                    c.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Footer: rules + CTA ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.rules,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: c.gradient),
                      borderRadius:
                          BorderRadius.circular(AppDimens.rPill),
                      boxShadow: [
                        BoxShadow(
                          color: c.gradient.first.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(AppDimens.rPill),
                        onTap: () {
                          Haptics.medium();
                          onPlay();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(c.icon,
                                size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              played ? 'Play again' : 'Start challenge',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reflex Rush — dark arena, combo streaks, shrinking orb, floating +N.
class _ReflexRushGame extends ConsumerStatefulWidget {
  const _ReflexRushGame({required this.challenge});

  final PlayChallenge challenge;

  @override
  ConsumerState<_ReflexRushGame> createState() => _ReflexRushGameState();
}

class _ReflexRushGameState extends ConsumerState<_ReflexRushGame>
    with SingleTickerProviderStateMixin {
  static const _gameSeconds = 30;

  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _secondsLeft = _gameSeconds;
  Offset _orbPos = const Offset(0.5, 0.4);
  double _orbSize = 74;
  bool _finished = false;
  Offset? _popPos; // where the +N floats
  int _popTick = 0;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.94,
    upperBound: 1.06,
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _tick() async {
    while (_secondsLeft > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _secondsLeft -= 1);
    }
    if (mounted) setState(() => _finished = true);
  }

  void _tapOrb() {
    if (_finished) return;
    final rnd = Random();
    final combo = _combo + 1;
    Haptics.select();
    setState(() {
      _score += 1;
      _combo = combo;
      _bestCombo = max(_bestCombo, combo);
      _orbPos = Offset(
        0.14 + rnd.nextDouble() * 0.72,
        0.14 + rnd.nextDouble() * 0.62,
      );
      // Orb shrinks a touch as combo climbs (harder, juicier).
      _orbSize = max(54.0, 76.0 - combo * 1.6);
      _popPos = _orbPos;
      _popTick++;
    });
  }

  void _missTap() {
    if (_finished) return;
    if (_combo == 0) return;
    Haptics.light();
    setState(() => _combo = 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final progress = _secondsLeft / _gameSeconds;
    final timeCritical = _secondsLeft <= 8;
    final hot = _combo >= 5;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        leading: const UniformBackButton.dark(),
        title: Text(c.title, style: const TextStyle(color: Colors.white)),
      ),
      body: _finished
          ? _ResultView(
              challenge: c,
              score: _score,
              onDone: () => Navigator.pop(context),
            )
          : SafeArea(
              child: Column(
                children: [
                  // ── HUD ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.lg, vertical: AppDimens.sm),
                    child: Row(
                      children: [
                        // Score chip.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(
                                AppDimens.rPill),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  size: 17, color: AppColors.auroraMint),
                              const SizedBox(width: 5),
                              Text('$_score',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16)),
                              Text(' / ${c.target}',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.45),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Combo chip (ignites at 5+).
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hot
                                ? AppColors.auroraCoral
                                    .withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.07),
                            borderRadius:
                                BorderRadius.circular(AppDimens.rPill),
                            border: hot
                                ? Border.all(
                                    color: AppColors.auroraCoral
                                        .withValues(alpha: 0.6))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  size: 16,
                                  color: hot
                                      ? AppColors.auroraCoral
                                      : Colors.white38),
                              const SizedBox(width: 4),
                              Text(
                                '${_combo}x',
                                style: TextStyle(
                                  color: hot
                                      ? Colors.white
                                      : Colors.white38,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Countdown ring.
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3.5,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.10),
                                valueColor: AlwaysStoppedAnimation(
                                  timeCritical
                                      ? AppColors.auroraCoral
                                      : AppColors.auroraMint,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '$_secondsLeft',
                                  style: TextStyle(
                                    color: timeCritical
                                        ? AppColors.auroraCoral
                                        : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Target hint ──────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimens.sm),
                    child: Text(
                      'Beat ${c.target} pts — don\'t break the streak!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),

                  // ── Arena ────────────────────────────────────
                  Expanded(
                    child: GestureDetector(
                      onTap: _missTap,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(
                            AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.035),
                          borderRadius:
                              BorderRadius.circular(AppDimens.rTile + 8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ambient arena rings.
                            Center(
                              child: Icon(Icons.blur_on_rounded,
                                  size: 240,
                                  color: Colors.white
                                      .withValues(alpha: 0.03)),
                            ),
                            // The orb.
                            AnimatedAlign(
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment(
                                _orbPos.dx * 2 - 1,
                                _orbPos.dy * 2 - 1,
                              ),
                              child: ScaleTransition(
                                scale: _pulse,
                                child: GestureDetector(
                                  onTap: _tapOrb,
                                  child: Container(
                                    width: _orbSize,
                                    height: _orbSize,
                                    decoration: BoxDecoration(
                                      gradient: hot
                                          ? const LinearGradient(colors: [
                                              AppColors.auroraCoral,
                                              AppColors.auroraAmber,
                                            ])
                                          : AppColors.aurora,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (hot
                                                  ? AppColors.auroraCoral
                                                  : AppColors.auroraSky)
                                              .withValues(alpha: 0.55),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.touch_app_rounded,
                                        color: Colors.white,
                                        size: 30),
                                  ),
                                ),
                              ),
                            ),
                            // Floating +N pop.
                            if (_popPos != null)
                              Align(
                                alignment: Alignment(
                                  _popPos!.dx * 2 - 1,
                                  _popPos!.dy * 2 - 1,
                                ),
                                child: Text(
                                  '+1',
                                  key: ValueKey(_popTick),
                                  style: const TextStyle(
                                    color: AppColors.auroraMint,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 120.ms)
                                    .slideY(
                                      begin: -0.2,
                                      end: -1.4,
                                      duration: 520.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .fadeOut(delay: 260.ms),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Colour Echo — dark Simon pads, live input dots, level progress.
class _ColourEchoGame extends ConsumerStatefulWidget {
  const _ColourEchoGame({required this.challenge});

  final PlayChallenge challenge;

  @override
  ConsumerState<_ColourEchoGame> createState() => _ColourEchoGameState();
}

class _ColourEchoGameState extends ConsumerState<_ColourEchoGame> {
  static const _pads = [
    (Color(0xFF0EA5E9), Color(0xFF7DD3FC), Icons.water_drop_rounded),
    (Color(0xFF10B981), Color(0xFF6EE7B7), Icons.eco_rounded),
    (Color(0xFF8B5CF6), Color(0xFFC4B5FD), Icons.auto_awesome_rounded),
    (Color(0xFFFB7185), Color(0xFFFDA4AF), Icons.favorite_rounded),
  ];

  final List<int> _sequence = [];
  final List<int> _input = [];
  bool _showing = false;
  int _lit = -1;
  int _wrongPad = -1;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  int get _round => _sequence.length;

  Future<void> _nextRound() async {
    _sequence.add(Random().nextInt(4));
    _input.clear();
    setState(() => _showing = true);
    await Future<void>.delayed(const Duration(milliseconds: 520));
    for (final i in _sequence) {
      if (!mounted) return;
      setState(() => _lit = i);
      Haptics.light();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _lit = -1);
      await Future<void>.delayed(const Duration(milliseconds: 170));
    }
    if (!mounted) return;
    setState(() => _showing = false);
  }

  void _press(int i) {
    if (_showing || _finished) return;
    Haptics.select();
    setState(() => _input.add(i));
    if (_sequence[_input.length - 1] != i) {
      Haptics.heavy();
      setState(() {
        _wrongPad = i;
        _finished = true;
      });
      return;
    }
    if (_input.length == _sequence.length) {
      Haptics.confirm();
      Future<void>.delayed(const Duration(milliseconds: 480), () {
        if (mounted) _nextRound();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final levelProgress =
        (_round - 1) / max(1, c.target); // target rounds → full bar
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        leading: const UniformBackButton.dark(),
        title: Text(c.title, style: const TextStyle(color: Colors.white)),
      ),
      body: _finished
          ? _ResultView(
              challenge: c,
              score: _sequence.length - 1,
              onDone: () => Navigator.pop(context),
            )
          : SafeArea(
              child: Column(
                children: [
                  // ── HUD: level pill + progress ────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg, AppDimens.sm, AppDimens.lg, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Phase state pill.
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: _showing
                                    ? AppColors.auroraAmber
                                        .withValues(alpha: 0.18)
                                    : AppColors.auroraMint
                                        .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.rPill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showing
                                        ? Icons.visibility_rounded
                                        : Icons.back_hand_rounded,
                                    size: 14,
                                    color: _showing
                                        ? AppColors.auroraAmber
                                        : AppColors.auroraMint,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _showing
                                        ? 'WATCH THE ECHO'
                                        : 'YOUR TURN',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: _showing
                                          ? AppColors.auroraAmber
                                          : AppColors.auroraMint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.rPill),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stairs_rounded,
                                      size: 15,
                                      color: AppColors.auroraViolet),
                                  const SizedBox(width: 5),
                                  Text('Level $_round',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Progress toward the credit target.
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimens.rPill),
                          child: LinearProgressIndicator(
                            value: levelProgress.clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.10),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.auroraViolet),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Level ${c.target} pays +${c.rewardKarma} credits',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Live input dots ───────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimens.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _sequence.length; i++)
                          Container(
                            width: 10,
                            height: 10,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _input.length
                                  ? _pads[_sequence[i]].$1
                                  : Colors.white.withValues(alpha: 0.14),
                              border: i < _input.length
                                  ? null
                                  : Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.18)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── The four pads ─────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppDimens.md,
                        crossAxisSpacing: AppDimens.md,
                        childAspectRatio: 1.15,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(4, (i) {
                          final lit = _lit == i;
                          final wrong = _wrongPad == i;
                          final dim = _showing && _lit != -1 && !lit;
                          return GestureDetector(
                            onTap: () => _press(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                gradient: lit || wrong
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          _pads[i]
                                              .$1
                                              .withValues(
                                                  alpha: dim ? 0.35 : 0.85),
                                          _pads[i]
                                              .$1
                                              .withValues(
                                                  alpha: dim ? 0.22 : 0.55),
                                        ],
                                      ),
                                color: lit
                                    ? _pads[i].$2
                                    : wrong
                                        ? AppColors.danger
                                        : null,
                                borderRadius: BorderRadius.circular(
                                    AppDimens.rTile),
                                border: Border.all(
                                  color: (lit || wrong)
                                      ? Colors.white
                                          .withValues(alpha: 0.65)
                                      : Colors.white
                                          .withValues(alpha: 0.10),
                                  width: lit || wrong ? 2 : 1,
                                ),
                                boxShadow: lit
                                    ? [
                                        BoxShadow(
                                          color: _pads[i]
                                              .$1
                                              .withValues(alpha: 0.65),
                                          blurRadius: 30,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                _pads[i].$3,
                                size: lit ? 44 : 36,
                                color: Colors.white
                                    .withValues(alpha: lit ? 1 : 0.55),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Shared post-game result view that banks the credits.
class _ResultView extends ConsumerStatefulWidget {
  const _ResultView({
    required this.challenge,
    required this.score,
    required this.onDone,
  });

  final PlayChallenge challenge;
  final int score;
  final VoidCallback onDone;

  @override
  ConsumerState<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<_ResultView> {
  bool _banked = false;

  @override
  void initState() {
    super.initState();
    if (!_banked) {
      _banked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(storeProvider).backend.recordPlay(
              challengeId: widget.challenge.id,
              score: widget.score,
              target: widget.challenge.target,
              rewardKarma: widget.challenge.rewardKarma,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.score >= widget.challenge.target;
    final earned = won ? widget.challenge.rewardKarma : 10;
    return Container(
      color: AppColors.ink,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy burst.
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: won
                        ? [AppColors.auroraMint, AppColors.auroraSky]
                        : [AppColors.auroraViolet, AppColors.auroraLilac]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (won ? AppColors.auroraMint : AppColors.auroraViolet)
                        .withValues(alpha: 0.5),
                    blurRadius: 44,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(
                won ? Icons.emoji_events_rounded : Icons.stars_rounded,
                color: Colors.white,
                size: 50,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  duration: 520.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: AppDimens.xl),
            Text(
              won ? 'Target beaten!' : 'Good try!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Score ${widget.score} · target ${widget.challenge.target}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: AppDimens.xl),
            // Credit reward card.
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppDimens.xxl),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg, vertical: AppDimens.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppDimens.rTile),
                border: Border.all(
                    color: AppColors.auroraMint.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond_rounded,
                      color: AppColors.auroraMint, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '+$earned Time Credits banked',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 260.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: AppDimens.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.xxl),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Collect & exit',
                  icon: Icons.diamond_rounded,
                  onPressed: widget.onDone,
                ),
              ),
            ).animate(delay: 340.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

/// ── Phase 7 · Partner Perks ──────────────────────────────────────
class PartnerPerksScreen extends ConsumerWidget {
  const PartnerPerksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(storeProvider).backend;
    final me = b.currentUser;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Partner Perks'),
        leading: const UniformBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.lg, AppDimens.sm, AppDimens.lg, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              gradient: AppColors.sunsetPop,
              borderRadius: BorderRadius.circular(AppDimens.rTile + 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auroraCoral.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spend your Time Credits',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Local cafes and shops honour these vouchers — '
                        'claim with credits, show the app at the counter.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(AppDimens.rPill),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.diamond_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        '${me?.karma ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: AppDimens.xl),
          SectionHeader(title: 'Nearby partners'),
          ...kSeedPerks.asMap().entries.map((e) {
            final perk = e.value;
            final claimed = b.isPerkClaimed(perk.id);
            final canAfford = (me?.karma ?? 0) >= perk.costKarma;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient:
                                LinearGradient(colors: perk.gradient),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(perk.emojiIcon,
                              color: Colors.white, size: 25),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(perk.merchant,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: AppColors.textFaint)),
                              const SizedBox(height: 2),
                              Text(perk.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5)),
                            ],
                          ),
                        ),
                        TintPill(
                          label: '${perk.costKarma} cr',
                          bg: AppColors.butterSoft,
                          fg: const Color(0xFF92400E),
                          icon: Icons.diamond_rounded,
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(perk.details,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            height: 1.45)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 13, color: AppColors.textFaint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(perk.area,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          'valid ${perk.validHours}h after claim',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textFaint,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.lg),
                    SizedBox(
                      width: double.infinity,
                      child: claimed
                          ? const TintPill(
                              label:
                                  'Voucher claimed — show the app at the counter',
                              bg: AppColors.successSoft,
                              fg: AppColors.success,
                              icon: Icons.verified_rounded,
                            )
                          : GradientButton(
                              label: canAfford
                                  ? 'Claim for ${perk.costKarma} credits'
                                  : 'Need ${perk.costKarma - (me?.karma ?? 0)} more credits',
                              icon: Icons.redeem_rounded,
                              onPressed: canAfford
                                  ? () {
                                      final ok = b.claimPerk(perk);
                                      Haptics.confirm();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: ok
                                              ? AppColors.success
                                              : AppColors.danger,
                                          content: Text(ok
                                              ? '${perk.merchant} voucher claimed!'
                                              : 'Not enough credits yet — play a challenge!'),
                                        ),
                                      );
                                    }
                                  : null,
                              gradient: const LinearGradient(
                                  colors: [AppColors.auroraAmber, AppColors.auroraCoral]),
                            ),
                    ),
                  ],
                ),
              )
                  .animate(delay: (80 + e.key * 70).ms)
                  .fadeIn(duration: 320.ms),
            );
          }),
        ],
      ),
    );
  }
}
