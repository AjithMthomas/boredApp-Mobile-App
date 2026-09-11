import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

/// Step 1 of 3 — email entry. Aurora ambient wash, display heading,
/// elevated field, aurora CTA.
class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _emailCtrl = TextEditingController();
  String? _error;
  bool _busy = false;

  bool get _isValid {
    final e = _emailCtrl.text.trim();
    return e.contains('@') && e.contains('.') && e.length > 5;
  }

  Future<void> _sendOtp() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final b = ref.read(storeProvider).backend;
    b.requestOtp(_emailCtrl.text.trim());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    unawaited(context.push('/auth/otp'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // ── Ambient aurora wash (matches home) ────────────────────
          Positioned(
            top: -160,
            left: -80,
            right: -80,
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.xl, AppDimens.lg, AppDimens.xl, AppDimens.xl),
              children: [
                // ── Top: brand mark + step dots ─────────────────────
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.aurora,
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 19),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TIME~NEED',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const StepDots(current: 0, total: 3),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppDimens.huge),

                // ── Heading ─────────────────────────────────────────
                const Text(
                  'What\'s your\nemail?',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    height: 1.08,
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.25,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.md),
                const Text(
                  'We\'ll send a 6-digit code. No password to remember, no phone number needed.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ).animate(delay: 160.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimens.xxl),

                // ── Elevated email field ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.rField + 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12101323),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: const Icon(Icons.alternate_email_rounded,
                          size: 21, color: AppColors.textFaint),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.rField + 2),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ).animate(delay: 240.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                if (_error != null) ...[
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn().shakeX(),
                ],
                const SizedBox(height: AppDimens.lg),
                PrimaryButton(
                  label: 'Send Code',
                  icon: Icons.arrow_forward_rounded,
                  loading: _busy,
                  onPressed: _isValid ? _sendOtp : null,
                ).animate(delay: 320.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppDimens.xl),

                // ── 18+ notice — elevated mint card with icon tile ──
                SoftCard(
                  color: AppColors.mintFaint,
                  borderColor: AppColors.mintSoft,
                  radius: AppDimens.rTile,
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.aurora,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.verified_user_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: AppDimens.md),
                      const Expanded(
                        child: Text(
                          '18+ only. You confirm you are an adult. '
                          'Minor accounts are suspended on report pending age review.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
