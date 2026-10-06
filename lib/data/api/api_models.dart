// Small view-model helpers for the API layer: icon + gradient mapping
// from server icon names (no emojis in UI — icon-driven design, §6.4).
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Map a server icon name to a Material icon (perks, challenges).
IconData iconFor(String name) => switch (name) {
      'local_cafe' => Icons.local_cafe_rounded,
      'restaurant' => Icons.restaurant_rounded,
      'icecream' => Icons.icecream_rounded,
      'pedal_bike' => Icons.pedal_bike_rounded,
      'touch_app' => Icons.touch_app_rounded,
      'psychology' => Icons.psychology_rounded,
      'storefront' => Icons.storefront_rounded,
      'luggage' => Icons.luggage_rounded,
      'night_shelter' => Icons.night_shelter_rounded,
      'emergency' => Icons.emergency_share_rounded,
      _ => Icons.star_rounded,
    };

/// Deterministic aurora gradient per icon name (visual variety without
/// storing colors server-side).
List<Color> gradientFor(String name) => switch (name) {
      'local_cafe' => [AppColors.auroraAmber, AppColors.auroraCoral],
      'restaurant' => [AppColors.auroraCoral, AppColors.auroraViolet],
      'icecream' => [AppColors.auroraSky, AppColors.auroraMint],
      'pedal_bike' => [AppColors.auroraViolet, AppColors.auroraLilac],
      'touch_app' => [AppColors.auroraMint, AppColors.auroraSky],
      'psychology' => [AppColors.auroraViolet, AppColors.auroraLilac],
      _ => [AppColors.auroraSky, AppColors.auroraViolet],
    };
