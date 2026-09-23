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

/// Step 3 of 3 — identity. Aurora wash, live gradient avatar preview,
/// elevated fields, gradient gender cards, category selection pills.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  Gender? _gender;
  final Set<String> _categories = {};

  String? _selectedAvatar = 'assets/avatars/1.jpg';

  static const _avatars = [
    'assets/avatars/1.jpg',
    'assets/avatars/2.jpg',
    'assets/avatars/3.jpg',
    'assets/avatars/4.jpg',
    'assets/avatars/5.jpg',
    'assets/avatars/6.jpg',
    'assets/avatars/7.jpg',
    'assets/avatars/8.jpg',
    'assets/avatars/9.jpg',
    'assets/avatars/10.jpg',
  ];

  static const _allCategories = [
    ('Errands', Icons.directions_run_rounded),
    ('Company', Icons.group_rounded),
    ('Food', Icons.restaurant_rounded),
    ('Sports', Icons.sports_cricket_rounded),
    ('Study', Icons.menu_book_rounded),
    ('Culture', Icons.theater_comedy_rounded),
    ('Transport', Icons.commute_rounded),
  ];

  bool get _valid =>
      _nameCtrl.text.trim().length >= 2 &&
      _gender != null &&
      _categories.isNotEmpty;

  void _save() {
    ref.read(storeProvider).backend.completeSignupProfile(
          name: _nameCtrl.text.trim(),
          gender: _gender!,
          bio: _bioCtrl.text.trim(),
          categories: _categories.toList(),
          photoUrl: _selectedAvatar,
        );
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // ── Ambient aurora wash ───────────────────────────────────
          Positioned(
            top: -160,
            left: -80,
            right: -80,
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraViolet.withValues(alpha: 0.14),
                    AppColors.auroraMint.withValues(alpha: 0.10),
                    AppColors.canvas.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.xl, AppDimens.lg, AppDimens.xl, AppDimens.xl),
              children: [
                // ── Top: back + brand icon + step dots ───────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UniformBackButton(onTap: () => context.pop()),
                    const SizedBox(width: AppDimens.sm),
                    Image.asset(
                      'assets/logo_icon.png',
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    const StepDots(current: 2, total: 3),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppDimens.xl),

                // ── Heading ─────────────────────────────────────────
                const Text(
                  'Make it easy\nto trust you',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.1,
                    height: 1.08,
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.25,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.sm),
                const Text(
                  'Public name only — your email stays private. Pick what you\'re happy to help with.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ).animate(delay: 140.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimens.xl),

                // ── Live identity preview + Avatar Selection ─────────
                Center(
                  child: Column(
                    children: [
                      GradientAvatar(
                        name: _nameCtrl.text.trim().isEmpty
                            ? 'You'
                            : _nameCtrl.text.trim(),
                        photoUrl: _selectedAvatar,
                        size: 88,
                      ).animate().scale(
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose an Avatar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _avatars.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final path = _avatars[index];
                            final isSelected = _selectedAvatar == path;
                            return GestureDetector(
                              onTap: () {
                                Haptics.select();
                                setState(() {
                                  _selectedAvatar = path;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.coral
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.coral
                                                .withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipOval(
                                  child: Image.asset(path, fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),

                // ── Fields — elevated & neat ──────────────────────
                _ElevatedField(
                  controller: _nameCtrl,
                  hint: 'Public name (e.g. Ayesha K.)',
                  icon: Icons.person_outline_rounded,
                  maxLength: 30,
                  onChanged: (_) => setState(() {}),
                ).animate(delay: 250.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.md),
                _ElevatedField(
                  controller: _bioCtrl,
                  hint: 'One line about you (optional)',
                  icon: Icons.notes_rounded,
                  maxLength: 140,
                  maxLines: 1,
                  onChanged: (_) => setState(() {}),
                ).animate(delay: 320.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.lg),

                // ── Gender — gradient selectable cards ──────────────
                const _SectionLabel(
                  title: 'Your gender',
                  note:
                      'Used only to gate girls-only / boys-only posts — a safety feature. Never shown publicly beyond that.',
                )
                    .animate(delay: 380.ms)
                    .fadeIn(),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: Gender.values.map((g) {
                    final on = _gender == g;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: g == Gender.values.last
                                ? 0
                                : AppDimens.sm),
                        child: GestureDetector(
                          onTap: () {
                            Haptics.select();
                            setState(() => _gender = g);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: on ? AppColors.aurora : null,
                              color: on ? null : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.rMd),
                              border: Border.all(
                                color: on
                                    ? Colors.transparent
                                    : AppColors.stroke,
                              ),
                              boxShadow: on
                                  ? [
                                      BoxShadow(
                                        color: AppColors.auroraSky
                                            .withValues(alpha: 0.3),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : const [
                                      BoxShadow(
                                        color: Color(0x0A101323),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: on
                                        ? const LinearGradient(colors: [
                                            Colors.white,
                                            Colors.white
                                          ])
                                        : AppColors.aurora,
                                  ),
                                  child: Icon(
                                    g.icon,
                                    size: 19,
                                    color: on
                                        ? AppColors.auroraSky
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  g.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: on
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: AppDimens.lg),

                // ── Categories — icon selection pills ───────────────
                const _SectionLabel(title: 'I can help with')
                    .animate(delay: 420.ms)
                    .fadeIn(),
                const SizedBox(height: AppDimens.sm),
                Wrap(
                  spacing: AppDimens.sm,
                  runSpacing: AppDimens.sm,
                  children: _allCategories.map((c) {
                    final (label, icon) = c;
                    final on = _categories.contains(label);
                    return GestureDetector(
                      onTap: () {
                        Haptics.select();
                        setState(() => on
                            ? _categories.remove(label)
                            : _categories.add(label));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: on ? AppColors.aurora : null,
                          color: on ? null : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.rPill),
                          border: Border.all(
                            color: on
                                ? Colors.transparent
                                : AppColors.stroke,
                          ),
                          boxShadow: on
                              ? [
                                  BoxShadow(
                                    color: AppColors.auroraMint
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: on
                                  ? AppColors.textOnAurora
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: on
                                    ? AppColors.textOnAurora
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate(delay: 450.ms).fadeIn(),
                const SizedBox(height: AppDimens.xl),
                PrimaryButton(
                  label: 'Enter Madiwala',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _valid ? _save : null,
                ).animate(delay: 500.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.md),
                const Center(
                  child: Text(
                    'Verification badges come later — behavior builds trust here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textFaint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate(delay: 540.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section label with an optional muted note under it.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
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
            note!,
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
}

/// Elevated borderless text field with a prefix icon.
class _ElevatedField extends StatelessWidget {
  const _ElevatedField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.maxLength,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLength;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.rField + 4),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101323),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textFaint,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 48),
          counterText: '',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.rField + 4),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// Circular elevated icon button — retired: replaced by the shared
// [UniformBackButton] so every screen shares one back control.
