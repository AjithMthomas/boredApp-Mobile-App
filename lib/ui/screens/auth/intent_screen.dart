import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class IntentScreen extends ConsumerStatefulWidget {
  const IntentScreen({super.key});

  @override
  ConsumerState<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends ConsumerState<IntentScreen> {
  String _selected = 'both';
  bool _ageConfirmed = false;

  Future<void> _continue() async {
    if (!_ageConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please confirm you are 18 or older to continue.'),
        ),
      );
      return;
    }
    ref.read(storeProvider).backend.setSignupIntent(_selected);
    context.go('/auth/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.xl),
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo_icon.png',
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            const Text(
              'What do you want to do here?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.2),
            ),
            const SizedBox(height: AppDimens.sm),
            const Text(
              'You can change this anytime. Most members choose Both.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.xl),
            ChoiceCard(
              icon: Icons.waving_hand_rounded,
              title: 'I have free time',
              subtitle:
                  'Find nearby things to do, people to help, activities to join, ways to earn.',
              selected: _selected == 'haveTime',
              onTap: () => setState(() => _selected = 'haveTime'),
            ),
            const SizedBox(height: AppDimens.md),
            ChoiceCard(
              icon: Icons.handshake_rounded,
              iconGradient: AppColors.violetDream,
              title: 'I need something',
              subtitle:
                  'Find someone nearby who can help, accompany you, or spend time with you.',
              selected: _selected == 'needSomething',
              onTap: () => setState(() => _selected = 'needSomething'),
            ),
            const SizedBox(height: AppDimens.md),
            ChoiceCard(
              icon: Icons.sync_alt_rounded,
              iconGradient: AppColors.sunsetPop,
              title: 'Both',
              subtitle:
                  'Sometimes I need help. Sometimes I have time. (Recommended)',
              selected: _selected == 'both',
              onTap: () => setState(() => _selected = 'both'),
            ),
            const SizedBox(height: AppDimens.xl),
            // 18+ gate (policy + DPDP conscious; self-declared at MVP)
            Row(
              children: [
                Checkbox(
                  value: _ageConfirmed,
                  activeColor: AppColors.success,
                  onChanged: (v) => setState(() => _ageConfirmed = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I confirm I am 18 years or older.',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            PrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: _ageConfirmed ? _continue : null,
            ),
          ],
        ),
      ),
    );
  }
}
