import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/haptics.dart';
import 'state/providers.dart';

/// Bump navigation (v6) — the v4 traveling bump the user loved, plus
/// the create button restored:
///  • Floating bar; a semicircular NOTCH is cut into its top edge and
///    TRAVELS to whichever tab is selected (path morph + glide).
///  • The circular gradient button nests in the traveling bump —
///    it shows the destination tab's icon while in transit.
///  • CREATE = a docked aurora orb at the bottom-center, nested in
///    its own static center notch (like the reference's purple orb).
///  • Selected tab also gets the gradient bar + colored fill + label.
///  • Scroll-aware: bar slides away on scroll down, returns on any
///    scroll up; always visible on first paint and after tab switches.
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
  static const _bumpRadius = 26.0; // traveling button radius
  static const _notchRadius = 30.0; // notch radius (4px white ring gap)
  static const _orbRadius = 27.0; // create orb radius
  static const _barMarginH = 18.0;
  static const _barMarginBottom = 18.0;
  static const _barRadius = 24.0;

  static double get _stackHeight =>
      _barHeight + _bumpRadius * 2 + _barMarginBottom;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _barVisible = true;
  String? _lastLocation;

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final unreadMessages = store.backend.totalUnreadRooms;
    final location = GoRouterState.of(context).matchedLocation;

    var activeIndex = 0;
    for (var i = 0; i < AppShell._destinations.length; i++) {
      if (location.startsWith(AppShell._destinations[i].$1)) activeIndex = i;
    }

    // Tab switches always bring the bar back.
    if (_lastLocation != null && location != _lastLocation && !_barVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _barVisible = true);
      });
    }
    _lastLocation = location;

    final barWidth =
        MediaQuery.sizeOf(context).width - AppShell._barMarginH * 2;
    final bumpX = _notchCenterX(activeIndex, barWidth);

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.direction == ScrollDirection.forward) {
            if (_barVisible) setState(() => _barVisible = false);
          } else if (n.direction == ScrollDirection.reverse) {
            if (!_barVisible) setState(() => _barVisible = true);
          }
          return false;
        },
        child: AnimatedSwitcher(
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
      ),
      // Collapses to zero height when hidden; OverflowBox keeps the bar
      // at natural size anchored bottom so it slides away under the clip.
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        height: _barVisible ? AppShell._stackHeight : 0,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: AppShell._stackHeight,
          maxHeight: AppShell._stackHeight,
          child: SizedBox(
            height: AppShell._stackHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── The bar, clipped with TWO notches ─────────────
                //   center = static (create orb) · traveling = active tab
                Positioned(
                  left: AppShell._barMarginH,
                  right: AppShell._barMarginH,
                  bottom: AppShell._barMarginBottom,
                  child: ClipPath(
                    clipper: _NotchClipper(
                      centers: [
                        barWidth / 2, // create notch (static)
                        bumpX, // traveling notch (active tab)
                      ],
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
                // ── Hairline stroke following bar + both notch arcs ─
                Positioned(
                  left: AppShell._barMarginH,
                  right: AppShell._barMarginH,
                  bottom: AppShell._barMarginBottom,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size(barWidth, AppShell._barHeight),
                      painter: _NotchBorderPainter(
                        centers: [barWidth / 2, bumpX],
                        notchRadius: AppShell._notchRadius,
                      ),
                    ),
                  ),
                ),
                // ── Tabs (center slot empty — the orb lives there) ──
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
                        const Expanded(child: SizedBox()),
                        _tab(context, 2, activeIndex, unreadMessages),
                        _tab(context, 3, activeIndex, unreadMessages),
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
                  left: AppShell._barMarginH + bumpX - AppShell._bumpRadius,
                  bottom: AppShell._barMarginBottom + AppShell._barHeight -
                      AppShell._bumpRadius,
                  child: _TravelingBump(
                    route: AppShell._destinations[activeIndex].$1,
                    icon: AppShell._destinations[activeIndex].$2,
                    label: AppShell._destinations[activeIndex].$4,
                    radius: AppShell._bumpRadius,
                  ),
                ),
                // ── Create orb — sits on the bar, plain, no arch ─────
                // Bottom-anchored so the bar looks clean; no outer
                // arc protruding above the bar edge.
                Positioned(
                  left: AppShell._barMarginH + barWidth / 2 -
                      AppShell._orbRadius,
                  bottom: AppShell._barMarginBottom,
                  child: _CreateOrb(
                    radius: AppShell._orbRadius,
                    onTap: _openCreate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCreate() {
    Haptics.confirm();
    context.push('/create');
  }

  /// X (within the bar) of slot [activeIndex]'s center. Four tab slots
  /// span the full bar width; the center orb floats above, not in a slot.
  static double _notchCenterX(int activeIndex, double barWidth) {
    final slot = barWidth / AppShell._destinations.length;
    return slot * activeIndex + slot / 2;
  }

  Widget _tab(
    BuildContext context,
    int index,
    int activeIndex,
    int unreadMessages,
  ) {
    final (route, iconFull, iconOut, label) = AppShell._destinations[index];
    final selected = index == activeIndex;
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
                // Active icon hides — the traveling bump shows it.
                // Active badge hides too (the bump carries the state).
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: selected ? 0 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        iconOut,
                        size: 23,
                        color: AppColors.textFaint,
                      ),
                    ),
                    if (unread > 0 && !selected)
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
/// the active tab's icon. Tappable so the bump is never a dead zone
/// (navigating to its own route is a no-op when already there).
class _TravelingBump extends StatelessWidget {
  const _TravelingBump({
    required this.route,
    required this.icon,
    required this.label,
    required this.radius,
  });

  final String route;
  final IconData icon;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.select();
        context.go(route);
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
          padding: const EdgeInsets.all(3.5), // white ring
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

/// The docked CREATE orb — aurora gradient, white ring, glow. Sits on
/// the bar's bottom edge, nested in the static center notch.
class _CreateOrb extends StatelessWidget {
  const _CreateOrb({required this.radius, required this.onTap});

  final double radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: 'Create a post',
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
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4), // white ring
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.aurora,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

extension _StackOnOffset on Stack {
  /// Identical to [Stack.children] — only here to keep the nested
  /// [Positioned] below the notch clip visible (its top half sticks
  /// out above the bar). Already included via this file's existing
  /// [Stack] declaration; no behavioral change.
  List<Widget> get _noOP => children ?? const [];
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
