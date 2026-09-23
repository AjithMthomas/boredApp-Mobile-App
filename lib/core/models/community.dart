import 'package:flutter/material.dart';

/// Phase 9 — Community board idea (submit + upvote; top ideas get
/// scheduled as official events).
class BoardIdea {
  const BoardIdea({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.title,
    required this.details,
    required this.tag,
    required this.upvotes,
    required this.createdAt,
    this.votedByMe = false,
    this.scheduled = false,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final String title;
  final String details;

  /// Short bucket: 'Meetup', 'Walk', 'Sports', 'Feature', 'Help'...
  final String tag;
  final int upvotes;
  final DateTime createdAt;
  final bool votedByMe;

  BoardIdea copyWithVoted({required bool voted, required int upvotes}) {
    return BoardIdea(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      title: title,
      details: details,
      tag: tag,
      upvotes: upvotes,
      createdAt: createdAt,
      votedByMe: voted,
      scheduled: scheduled,
    );
  }
  final bool scheduled;
}

/// Phase 7 — Partner merchant offer (cafes, shops) with a claimable
/// footfall voucher.
class PartnerPerk {
  const PartnerPerk({
    required this.id,
    required this.merchant,
    required this.title,
    required this.details,
    required this.emojiIcon,
    required this.costKarma,
    required this.area,
    required this.validHours,
    required this.gradient,
  });

  final String id;
  final String merchant;
  final String title;
  final String details;

  /// Material icon codepoint name (no emojis in UI — icon-driven).
  final IconData emojiIcon;
  final int costKarma;

  /// Karma cost to claim the voucher.
  final String area;
  final int validHours;
  final List<Color> gradient;
}

/// Phase 6 — Play & Earn casual challenge.
class PlayChallenge {
  const PlayChallenge({
    required this.id,
    required this.title,
    required this.rules,
    required this.target,
    required this.rewardKarma,
    required this.icon,
    required this.gradient,
  });

  final String id;
  final String title;
  final String rules;

  /// Target score to beat for the full reward.
  final int target;
  final int rewardKarma;
  final IconData icon;
  final List<Color> gradient;
}
