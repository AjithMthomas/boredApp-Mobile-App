import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? _reason;
  final _detailsCtrl = TextEditingController();
  bool _sent = false;

  static const _reasons = [
    (Icons.block_rounded, 'Prohibited activity', 'Illegal goods, substances, or services'),
    (Icons.money_off_rounded, 'Scam or fraud', 'Advance payment requests, fake profiles'),
    (Icons.child_care_rounded, 'Involves minors', 'Anyone under 18 involved or targeted'),
    (Icons.record_voice_over_rounded, 'Harassment or abuse', 'Threats, discrimination, intimidation'),
    (Icons.password_rounded, 'Credential request', 'Asking for OTP, PIN, passwords, banking'),
    (Icons.location_off_rounded, 'Unsafe meetup pressure', 'Insisting on isolated/private location'),
    (Icons.face_retouching_off_rounded, 'Impersonation', 'Pretending to be someone else'),
    (Icons.help_outline_rounded, 'Something else', 'Describe below'),
  ];

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final b = ref.read(storeProvider).backend;
    b.reportTask(widget.taskId, _reason ?? 'Other', _detailsCtrl.text.trim());
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Report sent'),
          leading: const UniformBackButton(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    gradient: AppColors.aurora,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded,
                      size: 42, color: Colors.white),
                ),
                const SizedBox(height: AppDimens.lg),
                const Text(
                  'Thank you for keeping Madiwala safe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppDimens.sm),
                const Text(
                  'Our safety team reviews reports within 24 hours. '
                  'Serious cases are escalated immediately. '
                  'If you are in danger right now, call 112.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                PrimaryButton(
                  label: 'Done',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Report'),
        leading: const UniformBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.xl),
        children: [
          const Text(
            'What\'s wrong?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppDimens.sm),
          const Text(
            'Reports go to moderation with context. False reports reduce your own reliability — report honestly.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          for (final (icon, label, sub) in _reasons) ...[
            ChoiceCard(
              icon: icon,
              iconGradient: AppColors.sunsetPop,
              title: label,
              subtitle: sub,
              selected: _reason == label,
              onTap: () => setState(() => _reason = label),
            ),
            const SizedBox(height: AppDimens.sm),
          ],
          const SizedBox(height: AppDimens.md),
          TextField(
            controller: _detailsCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Additional details (optional but helpful)',
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            label: 'Submit report',
            icon: Icons.flag_rounded,
            color: AppColors.danger,
            onPressed: _reason != null ? _submit : null,
          ),
        ],
      ),
    );
  }
}
