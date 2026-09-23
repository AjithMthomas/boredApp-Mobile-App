import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

/// Step 2 of 3 — OTP entry. Aurora ambient wash, big OTP boxes with
/// glow, pulsing resend row, demo hint as a quiet inline pill.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focus = FocusNode();
  String _code = '';
  String? _error;
  bool _busy = false;
  int _resendIn = 30;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendIn > 0) setState(() => _resendIn -= 1);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _otpCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    final clamped = digits.length > 6 ? digits.substring(0, 6) : digits;
    setState(() {
      _code = clamped;
      _error = null;
    });
    _otpCtrl.value = TextEditingValue(
      text: clamped,
      selection: TextSelection.collapsed(offset: clamped.length),
    );
    if (clamped.length == 6) _verify();
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final b = ref.read(storeProvider).backend;
    final ok = b.verifyOtp(_code);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (ok) {
      Haptics.confirm();
      // Router redirect sends to /auth/intent (profile incomplete).
      context.go('/auth/intent');
    } else {
      setState(() {
        _busy = false;
        _error = 'Wrong code — check and try again.';
      });
      Haptics.select();
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final email = b.pendingEmail ?? 'your email';

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
                    AppColors.auroraSky.withValues(alpha: 0.16),
                    AppColors.auroraViolet.withValues(alpha: 0.09),
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
                    const StepDots(current: 1, total: 3),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppDimens.huge),

                // ── Heading with the email highlighted ──────────────
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.12,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Code sent to\n'),
                      TextSpan(
                        text: email,
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                AppColors.auroraSky,
                                AppColors.auroraViolet,
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0, 0, 320, 40),
                            ),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.25,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.sm),
                const Text(
                  'Enter the 6 digits. Valid for 10 minutes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimens.xxl),

                // ── OTP boxes (hidden real input + visual boxes) ────
                Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _otpCtrl,
                        focusNode: _focus,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autofocus: true,
                        onChanged: _onChanged,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _focus.requestFocus(),
                      child: OtpBoxes(controller: _otpCtrl, onChanged: () {}),
                    ),
                  ],
                ).animate(delay: 240.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                if (_error != null) ...[
                  const SizedBox(height: AppDimens.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn().shakeX(),
                ],
                const SizedBox(height: AppDimens.lg),

                // ── Resend row — pulses when ready ──────────────────
                Center(
                  child: _resendIn > 0
                      ? Text(
                          'Resend in $_resendIn s',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            b.requestOtp(b.pendingEmail ?? '');
                            setState(() => _resendIn = 30);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.aurora,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.rPill),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.auroraMint
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Resend code',
                              style: TextStyle(
                                color: AppColors.textOnAurora,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.05, 1.05),
                                duration: 900.ms,
                                curve: Curves.easeInOut,
                              ),
                        ),
                ).animate(delay: 320.ms).fadeIn(),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: AppDimens.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // ── Demo hint — quiet inline pill ───────────────────
                const SizedBox(height: AppDimens.xxl),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.butterSoft,
                      borderRadius: BorderRadius.circular(AppDimens.rPill),
                      border: Border.all(
                          color: AppColors.butter.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bug_report_rounded,
                            size: 14, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text(
                          'Demo OTP: 424242',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Real email delivery lands in Stage 2 (Django backend).',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textFaint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate(delay: 430.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Circular elevated icon button — retired: replaced by the shared
// [UniformBackButton] so every screen shares one back control.
