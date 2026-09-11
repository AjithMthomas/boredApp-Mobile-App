import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../widgets/common.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Create')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.xl),
          children: [
            const Text(
              'What are you posting?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppDimens.sm),
            const Text(
              'Pick the closest type — everything else is guided.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.xl),

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
                selected: false,
                onTap: () => context.push('/create/wizard?type=${t.name}'),
              ),
              const SizedBox(height: AppDimens.md),
            ],

            const SizedBox(height: AppDimens.md),
            const SoftCard(
              color: AppColors.mintFaint,
              borderColor: AppColors.mintSoft,
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: AppColors.success),
                  SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(
                      'Type naturally — AI structuring ("Nandi Hills trip, I\'ll cover petrol" → structured draft) is a Stage-3 layer. Structure-first keeps safety checks reliable.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
