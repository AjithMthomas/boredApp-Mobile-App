import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Enums that shape the marketplace, mirroring the Django schema 1:1
/// (kept in sync manually until API codegen exists).

enum PostType { task, company, offer }

/// Vertical a post belongs to. `regular` covers the classic
/// Task / Company / Offer feed; the others are dedicated hubs
/// (Emergency, Shop Gigs, Room Finder, Make Team, Trips) that still
/// reuse the Task pipeline — feed, apply, chat, completion.
enum PostKind { regular, emergency, gig, room, team, trip }

extension PostKindX on PostKind {
  String get label => switch (this) {
        PostKind.regular => 'Post',
        PostKind.emergency => 'SOS',
        PostKind.gig => 'Gig',
        PostKind.room => 'Room',
        PostKind.team => 'Team',
        PostKind.trip => 'Trip',
      };

  String get hubTitle => switch (this) {
        PostKind.regular => 'Feed',
        PostKind.emergency => 'Emergency Helpers',
        PostKind.gig => 'Shop Gigs',
        PostKind.room => 'Room Finder',
        PostKind.team => 'Make Team',
        PostKind.trip => 'Community Trips',
      };

  IconData get icon => switch (this) {
        PostKind.regular => Icons.forum_rounded,
        PostKind.emergency => Icons.emergency_share_rounded,
        PostKind.gig => Icons.storefront_rounded,
        PostKind.room => Icons.night_shelter_rounded,
        PostKind.team => Icons.diversity_3_rounded,
        PostKind.trip => Icons.luggage_rounded,
      };

  ({Color soft, Color strong}) get colors => switch (this) {
        PostKind.regular => (soft: AppColors.infoSoft, strong: AppColors.info),
        PostKind.emergency =>
          (soft: AppColors.dangerSoft, strong: AppColors.danger),
        PostKind.gig =>
          (soft: AppColors.butterSoft, strong: AppColors.auroraAmber),
        PostKind.room =>
          (soft: AppColors.lavenderSoft, strong: AppColors.auroraViolet),
        PostKind.team => (soft: AppColors.mintSoft, strong: AppColors.success),
        PostKind.trip =>
          (soft: AppColors.coralSoft, strong: AppColors.auroraCoral),
      };
}

/// Post-completion trust badges (Phase 8) — earned from mutual reviews,
/// never self-declared.
enum TrustBadge { punctual, friendly, safeHelper, verifiedScout }

extension TrustBadgeX on TrustBadge {
  String get label => switch (this) {
        TrustBadge.punctual => 'Punctual',
        TrustBadge.friendly => 'Friendly',
        TrustBadge.safeHelper => 'Safe Helper',
        TrustBadge.verifiedScout => 'Verified Scout',
      };

  IconData get icon => switch (this) {
        TrustBadge.punctual => Icons.schedule_rounded,
        TrustBadge.friendly => Icons.sentiment_satisfied_alt_rounded,
        TrustBadge.safeHelper => Icons.health_and_safety_rounded,
        TrustBadge.verifiedScout => Icons.travel_explore_rounded,
      };

  Color get color => switch (this) {
        TrustBadge.punctual => AppColors.info,
        TrustBadge.friendly => AppColors.auroraCoral,
        TrustBadge.safeHelper => AppColors.success,
        TrustBadge.verifiedScout => AppColors.auroraViolet,
      };

  Color get soft => switch (this) {
        TrustBadge.punctual => AppColors.infoSoft,
        TrustBadge.friendly => AppColors.coralSoft,
        TrustBadge.safeHelper => AppColors.successSoft,
        TrustBadge.verifiedScout => AppColors.lavenderSoft,
      };
}

enum ExchangeMode { paid, free, treat, expensesCovered, negotiable, barter }

enum TaskRisk { low, medium, high }

enum TaskStatus {
  draft,
  safetyCheck,
  published,
  confirmed,
  active,
  completed,
  cancelled,
  expired,
  disputed,
}

enum ApplicationStatus { interested, chatting, selected, declined, withdrawn }

extension PostTypeX on PostType {
  String get label => switch (this) {
        PostType.task => 'Task',
        PostType.company => 'Company',
        PostType.offer => 'Offer',
      };

  String get tagline => switch (this) {
        PostType.task => 'A concrete need',
        PostType.company => 'Time together',
        PostType.offer => 'Something shared',
      };

