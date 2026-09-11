import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Auto-discovers banner assets under `assets/ads/` via the AssetManifest
/// (drop a PNG in the folder → it appears in the slideshow) and shows them
/// as an auto-advancing, swipeable, infinitely-wrapping carousel with a
/// pill-dash progress indicator.
class AdCarousel extends StatefulWidget {
  const AdCarousel({super.key, this.height = 150, this.onTapAd});

  final double height;

  /// Called with the asset path when a banner is tapped (deep-link
  /// target for real campaigns later).
  final ValueChanged<String>? onTapAd;

  static const _folder = 'assets/ads/';

  /// Loads banner asset paths from the asset manifest.
  static Future<List<String>> _discover() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest
          .listAssets()
          .where((a) => a.startsWith(_folder))
          .toList()
        ..sort();
      return assets;
    } catch (_) {
      return const [];
    }
  }

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  List<String> _banners = const [];
  PageController? _controller;
  Timer? _timer;

  static const _autoAdvance = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    AdCarousel._discover().then((banners) {
      if (!mounted) return;
      if (banners.isEmpty) return;
      setState(() {
        _banners = banners;
        // Start in the middle copy so the user can swipe backwards.
        _controller = PageController(initialPage: _banners.length * 200);
      });
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoAdvance, (_) {
      final c = _controller;
      if (c == null || !c.hasClients) return;
      final next = c.page!.round() + 1;
      c.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) return const SizedBox.shrink();
    final virtualCount = _banners.length * 400;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _timer?.cancel(),
          onTapUp: (_) => _startTimer(),
          onPanDown: (_) => _timer?.cancel(),
          onPanEnd: (_) => _startTimer(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.rCard),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14101323),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: PageView.builder(
                controller: _controller,
                itemCount: virtualCount,
                onPageChanged: (_) => setState(() {}),
                itemBuilder: (context, page) {
                  final i = page % _banners.length;
                  return Image.asset(
                    _banners[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Pill-dash indicator — active banner stretches.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final c = _controller;
            final page = c != null && c.hasClients
                ? (c.page ?? 0).round()
                : _banners.length * 200;
            final active = i == page % _banners.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                gradient: active
                    ? AppColors.aurora
                    : const LinearGradient(colors: [
                        AppColors.strokeStrong,
                        AppColors.strokeStrong,
                      ]),
                borderRadius: BorderRadius.circular(AppDimens.rPill),
              ),
            );
          }),
        ),
      ],
    );
  }
}
