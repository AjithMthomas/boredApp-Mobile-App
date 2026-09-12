import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/task_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final b = store.backend;
    final feed = b.feed;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: AppDimens.lg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'Discover',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => _openFilters(context, ref),
                icon: const Icon(Icons.tune_rounded),
              ),
              if (b.hasActiveFilters)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 4.5,
                    backgroundColor: AppColors.coral,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Radius / source switch ───────────────────────────────
          Padding(
            padding:
                const EdgeInsets.fromLTRB(AppDimens.lg, 4, AppDimens.lg, 0),
            child: Row(
              children: [
                _sourceChip(context, ref, 'nearby', 'Nearby (${b.radiusKm.round()} km)'),
                const SizedBox(width: AppDimens.sm),
                _sourceChip(context, ref, 'myCity', 'All Madiwala'),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),

          // ── Search ──────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            child: TextField(
              onChanged: b.setQuery,
              decoration: const InputDecoration(
                hintText: 'Search tasks, activities…',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sm),

          // ── Category chips ──────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.lg),
              children: b.categories
                  .map((c) => Padding(
                        padding:
                            const EdgeInsets.only(right: AppDimens.sm),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: b.filterCategory == c,
                          onSelected: (_) => b.setCategory(c),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.ink,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: b.filterCategory == c
                                ? AppColors.textOnInk
                                : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: b.filterCategory == c
                                ? AppColors.ink
                                : AppColors.stroke,
                          ),
                          showCheckmark: false,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppDimens.sm),

          // ── Feed list ───────────────────────────────────────────
          Expanded(
            child: feed.isEmpty
                ? EmptyState(
                    icon: Icons.search_rounded,
                    title: 'No matches nearby',
                    message:
                        'Try widening the radius, clearing filters, or creating the first post of its kind.',
                    actions: [
                      GhostButton(
                        label: 'Clear filters',
                        onPressed: b.hasActiveFilters ? b.clearFilters : null,
                      ),
                      PrimaryButton(
                        label: 'Create a post',
                        icon: Icons.add_rounded,
                        expanded: false,
                        onPressed: () => context.push('/create'),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg, AppDimens.sm, AppDimens.lg, 110),
                    itemCount: feed.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (context, i) {
                      final t = feed[i];
                      return TaskCard(
                        task: t,
                        saved: b.isSaved(t.id),
                        onSave: () => b.toggleSaved(t.id),
                        onTap: () => context.push('/task/${t.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sourceChip(
      BuildContext context, WidgetRef ref, String value, String label) {
    final b = ref.read(storeProvider).backend;
    final selected = b.feedSource == value;
    return GestureDetector(
      onTap: () => b.setFeedSource(value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color:
                selected ? AppColors.textOnInk : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _openFilters(BuildContext context, WidgetRef ref) {
    final b = ref.read(storeProvider).backend;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(b: b),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.b});

  final dynamic b;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimens.xl,
          right: AppDimens.xl,
          top: AppDimens.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppDimens.lg),

            const Text('Radius',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            Slider(
              value: b.radiusKm,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.ink,
              label: '${b.radiusKm.round()} km',
              onChanged: (v) {
                setState(() => b.setRadius(v));
              },
            ),

            const SizedBox(height: AppDimens.md),
            const Text('Post type',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: PostType.values.map((t) {
                final on = b.filterTypes.contains(t);
                return FilterChip(
                  label: Text(t.label),
                  selected: on,
                  onSelected: (_) {
                    setState(() => b.toggleTypeFilter(t));
                  },
                  selectedColor: AppColors.mintSoft,
                  checkmarkColor: AppColors.success,
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimens.md),
            const Text('Exchange',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: ExchangeMode.values.map((m) {
                final on = b.filterExchanges.contains(m);
                return FilterChip(
                  label: Text(m.label),
                  selected: on,
                  onSelected: (_) {
                    setState(() => b.toggleExchangeFilter(m));
                  },
                  selectedColor: AppColors.mintSoft,
                  checkmarkColor: AppColors.success,
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimens.md),
            const Text('Gender preference',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: GenderPreference.values.map((g) {
                final on = b.filterGenderPrefs.contains(g);
                return FilterChip(
                  avatar: Icon(g.icon,
                      size: 15,
                      color: on ? AppColors.ink : AppColors.textSecondary),
                  label: Text(g.label),
                  selected: on,
                  onSelected: (_) {
                    setState(() => b.toggleGenderFilter(g));
                  },
                  selectedColor: AppColors.mintSoft,
                  checkmarkColor: AppColors.success,
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimens.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Free & treats only',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              subtitle: const Text('Community activities with no money involved',
                  style: TextStyle(fontSize: 12)),
              value: b.filterFreeOnly,
              activeThumbColor: AppColors.success,
              onChanged: (v) {
                setState(() => b.setFreeOnly(v));
              },
            ),

            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Reset',
                    onPressed: () {
                      b.clearFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Show results',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
