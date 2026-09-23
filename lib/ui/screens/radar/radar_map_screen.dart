import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/haptics.dart';
import '../../widgets/common.dart';

/// Bored Radar — the live neighbourhood map.
///
/// Privacy-preserving by design (per the product plan): people are shown
/// as soft density circles over ~500 m zone clusters, never as individual
/// pins. Tapping a zone opens its pulse sheet (counts + quick actions).
/// Counts are seed-driven until the Stage 2 socket feed lands.

class _RadarZone {
  const _RadarZone({
    required this.zone,
    required this.center,
    required this.free,
    required this.tasks,
    required this.tea,
    required this.spot,
  });

  final String zone;
  final LatLng center;
  final int free;
  final int tasks;
  final int tea;
  final String spot;

  /// Radius in metres, scaled with crowd size (clamped 180–320 m).
  double get radiusM => (180 + free * 6).clamp(180.0, 320.0).toDouble();

  /// Intensity 0–1 drives the heat colour.
  double get intensity => (free / 22).clamp(0.0, 1.0);
}

const List<_RadarZone> _kZones = [
  _RadarZone(
    zone: 'Jyoti Nivas Lane',
    center: LatLng(12.9352, 77.6245),
    free: 18, tasks: 5, tea: 7,
    spot: 'Jyoti Nivas College gate',
  ),
  _RadarZone(
    zone: '5th Block',
    center: LatLng(12.9407, 77.6208),
    free: 11, tasks: 3, tea: 4,
    spot: '5th Block park bench row',
  ),
  _RadarZone(
    zone: 'Madiwala Market',
    center: LatLng(12.9290, 77.6199),
    free: 9, tasks: 6, tea: 2,
    spot: 'Market main entrance',
  ),
  _RadarZone(
    zone: 'BTM Border',
    center: LatLng(12.9265, 77.6128),
    free: 14, tasks: 2, tea: 8,
    spot: 'BTM 16th main tea stall',
  ),
];

Color _heatColor(double t) => Color.lerp(
      AppColors.auroraSky.withValues(alpha: 0.30),
      AppColors.auroraMint.withValues(alpha: 0.55),
      t,
    )!;

class RadarMapScreen extends ConsumerStatefulWidget {
  const RadarMapScreen({super.key});

  @override
  ConsumerState<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends ConsumerState<RadarMapScreen> {
  _RadarZone? _selected;

  @override
  Widget build(BuildContext context) {
    final totalFree = _kZones.fold<int>(0, (s, z) => s + z.free);
    final totalTasks = _kZones.fold<int>(0, (s, z) => s + z.tasks);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Bored Radar'),
        leading: const UniformBackButton(),
        actions: [
          if (_selected != null)
            IconButton(
              onPressed: () => setState(() => _selected = null),
              tooltip: 'Clear selection',
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── The map ─────────────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(12.9335, 77.6195),
              initialZoom: 14.4,
              minZoom: 12,
              maxZoom: 17,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, _) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nuvra.app',
              ),
              // Privacy-blurred density circles — one per zone.
              CircleLayer(
                circles: [
                  for (final z in _kZones) ...[
                    // Soft halo.
                    CircleMarker(
                      point: z.center,
                      radius: z.radiusM,
                      useRadiusInMeter: true,
                      color: _heatColor(z.intensity).withValues(alpha: 0.30),
                      borderColor: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
                    // Core blob.
                    CircleMarker(
                      point: z.center,
                      radius: z.radiusM * 0.55,
                      useRadiusInMeter: true,
                      color: _heatColor(z.intensity),
                      borderColor: Colors.white.withValues(alpha: 0.85),
                      borderStrokeWidth: 1.4,
                    ),
                  ],
                ],
              ),
              // Count labels pinned at zone centers.
              MarkerLayer(
                markers: [
                  for (final z in _kZones)
                    Marker(
                      point: z.center,
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () {
                          Haptics.select();
                          setState(() => _selected = z);
                        },
                        child: Center(
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _selected?.zone == z.zone
                                  ? AppColors.ink
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selected?.zone == z.zone
                                    ? Colors.white
                                    : AppColors.strokeStrong,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${z.free}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: _selected?.zone == z.zone
                                      ? Colors.white
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap',
                    onTap: () {},
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          // ── Live pulse summary chip (top) ────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.92),
                    borderRadius:
                        BorderRadius.circular(AppDimens.rPill),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.auroraMint,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.3, 1.3),
                            duration: 1100.ms,
                            curve: Curves.easeInOut,
                          ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE · $totalFree people free · $totalTasks open tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── Zone detail sheet (bottom) ──────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _ZoneSheet(
              zone: _selected,
              onJoin: (z) {
                Haptics.light();
                context.push('/discover');
              },
              onOfferTea: (z) {
                Haptics.light();
                context.push('/create/wizard?type=offer');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom detail card — empty state, or the selected zone's pulse with
/// quick actions (browse its area / offer a treat there).
class _ZoneSheet extends StatelessWidget {
  const _ZoneSheet({
    required this.zone,
    required this.onJoin,
    required this.onOfferTea,
  });

  final _RadarZone? zone;
  final ValueChanged<_RadarZone> onJoin;
  final ValueChanged<_RadarZone> onOfferTea;

  @override
  Widget build(BuildContext context) {
    final z = zone;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.rTile),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101323),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: z == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.radar_rounded,
                        size: 18, color: AppColors.auroraSky),
                    SizedBox(width: 8),
                    Text(
                      'Who is bored around you?',
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Circles show clusters of free members — bigger and greener means more company nearby. '
                  'Zones are blurred to ~500 m; nobody\'s exact location is ever shown. Tap a count to open its pulse.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius:
                            BorderRadius.circular(AppDimens.rSm + 2),
                      ),
                      child: const Icon(Icons.radar_rounded,
                          size: 22, color: AppColors.success),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            z.zone,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Near ${z.spot} · ~500 m blur',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  children: [
                    Expanded(
                      child: _PulseStat(
                          value: '${z.free}', label: 'free now'),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: _PulseStat(
                          value: '${z.tasks}', label: 'open tasks'),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: _PulseStat(
                          value: '${z.tea}', label: 'up for tea'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Browse posts',
                        icon: Icons.explore_rounded,
                        expanded: true,
                        onPressed: () => onJoin(z),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Treat here',
                        icon: Icons.emoji_food_beverage_rounded,
                        expanded: true,
                        color: AppColors.auroraAmber,
                        onPressed: () => onOfferTea(z),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Compact stat tile used inside the zone sheet.
class _PulseStat extends StatelessWidget {
  const _PulseStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppDimens.rSm + 2),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
