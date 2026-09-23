import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Member avatar: real photo when available, otherwise a deterministic
/// gradient with white initials (derived from the name — stable identity
/// colour across the app). Optional online dot + soft glow ring.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 44,
    this.showBorder = true,
    this.gradient,
    this.online = false,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final bool showBorder;
  final Gradient? gradient;
  final bool online;

  static const _palette = [
    [Color(0xFF5EEAD4), Color(0xFF60A5FA)], // mint → sky
    [Color(0xFF8B5CF6), Color(0xFFC4B5FD)], // violet → lilac
    [Color(0xFFFB7185), Color(0xFFFBBF24)], // coral → amber
    [Color(0xFF34D399), Color(0xFFA7F3D0)], // emerald
    [Color(0xFFF472B6), Color(0xFFC084FC)], // pink → purple
    [Color(0xFF60A5FA), Color(0xFF818CF8)], // blue → indigo
    [Color(0xFFFBBF24), Color(0xFFFB923C)], // amber → orange
    [Color(0xFF2DD4BF), Color(0xFF34D399)], // teal → emerald
  ];

  /// The 10 bundled avatars — used whenever a member has no photo, so
  /// cards never show a blank/initials-only face. Assignment is derived
  /// from the name hash: the same person always gets the same avatar.
  static const _bundledAvatars = [
    'assets/avatars/1.jpg',
    'assets/avatars/2.jpg',
    'assets/avatars/3.jpg',
    'assets/avatars/4.jpg',
    'assets/avatars/5.jpg',
    'assets/avatars/6.jpg',
    'assets/avatars/7.jpg',
    'assets/avatars/8.jpg',
    'assets/avatars/9.jpg',
    'assets/avatars/10.jpg',
  ];

  static String avatarFor(String name) {
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = (hash * 31 + code) & 0x7FFFFFFF;
    }
    return _bundledAvatars[hash % _bundledAvatars.length];
  }

  static Gradient gradientFor(String name) {
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = (hash * 31 + code) & 0x7FFFFFFF;
    }
    final pair = _palette[hash % _palette.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: pair,
    );
  }

  bool get _hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ring = showBorder
        ? Border.all(color: Colors.white, width: 2.5)
        : null;

    Widget inner;
    if (_hasPhoto) {
      if (photoUrl!.startsWith('assets/')) {
        inner = ClipOval(
          child: Image.asset(
            photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } else {
        inner = ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 250),
            placeholder: (_, _) => _fallback(),
            errorWidget: (_, _, _) => _fallback(),
          ),
        );
      }
    } else {
      inner = _fallback();
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ring,
        boxShadow: [
          BoxShadow(
            color: AppColors.glow,
            blurRadius: size * 0.35,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: inner,
    );

    if (!online) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    // Real bundled avatar face, deterministic per member — never blank.
    return ClipOval(
      child: Image.asset(
        avatarFor(name),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(
            gradient: gradient ?? gradientFor(name),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded-square photo tile used for task-type headers where a
/// member photo would repeat (kept for future use).
class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.photoUrl,
    this.size = 48,
    this.radius = AppDimens.rSm,
  });

  final String photoUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColors.surfaceMuted),
        errorWidget: (_, _, _) => Container(color: AppColors.surfaceMuted),
      ),
    );
  }
}
