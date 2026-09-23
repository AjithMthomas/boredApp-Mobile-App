import 'package:flutter/material.dart';

/// Phase 8 — pre-publication content moderation.
/// Keyword screen + auto-quarantine flag. Server-side AI filtering in
/// Stage 2 replaces the local list; interface stays the same.
abstract final class Moderation {
  /// Words that trigger automatic quarantine (hard block).
  static const _hard = [
    'escort', 'douche', 'nude', 'nudes', 'naked', 'porn', 'sex ',
    'sexy', 'hookup', 'one night', 'weed', 'ganja', 'md ', 'mdma',
    'cocaine', 'meth',
  ];

  /// Milder words that flag for review but do not block.
  static const _soft = [
    'massages', 'full body', 'private party', 'alone at home',
    'wife not', 'parents not', 'cash only no questions',
  ];

  /// Leetspeak / spacing evasions folded before matching.
  static String _normalize(String input) {
    var s = input.toLowerCase();
    const map = {'0': 'o', '1': 'i', '8': 'b', '5': 's', '3': 'e', '4': 'a'};
    s = s.replaceAllMapped(
      RegExp(r'[018534]'),
      (m) => map[m[0]] ?? m[0]!,
    );
    s = s.replaceAll(RegExp(r'[^a-z ]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  /// Returns null when clean, else a user-facing reason string.
  static String? screen(String title, String description) {
    final text = _normalize('$title $description');
    for (final w in _hard) {
      if (text.contains(w.trim())) {
        return 'This post conflicts with community safety rules. '
            'Remove inappropriate wording to publish.';
      }
    }
    for (final w in _soft) {
      if (text.contains(w)) {
        return 'This wording may be misread. Please rephrase before publishing.';
      }
    }
    return null;
  }

  /// Snack-bar helper for a blocked post.
  static void showBlocked(BuildContext context, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF101323),
        content: Row(
          children: [
            const Icon(Icons.gpp_bad_rounded, color: Color(0xFFF43F5E)),
            const SizedBox(width: 12),
            Expanded(child: Text(reason)),
          ],
        ),
      ),
    );
  }
}
