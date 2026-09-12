import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/haptics.dart';
import 'state/providers.dart';

/// Bump navigation (v7) — the traveling bump the user loved, with the
/// create button as a plain center tab (no arch, same style as tabs):
///  • Floating bar; a semicircular NOTCH is cut into its top edge and
///    TRAVELS to whichever tab is selected (path morph + glide).
///  • The circular gradient button nests in the traveling bump —
///    it shows the destination tab's icon while in transit.
///  • CREATE = plain white circle in the center slot (pushes /create).
///  • Selected tab also gets the colored fill + label.
///  • ALWAYS VISIBLE: the bar never hides — not on scroll, not ever.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    ('/home', Icons.home_rounded, Icons.home_outlined, 'Home'),
    ('/discover', Icons.explore_rounded, Icons.explore_outlined, 'Discover'),
    ('/activity', Icons.receipt_long_rounded, Icons.receipt_long_outlined,
        'Activity'),
    ('/messages', Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded,
        'Messages'),
  ];

  // ── Geometry ────────────────────────────────────────────────────
  static const _barHeight = 64.0;
  static const _notchRadius = 26.0; // notch radius (4px white ring gap)
  static const _tabRadius = 24.0; // tab button radius (traveling + create)
  static const _barMarginH = 18.0;
  static const _barMarginBottom = 18.0;
  static const _barRadius = 24.0;

  static double get _stackHeight =>
      _barHeight + _notchRadius * 2 + _barMarginBottom;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final unreadMessages = store.backend.totalUnreadRooms;
    final location = GoRouterState.of(context).matchedLocation;

    // NOTE: /create is a stack route OUTSIDE this shell, so within the
    // shell the location is always one of the four tab routes. activeIndex
    // therefore maps directly to _destinations; slot 2 (center) is only
    // used by the Create button, which pushes /create as a full screen.
    var activeIndex = 0;
    for (var i = 0; i < AppShell._destinations.length; i++) {
      if (location.startsWith(AppShell._destinations[i].$1)) {
        activeIndex = i;
        break;
      }
    }

    final barWidth =
        MediaQuery.sizeOf(context).width - AppShell._barMarginH * 2;
    final bumpX = _notchCenterX(activeIndex, barWidth);

    final travelingBumpIcon = AppShell._destinations[activeIndex].$2;
    final travelingBumpLabel = AppShell._destinations[activeIndex].$4;

    return Scaffold(
      // Body extends UNDER the floating bar — screens carry their own
      // bottom padding (110px) so content scrolls clear of the bar.
      extendBody: true,
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.012),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(location),
            child: widget.child,
          ),
        ),
      // Bar always visible. Fixed-height slot so the Scaffold reserves
      // exactly the bar's space and the body keeps the rest.
      bottomNavigationBar: SizedBox(
        height: AppShell._stackHeight,
        child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── The bar, clipped with the traveling notch ──────
              //   (create button is a plain tab — no notch of its own)
              Positioned(
                left: AppShell._barMarginH,
                right: AppShell._barMarginH,
                bottom: AppShell._barMarginBottom,
                child: ClipPath(
                  clipper: _NotchClipper(
                    centers: [bumpX], // traveling notch (active tab)
                    notchRadius: AppShell._notchRadius,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: AppShell._barHeight,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius:
                            BorderRadius.circular(AppShell._barRadius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A1B2A4A),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // ── Hairline stroke following bar + notch arc ──────
              Positioned(
                left: AppShell._barMarginH,
                right: AppShell._barMarginH,
                bottom: AppShell._barMarginBottom,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size(barWidth, AppShell._barHeight),
                    painter: _NotchBorderPainter(
                      centers: [bumpX],
                      notchRadius: AppShell._notchRadius,
                    ),
                  ),
                ),
              ),
              // ── Tabs (center slot = Create) ───────────────────
              Positioned(
                left: AppShell._barMarginH,
                right: AppShell._barMarginH,
                bottom: AppShell._barMarginBottom,
                child: SizedBox(
                  height: AppShell._barHeight,
                  child: Row(
                    children: [
                      _tab(context, 0, activeIndex, unreadMessages),
                      _tab(context, 1, activeIndex, unreadMessages),
                      _tab(context, 2, activeIndex, unreadMessages),
                      _tab(context, 3, activeIndex, unreadMessages),
                      _tab(context, 4, activeIndex, unreadMessages),
                    ],
                  ),
                ),
              ),
              // ── Traveling bump button ─────────────────────────
              // Lives in THIS full-height stack so its top half stays
              // inside hit-test bounds. Shows the destination icon.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic,
                left: AppShell._barMarginH + bumpX - AppShell._tabRadius,
                bottom: AppShell._barMarginBottom + AppShell._barHeight -
                    AppShell._tabRadius,
                child: _TravelingBump(
                  icon: travelingBumpIcon,
                  label: travelingBumpLabel,
                  radius: AppShell._tabRadius,
                ),
              ),
              // (create button is rendered by the center tab above)
            ],
          ),
        ),
    );
  }

  void _openCreate() {
    Haptics.select();
    context.go('/create');
  }

  /// X (within the bar) of the traveling notch for [activeIndex].
  /// Five slots: Home, Discover, [Create], Activity, Messages — the
  /// create button owns slot 2, so tabs past Discover shift right.
  static double _notchCenterX(int activeIndex, double barWidth) {
    final slot = barWidth / 5;
    final displaySlot = activeIndex < 2 ? activeIndex : activeIndex + 1;
    return slot * displaySlot + slot / 2;
  }

  Widget _tab(
    BuildContext context,
    int index,
    int activeIndex,
    int unreadMessages,
  ) {
    final isCreate = index == 2;
    if (isCreate) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Haptics.select();
            _openCreate();
          },
          child: Tooltip(
            message: 'Create a post',
            preferBelow: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppShell._tabRadius * 2,
                    height: AppShell._tabRadius * 2,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x595EEAD4),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3.5),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 22,
                      color: AppColors.auroraSky,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final realIndex = index < 2 ? index : index - 1;
    final (route, iconFull, iconOut, label) = AppShell._destinations[realIndex];
    final selected = realIndex == activeIndex;
    final unread = route == '/messages' ? unreadMessages : 0;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!selected) {
            Haptics.select();
            context.go(route);
          }
        },
        child: Tooltip(
          message: label,
          preferBelow: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Selected tab's icon fades out — the traveling bump
                // carries the elevated icon for the active tab.
                AnimatedOpacity(
                  opacity: selected ? 0 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        selected ? iconFull : iconOut,
                        size: 23,
                        color: selected
                            ? AppColors.auroraSky
                            : AppColors.textFaint,
                      ),
                      if (unread > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              gradient: AppColors.sunsetPop,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                fontSize: 8.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color:
                        selected ? AppColors.auroraSky : AppColors.textFaint,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The traveling bump's nested button: white ring + aurora core showing
/// the active tab's icon. Tappable so the bump is never a dead zone.
class _TravelingBump extends StatelessWidget {
  const _TravelingBump({
    required this.icon,
    required this.label,
    required this.radius,
  });

  final IconData icon;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.select();
      },
      child: Tooltip(
        message: label,
        preferBelow: false,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x595EEAD4),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.aurora,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

/// Clips the bar so semicircular notches are cut out of its top edge
/// at each center. Clip radius is slightly smaller than the painter's
/// so the white stroke stays fully visible.
class _NotchClipper extends CustomClipper<Path> {
  _NotchClipper({required this.centers, required this.notchRadius});

  final List<double> centers;
  final double notchRadius;

  @override
  Path getClip(Size size) => _barPath(size, centers, notchRadius - 1.5);

  @override
  bool shouldReclip(_NotchClipper old) =>
      old.notchRadius != notchRadius ||
      !listEquals(old.centers, centers);
}

/// Rounded-rect bar path with semicircular bites removed from the top
/// edge. Shared by clipper and border painter.
Path _barPath(Size size, List<double> centers, double notchRadius) {
  final path = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(24),
      ),
    );

  var bite = Path();
  for (final c in centers) {
    bite = Path.combine(
      PathOperation.union,
      bite,
      Path()
        ..addOval(Rect.fromCircle(center: Offset(c, 0), radius: notchRadius)),
    );
  }

  return Path.combine(PathOperation.difference, path, bite);
}

/// Draws the bar's hairline border *around* both notches so the cut
/// edges read as part of the design, plus a soft shadow for depth.
class _NotchBorderPainter extends CustomPainter {
  _NotchBorderPainter({required this.centers, required this.notchRadius});

  final List<double> centers;
  final double notchRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _barPath(size, centers, notchRadius);

    // Soft drop shadow under the whole silhouette (incl. bump arcs).
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0x141B2A4A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Crisp white hairline around bar + notches.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_NotchBorderPainter old) =>
      old.notchRadius != notchRadius ||
      !listEquals(old.centers, centers);
}
