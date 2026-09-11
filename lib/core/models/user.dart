import 'enums.dart';

/// Member model. PII is intentionally minimal (email-only auth),
/// everything else is public-name + trust signals.
/// Visual identity = profile photo when available, otherwise a
/// GradientAvatar derived from publicName (deterministic, no emoji).
class Member {
  const Member({
    required this.id,
    required this.publicName,
    required this.email,
    required this.photoUrl,
    required this.gender,
    required this.bio,
    required this.completedCount,
    required this.rating,
    required this.ratingCount,
    required this.cancellations,
    required this.noShows,
    required this.accountAgeMonths,
    required this.verifiedBadge,
    required this.isEstablished,
    required this.joinedAt,
    required this.dateOfBirth,
    required this.ageGatePassed,
    required this.categories,
    required this.isEmailVerified,
    required this.safetyContactName,
    required this.safetyContactPhone,
    required this.availabilityHours,
  });

  final String id;
  final String publicName;
  final String email; // private, never rendered in UI
  final String photoUrl; // nullable-in-spirit: '' falls back to gradient initials
  final Gender gender; // enables gender-restricted posts to enforce access
  final String bio;

  // Trust signals (behaviour-based, never wealth-based)
  final int completedCount;
  final double rating;
  final int ratingCount;
  final int cancellations;
  final int noShows;
  final int accountAgeMonths;
  final bool verifiedBadge;
  final bool isEstablished;

  final DateTime joinedAt;

  // Age gate (18+) — self-declared, DPDP-conscious
  final DateTime dateOfBirth;
  final bool ageGatePassed;

  final List<String> categories;
  final bool isEmailVerified;

  // Safety center (stored locally in MVP; API-managed later)
  final String? safetyContactName;
  final String? safetyContactPhone;

  final String availabilityHours;

  int get reliabilityPercent {
    if (completedCount == 0) return 100;
    final attempts = completedCount + cancellations + noShows;
    return (completedCount * 100 / attempts).round().clamp(0, 100);
  }

  String get ratingLabel => rating.toStringAsFixed(1);
}
