import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/haptics.dart';
import 'gradient_avatar.dart';
import 'gradient_button.dart';

export 'glass_card.dart';
export 'gradient_avatar.dart';
export 'gradient_button.dart';

/// The ONE back button used on every screen of the app.
///
/// A 36×36 squircle (radius 11) with `arrow_back_rounded`, blending into
/// its area — three variants, chosen by the page's background:
///  • [UniformBackButton.light]  — white chip + hairline stroke + ink icon
///    (light canvas pages — the default everywhere)
///  • [UniformBackButton.dark]   — `#1E293B` chip + white icon (dark
///    slate pages like the Auctions hub)
///  • [UniformBackButton.ghost]  — translucent white fill + white icon
///    (sits ON TOP of colorful heroes/posters without a boxy chip)
///
/// Root tab destinations pass [hidden] explicitly — plain stack pages
/// (even ones opened via `go()`, like /create) always show the button.
class UniformBackButton extends StatelessWidget {
  const UniformBackButton.light({super.key, this.onTap, this.hidden = false})
      : dark = false,
        ghost = false;

  const UniformBackButton.dark({super.key, this.onTap, this.hidden = false})
      : dark = true,
        ghost = false;

  const UniformBackButton.ghost({super.key, this.onTap, this.hidden = false})
      : dark = false,
        ghost = true;

  const UniformBackButton({
    super.key,
    this.dark = false,
    this.ghost = false,
    this.onTap,
    this.hidden = false,
  });

  final bool dark;

  /// Translucent style that melts into gradient heroes/posters.
  final bool ghost;

  /// Optional override — the wizard passes its step-back action here.
  final VoidCallback? onTap;

  /// Root tabs pass true (there is nothing to pop); every normal page
  /// leaves it false so the button always shows.
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();
    return _BackChip(dark: dark, ghost: ghost, onTap: onTap);
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.dark, required this.ghost, this.onTap});

  final bool dark;
  final bool ghost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color iconColor;
    final Border? border;
    if (ghost) {
      fill = Colors.white.withValues(alpha: 0.16);
      iconColor = Colors.white;
      border = Border.all(color: Colors.white.withValues(alpha: 0.18));
    } else if (dark) {
      fill = const Color(0xFF1E293B);
      iconColor = Colors.white;
      border = Border.all(color: Colors.white.withValues(alpha: 0.08));
    } else {
      fill = AppColors.surface;
      iconColor = AppColors.textPrimary;
      border = Border.all(color: const Color(0xFFE2E8F0));
    }

    return Center(
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
            Haptics.select();
            if (onTap != null) {
              onTap!();
            } else if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: border,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compat name for the primary CTA — now the aurora gradient pill,
/// so every legacy callsite gets the new look for free. A [color]
/// argument maps to a solid-tint gradient of that colour.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
      loading: loading,
      gradient: color == null
          ? AppColors.aurora
          : LinearGradient(colors: [color!, color!]),
    );
  }
}

/// Small tinted pill with optional icon.
class TintPill extends StatelessWidget {
  const TintPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
    this.small = false,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 9 : 13,
        vertical: small ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: small ? 11 : 12.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exchange chip with per-mode color treatment.
class ExchangeChip extends StatelessWidget {
  const ExchangeChip({super.key, required this.mode, this.small = false});

  final ExchangeMode mode;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final s = mode.chipStyle;
    return TintPill(
      label: mode.label,
      bg: s.bg,
      fg: s.fg,
      small: small,
    );
  }
}

/// Risk badge — dot + text, never colour-only.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.risk, this.small = false});

  final TaskRisk risk;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final bg = switch (risk) {
      TaskRisk.low => AppColors.successSoft,
      TaskRisk.medium => AppColors.warningSoft,
      TaskRisk.high => AppColors.dangerSoft,
    };
    return TintPill(
      label: risk.label,
      bg: bg,
      fg: risk.color,
      icon: Icons.shield_outlined,
      small: small,
    );
  }
}

/// Gender-restriction badge — only rendered for girls-only / boys-only
/// posts ("Everyone" posts show no badge to avoid badge noise).
class GenderPrefBadge extends StatelessWidget {
  const GenderPrefBadge({super.key, required this.pref, this.small = false});

  final GenderPreference pref;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final s = pref.chipStyle;
    return TintPill(
      label: pref.label,
      bg: s.bg,
      fg: s.fg,
      icon: pref.icon,
      small: small,
    );
  }
}

/// Section header with title + optional action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onViewAll, this.actionLabel});

  final String title;
  final VoidCallback? onViewAll;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                actionLabel ?? 'View all',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.auroraSky,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Creator trust row (avatar + name + badges).
class TrustRow extends StatelessWidget {
  const TrustRow({
    super.key,
    required this.name,
    required this.verified,
    required this.rating,
    required this.completed,
    this.photoUrl,
    this.trailing,
  });

  final String name;
  final String? photoUrl;
  final bool verified;
  final double rating;
  final int completed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GradientAvatar(name: name, photoUrl: photoUrl),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded,
                        size: 16, color: AppColors.auroraSky),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '★ $rating · $completed completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Meaningful, animated empty state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: AppColors.aurora,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auroraSky.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(icon, size: 38, color: Colors.white),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.06, 1.06),
                  duration: 1600.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: AppDimens.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (actions != null) ...[
              const SizedBox(height: AppDimens.xl),
              Wrap(
                spacing: AppDimens.md,
                runSpacing: AppDimens.md,
                alignment: WrapAlignment.center,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wizard progress dots with animated active pill.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.total,
    required this.current,
  });

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active ? AppColors.aurora : null,
            color: active ? null : AppColors.strokeStrong,
            borderRadius: BorderRadius.circular(AppDimens.rPill),
          ),
        );
      }),
    );
  }
}

/// Info tile with tinted icon square.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.tint = AppColors.infoSoft,
    this.iconColor = AppColors.info,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(AppDimens.rSm),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Selectable choice card with animated border + check.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
    this.iconGradient = AppColors.aurora,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Gradient iconGradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: () {
          Haptics.select();
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.infoSoft.withValues(alpha: 0.5)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.rTile),
            border: Border.all(
              color: selected ? AppColors.auroraSky : AppColors.stroke,
              width: selected ? 1.8 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.auroraSky.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: selected
                      ? iconGradient
                      : LinearGradient(colors: [
                          AppColors.strokeStrong.withValues(alpha: 0.35),
                          AppColors.strokeStrong.withValues(alpha: 0.2),
                        ]),
                  borderRadius: BorderRadius.circular(AppDimens.rSm + 2),
                ),
                child: Icon(icon,
                    size: 22,
                    color: selected ? Colors.white : AppColors.textSecondary),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.aurora : null,
                  color: selected ? null : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected
                      ? null
                      : Border.all(color: AppColors.strokeStrong, width: 1.6),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onboarding progress dots — filled = done/current, outline = upcoming.
/// Current dot stretches into an aurora pill.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(left: 5),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: active || done
                ? AppColors.aurora
                : const LinearGradient(
                    colors: [AppColors.strokeStrong, AppColors.strokeStrong]),
            borderRadius: BorderRadius.circular(AppDimens.rPill),
          ),
        );
      }),
    );
  }
}

/// 6-box OTP display driven by a controller.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        final filled = i < code.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 46,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.rSm + 2),
            border: Border.all(
              color: filled ? AppColors.auroraSky : AppColors.strokeStrong,
              width: filled ? 2 : 1.2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppColors.auroraSky.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            filled ? code[i] : '',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }),
    );
  }
}

/// Profile stat tile.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.rTile),
          border: Border.all(color: AppColors.stroke.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
