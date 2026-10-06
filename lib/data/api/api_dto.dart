// Server JSON → existing Flutter models.
//
// The UI consumes app models; this file is the ONLY place that knows the
// server's JSON shapes. Backend field renames happen here, not in screens.
import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../mock_backend.dart' show MockNotification;
import 'api_models.dart';

/// Parse a server datetime (ISO-8601) safely.
DateTime dtParse(String? raw) =>
    raw == null ? DateTime.now() : DateTime.tryParse(raw) ?? DateTime.now();

double dParse(dynamic v) =>
    v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);

int iParse(dynamic v) =>
    v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);

/// Server enum strings (expensesCovered) → Dart enums (case/space tolerant).
T enumParse<T extends Enum>(List<T> values, String? raw, T fallback) {
  final normalized = (raw ?? '').replaceAll('_', '').toLowerCase();
  for (final value in values) {
    if (value.name.toLowerCase() == normalized) return value;
  }
  return fallback;
}

Map<String, dynamic> _creatorOf(Map<String, dynamic> j) =>
    (j['creator'] as Map<String, dynamic>? ?? const {});

Task taskFromJson(Map<String, dynamic> j) => Task(
      id: j['id'] as String,
      creatorId: _creatorOf(j)['id'] as String? ?? '',
      creatorName: _creatorOf(j)['public_name'] as String? ?? '',
      creatorPhotoUrl: _creatorOf(j)['photo_url'] as String? ?? '',
      creatorVerified: _creatorOf(j)['verified'] as bool? ?? false,
      creatorRating: dParse(_creatorOf(j)['rating']),
      creatorCompleted: iParse(_creatorOf(j)['completed']),
      type: enumParse(PostType.values, j['type'], PostType.task),
      kind: enumParse(PostKind.values, j['kind'], PostKind.regular),
      payoutNote: j['payout_note'] as String? ?? '',
      title: j['title'] as String? ?? '',
      description: j['description'] as String? ?? '',
      category: j['category'] as String? ?? 'Errands',
      scheduledAt: dtParse(j['scheduled_at'] as String?),
      durationMinutes: iParse(j['duration_minutes']),
      area: j['area'] as String? ?? '',
      distanceKm: dParse(j['distance_km']),
      exchange: enumParse(ExchangeMode.values, j['exchange'], ExchangeMode.free),
      rewardAmount: dParse(j['reward_amount']),
      capacity: iParse(j['capacity']),
      applicantCount: iParse(j['applicant_count']),
      genderPreference:
          enumParse(GenderPreference.values, j['gender_preference'], GenderPreference.anyone),
      risk: enumParse(TaskRisk.values, j['risk'], TaskRisk.low),
      status: enumParse(TaskStatus.values, j['status'], TaskStatus.published),
      createdAt: dtParse(j['created_at'] as String?),
      meetingPreference: j['meeting_preference'] as String? ?? 'Public meeting point',
      hasCheckin: j['has_checkin'] as bool? ?? false,
    );

List<Task> tasksFromJson(dynamic data) {
  final list = data is Map && data['results'] is List
      ? data['results'] as List
      : data is List ? data : const [];
  return list
      .whereType<Map<String, dynamic>>()
      .map(taskFromJson)
      .toList(growable: false);
}

Member memberFromJson(Map<String, dynamic> j) => Member(
      id: j['id'] as String,
      publicName: j['public_name'] as String? ?? 'Member',
      email: j['email'] as String? ?? '',
      photoUrl: j['photo_url'] as String? ?? '',
      gender: enumParse(Gender.values, j['gender'], Gender.other),
      bio: j['bio'] as String? ?? '',
      completedCount: iParse(j['completed_count']),
      rating: dParse(j['rating']),
      ratingCount: iParse(j['rating_count']),
      cancellations: iParse(j['cancellations']),
      noShows: iParse(j['no_shows']),
      accountAgeMonths:
          DateTime.now().difference(dtParse(j['joined_at'] as String?)).inDays ~/ 30,
      verifiedBadge: j['verified_badge'] as bool? ?? false,
      isEstablished: j['is_established'] as bool? ?? false,
      joinedAt: dtParse(j['joined_at'] as String?),
      dateOfBirth: dtParse(j['date_of_birth'] as String?),
      ageGatePassed: j['age_gate_passed'] as bool? ?? true,
      categories: (j['categories'] as List?)?.cast<String>() ?? const [],
      isEmailVerified: j['is_email_verified'] as bool? ?? true,
      safetyContactName: (j['safety_contact_name'] as String?)?.isEmpty ?? true
          ? null
          : j['safety_contact_name'] as String,
      safetyContactPhone: (j['safety_contact_phone'] as String?)?.isEmpty ?? true
          ? null
          : j['safety_contact_phone'] as String,
      availabilityHours: j['availability_hours'] as String? ?? 'Flexible',
      karma: iParse(j['karma']),
      isGuardian: j['is_guardian'] as bool? ?? false,
      availableNow: j['available_now'] as bool? ?? false,
      badges: _badges(j['badges']),
    );

