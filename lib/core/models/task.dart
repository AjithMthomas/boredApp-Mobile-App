import 'enums.dart';

/// A marketplace post (Task / Company / Offer).
class Task {
  const Task({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhotoUrl,
    required this.creatorVerified,
    required this.creatorRating,
    required this.creatorCompleted,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.area,
    required this.distanceKm,
    required this.exchange,
    required this.rewardAmount,
    required this.capacity,
    required this.applicantCount,
    required this.genderPreference,
    required this.risk,
    required this.status,
    required this.createdAt,
    required this.meetingPreference,
    required this.hasCheckin,
  });

  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl; // '' → gradient-initials fallback
  final bool creatorVerified;
  final double creatorRating;
  final int creatorCompleted;

  final PostType type;
  final String title;
  final String description;
  final String category;
  final DateTime scheduledAt;
  final int durationMinutes;

  final String area;
  final double distanceKm;

  final ExchangeMode exchange;
  final double rewardAmount; // 0 for free/treat

  final int capacity;
  final int applicantCount;

  /// Creator-set restriction (girls-only / boys-only) — safety feature.
  final GenderPreference genderPreference;

  final TaskRisk risk;
  final TaskStatus status;
  final DateTime createdAt;

  final String meetingPreference; // e.g. "Public meeting point", "Cafe"
  final bool hasCheckin; // show check-in timeline on session screen

  bool get isFreeLike =>
      exchange == ExchangeMode.free ||
      exchange == ExchangeMode.treat ||
      (exchange == ExchangeMode.paid && rewardAmount == 0);

  String get rewardLabel {
    switch (exchange) {
      case ExchangeMode.paid:
        return '₹${rewardAmount.toStringAsFixed(0)}';
      case ExchangeMode.free:
        return 'Free';
      case ExchangeMode.treat:
        return 'My treat';
      case ExchangeMode.expensesCovered:
        return 'Expenses covered';
      case ExchangeMode.negotiable:
        return 'Negotiable';
      case ExchangeMode.barter:
        return 'Skill barter';
    }
  }

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }
}
