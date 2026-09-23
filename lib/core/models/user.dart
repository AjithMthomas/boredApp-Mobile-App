import 'enums.dart';

/// Phase 8 — badges earned from post-session mutual reviews.
const Map<String, int> kDefaultBadgeVotes = {};

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
    this.karma = 0,
    this.isGuardian = false,
    this.availableNow = false,
    this.badges = const {},
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

  // ── Community layer ──────────────────────────────────────────
  /// Time Credits — earned for free community tasks, redeemable for
  /// partner perks (Phase: Karma & Pay-it-Forward).
  final int karma;

  /// Verified emergency responder with ID & trust checks (Guardian Shield).
  final bool isGuardian;

  /// "Available Now" roster toggle (Emergency Helpers phase).
  final bool availableNow;

  /// Trust badges earned from reviews.
  final Set<TrustBadge> badges;

  Member copyMemberWith({
    int? karma,
    bool? isGuardian,
    bool? availableNow,
    Set<TrustBadge>? badges,
    int? completedCount,
  }) {
    return Member(
      id: id,
      publicName: publicName,
      email: email,
      photoUrl: photoUrl,
      gender: gender,
      bio: bio,
      completedCount: completedCount ?? this.completedCount,
      rating: rating,
      ratingCount: ratingCount,
      cancellations: cancellations,
      noShows: noShows,
      accountAgeMonths: accountAgeMonths,
      verifiedBadge: verifiedBadge,
      isEstablished: completedCount != null && completedCount >= 40
          ? true
          : isEstablished,
      joinedAt: joinedAt,
      dateOfBirth: dateOfBirth,
      ageGatePassed: ageGatePassed,
      categories: categories,
      isEmailVerified: isEmailVerified,
      safetyContactName: safetyContactName,
      safetyContactPhone: safetyContactPhone,
      availabilityHours: availabilityHours,
      karma: karma ?? this.karma,
      isGuardian: isGuardian ?? this.isGuardian,
      availableNow: availableNow ?? this.availableNow,
      badges: badges ?? this.badges,
    );
  }

  int get reliabilityPercent {
    if (completedCount == 0) return 100;
    final attempts = completedCount + cancellations + noShows;
    return (completedCount * 100 / attempts).round().clamp(0, 100);
  }

  String get ratingLabel => rating.toStringAsFixed(1);
}