  IconData get icon => switch (this) {
        PostType.task => Icons.handyman_rounded,
        PostType.company => Icons.groups_rounded,
        PostType.offer => Icons.card_giftcard_rounded,
      };

  /// Color family per post type (reference-style tinted tiles).
  ({Color soft, Color strong}) get colors => switch (this) {
        PostType.task => (soft: AppColors.skySoft, strong: AppColors.sky),
        PostType.company =>
          (soft: AppColors.lavenderSoft, strong: AppColors.lavender),
        PostType.offer => (soft: AppColors.butterSoft, strong: AppColors.butter),
      };
}

extension ExchangeModeX on ExchangeMode {
  String get label => switch (this) {
        ExchangeMode.paid => 'Paid',
        ExchangeMode.free => 'Free',
        ExchangeMode.treat => "I'll treat",
        ExchangeMode.expensesCovered => 'Expenses covered',
        ExchangeMode.negotiable => 'Negotiable',
        ExchangeMode.barter => 'Skill barter',
      };

  /// Chip color treatment: free/treat get warm emphasis (they are the
  /// community glue), paid stays neutral.
  ({Color bg, Color fg}) get chipStyle => switch (this) {
        ExchangeMode.free => (bg: AppColors.successSoft, fg: AppColors.success),
        ExchangeMode.treat => (bg: AppColors.coralSoft, fg: AppColors.coral),
        ExchangeMode.barter =>
          (bg: AppColors.lavenderSoft, fg: AppColors.textPrimary),
        _ => (bg: AppColors.infoSoft, fg: AppColors.info),
      };
}

extension ApplicationStatusX on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.interested => 'Interested',
        ApplicationStatus.chatting => 'In chat',
        ApplicationStatus.selected => 'Selected',
        ApplicationStatus.declined => 'Not selected',
        ApplicationStatus.withdrawn => 'Withdrawn',
      };
}

extension TaskRiskX on TaskRisk {
  String get label => switch (this) {
        TaskRisk.low => 'Low risk',
        TaskRisk.medium => 'Medium risk',
        TaskRisk.high => 'High risk',
      };

  Color get color => switch (this) {
        TaskRisk.low => AppColors.success,
        TaskRisk.medium => AppColors.warning,
        TaskRisk.high => AppColors.danger,
      };
}

/// Member gender — self-declared, collected so gender-restricted posts
/// (a safety feature) can be enforced. 'Other' is a first-class option.
enum Gender { female, male, other }

extension GenderX on Gender {
  String get label => switch (this) {
        Gender.female => 'Female',
        Gender.male => 'Male',
        Gender.other => 'Other',
      };

  IconData get icon => switch (this) {
        Gender.female => Icons.female_rounded,
        Gender.male => Icons.male_rounded,
        Gender.other => Icons.person_rounded,
      };
}

/// Creator-set participation restriction on a post — the safety feature
/// behind "girls-only travel company" and "boys-only meetups".
/// Enforced at apply-time on the backend, surfaced as a badge in the UI.
enum GenderPreference { anyone, femaleOnly, maleOnly }

extension GenderPreferenceX on GenderPreference {
  String get label => switch (this) {
        GenderPreference.anyone => 'Everyone',
        GenderPreference.femaleOnly => 'Girls only',
        GenderPreference.maleOnly => 'Boys only',
      };

  String get longLabel => switch (this) {
        GenderPreference.anyone => 'Everyone welcome',
        GenderPreference.femaleOnly => 'Girls only',
        GenderPreference.maleOnly => 'Boys only',
      };

  IconData get icon => switch (this) {
        GenderPreference.anyone => Icons.groups_rounded,
        GenderPreference.femaleOnly => Icons.female_rounded,
        GenderPreference.maleOnly => Icons.male_rounded,
      };

  ({Color bg, Color fg}) get chipStyle => switch (this) {
        GenderPreference.anyone =>
          (bg: AppColors.successSoft, fg: AppColors.success),
        GenderPreference.femaleOnly =>
          (bg: AppColors.lavenderSoft, fg: AppColors.auroraViolet),
        GenderPreference.maleOnly => (bg: AppColors.infoSoft, fg: AppColors.info),
      };

  /// The core rule: can a member of [gender] join this post?
  bool admits(Gender? gender) => switch (this) {
        GenderPreference.anyone => true,
        GenderPreference.femaleOnly => gender == Gender.female,
        GenderPreference.maleOnly => gender == Gender.male,
      };
}