Set<TrustBadge> _badges(dynamic raw) => (raw as List? ?? const [])
    .map((b) => enumParse(TrustBadge.values, b.toString(), TrustBadge.punctual))
    .toSet();

ApplicationStatus applicationStatusFrom(String? raw) =>
    enumParse(ApplicationStatus.values, raw, ApplicationStatus.chatting);

AuctionStatus auctionStatusFrom(String? raw) =>
    enumParse(AuctionStatus.values, raw, AuctionStatus.active);

AuctionItem auctionFromJson(Map<String, dynamic> j) {
  final seller = j['seller'] as Map<String, dynamic>? ?? const {};
  final bids = (j['bids'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map((b) => AuctionBid(
            id: b['id'] as String,
            bidderId: b['bidder'] as String? ?? '',
            bidderName: b['bidder_name'] as String? ?? '',
            bidderPhotoUrl: b['bidder_photo'] as String? ?? '',
            amount: dParse(b['amount']),
            timestamp: dtParse(b['created_at'] as String?),
          ))
      .toList();
  return AuctionItem(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    description: j['description'] as String? ?? '',
    category: j['category'] as String? ?? 'Gadgets',
    imageUrl: j['image_url'] as String? ?? '',
    sellerId: seller['id'] as String? ?? '',
    sellerName: seller['public_name'] as String? ?? '',
    sellerPhotoUrl: seller['photo_url'] as String? ?? '',
    sellerVerified: seller['verified'] as bool? ?? false,
    sellerRating: dParse(seller['rating']),
    basePrice: dParse(j['base_price']),
    currentBid: dParse(j['current_bid']),
    buyItNowPrice:
        j['buy_it_now_price'] == null ? null : dParse(j['buy_it_now_price']),
    serviceFeePercent: dParse(j['service_fee_percent']),
    startTime: dtParse(j['start_time'] as String?),
    endTime: dtParse(j['end_time'] as String?),
    totalBids: iParse(j['total_bids']),
    status: auctionStatusFrom(j['status'] as String?),
    bidHistory: bids,
    area: j['area'] as String? ?? 'Madiwala Central',
    distanceKm: dParse(j['distance_km']),
  );
}

List<dynamic> _resultsOf(dynamic data) {
  if (data is Map && data['results'] is List) return data['results'] as List;
  if (data is List) return data;
  return const [];
}

List<AuctionItem> auctionsFromJson(dynamic data) => _resultsOf(data)
    .whereType<Map<String, dynamic>>()
    .map(auctionFromJson)
    .toList();

List<MockNotification> notificationsFromJson(dynamic data) => _resultsOf(data)
    .whereType<Map<String, dynamic>>()
    .map((n) => MockNotification(
          id: n['id'] as String,
          title: n['title'] as String? ?? '',
          body: n['body'] as String? ?? '',
          createdAt: dtParse(n['created_at'] as String?),
          read: n['read'] as bool? ?? false,
        ))
    .toList();

PartnerPerk perkFromJson(Map<String, dynamic> j) => PartnerPerk(
      id: j['id'] as String,
      merchant: j['merchant'] as String? ?? '',
      title: j['title'] as String? ?? '',
      details: j['details'] as String? ?? '',
      emojiIcon: iconFor(j['icon'] as String? ?? 'local_cafe'),
      costKarma: iParse(j['cost_karma']),
      area: j['area'] as String? ?? '',
      validHours: iParse(j['valid_hours']),
      gradient: gradientFor(j['icon'] as String? ?? 'local_cafe'),
    );

PlayChallenge challengeFromJson(Map<String, dynamic> j) => PlayChallenge(
      id: j['code'] as String? ?? j['id'] as String,
      title: j['title'] as String? ?? '',
      rules: j['rules'] as String? ?? '',
      target: iParse(j['target']),
      rewardKarma: iParse(j['reward_karma']),
      icon: iconFor(j['icon'] as String? ?? 'touch_app'),
      gradient: gradientFor(j['icon'] as String? ?? 'touch_app'),
    );

List<BoardIdea> ideasFromJson(dynamic data) => _resultsOf(data)
    .whereType<Map<String, dynamic>>()
    .map((j) => BoardIdea(
          id: j['id'] as String,
          authorId: (j['author'] as Map<String, dynamic>?)?['id'] as String? ?? '',
          authorName:
              (j['author'] as Map<String, dynamic>?)?['public_name'] as String? ?? '',
          authorPhotoUrl:
              (j['author'] as Map<String, dynamic>?)?['photo_url'] as String? ?? '',
          title: j['title'] as String? ?? '',
          details: j['details'] as String? ?? '',
          tag: j['tag'] as String? ?? 'Feature',
          upvotes: iParse(j['upvotes']),
          createdAt: dtParse(j['created_at'] as String?),
          votedByMe: j['voted_by_me'] as bool? ?? false,
          scheduled: j['scheduled'] as bool? ?? false,
        ))
    .toList();
