import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  int _stars = 5;
  final _noteCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final b = ref.read(storeProvider).backend;
    b.submitRating(
      widget.taskId,
      _stars.toDouble(),
      _noteCtrl.text.trim(),
    );
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(storeProvider).backend;
    final task = b.taskById(widget.taskId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Complete')),
      body: SafeArea(
        child: _submitted
            ? _done(context)
            : ListView(
                padding: const EdgeInsets.all(AppDimens.xl),
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.successSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.celebration_rounded,
                          size: 40, color: AppColors.success),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  const Center(
                    child: Text(
                      'Activity completed!',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Center(
                    child: Text(
                      task != null
                          ? '"${task.title}" is done. How did it go?'
                          : 'How did it go?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Star rating
                  SoftCard(
                    child: Column(
                      children: [
                        const Text(
                          'Your rating',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: AppDimens.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final filled = i < _stars;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _stars = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: Icon(
                                  filled
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 38,
                                  color: filled
                                      ? AppColors.warning
                                      : AppColors.strokeStrong,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          switch (_stars) {
                            1 => 'Not great',
                            2 => 'Below expectations',
                            3 => 'Okay',
                            4 => 'Good',
                            _ => 'Excellent!',
                          },
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      hintText:
                          'Public note (optional) — shown on their profile',
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  PrimaryButton(
                    label: 'Submit rating',
                    icon: Icons.star_rounded,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  const Center(
                    child: Text(
                      'Ratings are mutual, post-completion only, and can\'t be deleted — honest feedback keeps the market healthy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textFaint,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _done(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🙏', style: TextStyle(fontSize: 52)),
            const SizedBox(height: AppDimens.lg),
            const Text(
              'Thanks for the rating!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppDimens.sm),
            const Text(
              'Reputation grows from real interactions like this one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            PrimaryButton(
              label: 'Back to home',
              icon: Icons.home_rounded,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
