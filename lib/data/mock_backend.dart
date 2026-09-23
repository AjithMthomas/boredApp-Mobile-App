// Madiwala seed content + in-memory mock backend.
// Swap `MockBackend` for the API implementation in Stage 2 — interfaces match.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/models.dart';
import '../core/moderation.dart';
import '../core/theme/app_colors.dart';
import 'task_draft.dart';

export 'task_draft.dart';

/// Simple readable IDs (u1, t1, a1, m1 ...).
class _Ids {
  static int _n = 0;
  static String next(String prefix) {
    _n += 1;
    return '$prefix$_n';
  }
}

/// Real portrait photos for seed members (Unsplash, faces crop).
String _p(String id) =>
    'https://images.unsplash.com/photo-$id?w=256&h=256&fit=crop&crop=faces&auto=format';

/// Seed members of the Madiwala micro-market. Visual identity = real
/// portrait photos, with gradient initials as the automatic fallback.
final List<Member> kSeedMembers = [
  _member('u1', 'Ayesha Khan', 'College student. Loves chai and long walks.',
      photo: _p('1494790108377-be9c29b29330'),
      gender: Gender.female,
      completed: 42, rating: 4.9, ratings: 50, months: 8, verified: true,
      karma: 320, guardian: true, availableNow: true,
      badges: const {TrustBadge.punctual, TrustBadge.friendly}),
  _member('u2', 'Ravi Kumar', 'Bike mechanic near Jyoti Nivas. Weekend cricketer.',
      photo: _p('1507003211169-0a1dd7228f2d'),
      gender: Gender.male,
      completed: 67, rating: 4.7, ratings: 80, months: 11, verified: true,
      karma: 540, guardian: true, availableNow: false,
      badges: const {TrustBadge.punctual, TrustBadge.safeHelper}),
  _member('u3', 'Meera Nair', 'Final year BA. Happy to accompany for errands.',
      photo: _p('1438761681033-6461ffad8d80'),
      completed: 18, rating: 4.8, ratings: 22, months: 3, verified: false),
  _member('u4', 'Sana Reddy', 'Nursing student. Free Sunday mornings.',
      photo: _p('1544005313-94ddf0286df2'),
      completed: 25, rating: 4.9, ratings: 30, months: 5, verified: true,
      karma: 180, guardian: true, availableNow: true,
      badges: const {TrustBadge.safeHelper}),
  _member('u5', 'Karthik S', 'IT guy. Can carry heavy stuff, has a bike.',
      photo: _p('1500648767791-00dcc994a43e'),
      gender: Gender.male,
      completed: 31, rating: 4.6, ratings: 36, months: 6, verified: false,
      karma: 210, availableNow: true,
      badges: const {TrustBadge.verifiedScout}),
  _member('u6', 'Lakshmi Devi', 'Homemaker. Cooks, hosts, feeds people.',
      photo: _p('1502823403499-6ccfcf4fb453'),
      completed: 54, rating: 5.0, ratings: 60, months: 9, verified: true),
  _member('u7', 'Imran Ali', 'MCA student. Study partner material.',
      photo: _p('1506794778202-cad84cf45f1d'),
      gender: Gender.male,
      completed: 9, rating: 4.5, ratings: 11, months: 2, verified: false),
  _member('u8', 'Divya Sharma', 'Freelance artist. Museum & cafe buddy.',
      photo: _p('1534528741775-53994a69daeb'),
      completed: 22, rating: 4.8, ratings: 27, months: 4, verified: false),
];

Member _member(
  String id,
  String name,
  String bio, {
  String photo = '',
  Gender gender = Gender.female,
  required int completed,
  required double rating,
  required int ratings,
  required int months,
  required bool verified,
  int karma = 0,
  bool guardian = false,
  bool availableNow = false,
  Set<TrustBadge> badges = const {},
}) {
  return Member(
    id: id,
    publicName: name,
    email: '$id@seed.local',
    photoUrl: photo,
    gender: gender,
    bio: bio,
    completedCount: completed,
    rating: rating,
    ratingCount: ratings,
    cancellations: months ~/ 3,
    noShows: 0,
    accountAgeMonths: months,
    verifiedBadge: verified,
    isEstablished: completed >= 40,
    joinedAt: DateTime.now().subtract(Duration(days: months * 30)),
    dateOfBirth: DateTime(1996, 1, 1),
    ageGatePassed: true,
    categories: const ['Errands', 'Tea & walks'],
    isEmailVerified: true,
    safetyContactName: null,
    safetyContactPhone: null,
    availabilityHours: 'Flexible',
    karma: karma,
    isGuardian: guardian,
    availableNow: availableNow,
    badges: badges,
  );
}

/// Madiwala seed feed — every post type and exchange mode represented.
final List<Task> kSeedTasks = [
  _task(
    id: 't0',
    creator: kSeedMembers[1],
    type: PostType.offer,
    title: "I'm free for 1 hour. Anyone need help/company?",
    desc:
        'Got an hour to spare in Madiwala before my evening study shift. Happy to help with quick errands, grab coffee, walk, or chat!',
    category: 'Company',
    inHours: 1,
    minutes: 60,
    area: 'Madiwala · 4th Block',
    km: 0.3,
    exchange: ExchangeMode.free,
    amount: 0,
    capacity: 2,
    applicants: 4,
    risk: TaskRisk.low,
    meeting: 'Public cafe / library',
    checkin: false,
  ),
  _task(
    id: 't1',
    creator: kSeedMembers[0],
    type: PostType.task,
    title: 'Bike wash + polish',
    desc:
        'Bike is dusty after a Hosur road trip. Need someone to wash and polish it near 5th Block. Bucket and supplies in the parking — no need to come inside.',
    category: 'Errands',
    inHours: 20,
    minutes: 30,
    area: 'Madiwala · 5th Block',
    km: 0.8,
    exchange: ExchangeMode.paid,
    amount: 100,
    capacity: 1,
    applicants: 3,
    risk: TaskRisk.low,
    meeting: 'At my building parking',
    checkin: false,
  ),
  _task(
    id: 't2',
    creator: kSeedMembers[7],
    type: PostType.company,
    title: 'Museum visit — need company',
    desc:
        'Going to the Government Museum on Saturday morning. Nobody around me is into history. Join me, filter coffee after.',
    category: 'Culture',
    inHours: 40,
    minutes: 120,
    area: 'Madiwala · Meeting at Metro Gate B',
    km: 1.4,
    exchange: ExchangeMode.free,
    amount: 0,
    capacity: 2,
    applicants: 5,
    risk: TaskRisk.low,
    meeting: 'Public meeting point',
    checkin: false,
  ),
  _task(
    id: 't3',
    creator: kSeedMembers[2],
    type: PostType.task,
    title: 'Accompany me to college office',
    desc:
        'Collecting my degree certificates tomorrow 11 AM. The office insists on "one more person" for the ID verification queue. Just need company while I wait.',
    category: 'Errands',
    inHours: 26,
    minutes: 90,
    area: 'Madiwala · Near Christ University gate',
    km: 2.1,
    exchange: ExchangeMode.paid,
    amount: 300,
    capacity: 1,
    applicants: 17,
    risk: TaskRisk.medium,
    meeting: 'College main gate',
    checkin: true,
  ),
  _task(
    id: 't4',
    creator: kSeedMembers[5],
    type: PostType.offer,
    title: 'Sunday lunch — my treat',
    genderPref: GenderPreference.femaleOnly,
    desc:
        'Cooking biryani for 6 this Sunday. Family is out of town, food should not be wasted. Come, eat, tell me about your city. Solo folks especially welcome.',
    category: 'Food',
    inHours: 52,
    minutes: 90,
    area: 'Madiwala · Jyoti Nivas lane',
    km: 1.1,
    exchange: ExchangeMode.treat,
    amount: 0,
    capacity: 4,
    applicants: 8,
    risk: TaskRisk.low,
    meeting: 'At host home (details after confirm)',
    checkin: false,
  ),
  _task(
    id: 't5',
    creator: kSeedMembers[1],
    type: PostType.company,
    title: 'Morning cricket — 2 more players',
    genderPref: GenderPreference.maleOnly,
    desc:
        'Regular Sunday 7 AM game at JP Park ground. We are 9, need 2 more. Medium pace, no fights, chai after.',
    category: 'Sports',
    inHours: 15,
    minutes: 150,
    area: 'BTM Layout · JP Park',
    km: 2.8,
    exchange: ExchangeMode.free,
    amount: 0,
    capacity: 2,
    applicants: 4,
    risk: TaskRisk.low,
    meeting: 'Public ground',
    checkin: false,
  ),
  _task(
    id: 't6',
    creator: kSeedMembers[3],
    type: PostType.task,
    title: 'Help my mom with groceries',
    desc:
        'I am travelling for work this week. Mom needs help carrying groceries from Madiwala market on Friday evening. She makes amazing snacks for helpers.',
    category: 'Errands',
    inHours: 9,
    minutes: 45,
    area: 'Madiwala Market',
    km: 0.5,
    exchange: ExchangeMode.paid,
    amount: 150,
    capacity: 1,
    applicants: 2,
    risk: TaskRisk.medium,
    meeting: 'Market entrance',
    checkin: true,
  ),
  _task(
    id: 't7',
    creator: kSeedMembers[6],
    type: PostType.company,
    title: 'Study buddy — DSA evenings',
    desc:
        'Placements in December. Looking for a serious study partner, 7-9 PM at Madiwala library cafe. We split the table coffee.',
    category: 'Study',
    inHours: 6,
    minutes: 120,
    area: 'Madiwala · Library cafe',
    km: 0.9,
    exchange: ExchangeMode.barter,
    amount: 0,
    capacity: 1,
    applicants: 3,
    risk: TaskRisk.low,
    meeting: 'Public cafe',
    checkin: false,
  ),
  _task(
    id: 't8',
    creator: kSeedMembers[4],
    type: PostType.task,
    title: 'Metro station pickup tonight',
    desc:
        'Reaching Indiranagar metro at 9:40 PM with two heavy bags. Need someone with a bike or car to drop me home. Fuel plus a bit extra covered.',
    category: 'Transport',
    inHours: 5,
    minutes: 40,
    area: 'Indiranagar Metro Station',
    km: 3.6,
    exchange: ExchangeMode.negotiable,
    amount: 0,
    capacity: 1,
    applicants: 1,
    risk: TaskRisk.high,
    meeting: 'Metro gate pickup',
    checkin: true,
  ),

  // ── Phase 1 · Emergency seeds ──────────────────────────────
  _task(
    id: 'e1',
    creator: kSeedMembers[0],
    type: PostType.task,
    kind: PostKind.emergency,
    title: 'Drive my grandma to St. John\'s Hospital — now',
    desc:
        'Grandma slipped in the bathroom. Need someone with a car or bike to '
        'take her to St. John\'s emergency wing in Koramangala. I will sit '
        'with her, just need the driver.',
    category: 'Emergency',
    inHours: 0,
    minutes: 90,
    area: 'Madiwala · Jyoti Nivas Lane',
    km: 0.6,
    exchange: ExchangeMode.free,
    amount: 0,
    capacity: 1,
    applicants: 2,
    risk: TaskRisk.high,
    meeting: 'Shared in chat',
    checkin: true,
  ),
  _task(
    id: 'e2',
    creator: kSeedMembers[5],
    type: PostType.task,
    kind: PostKind.emergency,
    title: 'Urgent: two hands to move fridge before repair van arrives',
    desc:
        'Service van comes in 90 minutes and the fridge is too heavy for one '
        'person. Two quick trips from kitchen to balcony would save the visit.',
    category: 'Emergency',
    inHours: 1,
    minutes: 30,
    area: 'Madiwala · 4th Block',
    km: 0.4,
    exchange: ExchangeMode.paid,
    amount: 300,
    capacity: 2,
    applicants: 1,
    risk: TaskRisk.low,
    meeting: 'At my flat (building gate)',
    checkin: false,
  ),

  // ── Phase 2 · Shop Gig seeds ─────────────────────────────
  _task(
    id: 'g1',
    creator: kSeedMembers[2],
    type: PostType.task,
    kind: PostKind.gig,
    creatorNameOverride: 'Sri Ganesh Stores',
    payoutNote: '₹900/day · 7 days',
    title: '2 sales reps for Diwali rush — evening shift',
    desc:
        'Diwali stock is arriving and the shop needs two friendly people at '
        'the counter, 5–10 PM for one week. Basic Kannada helps, smile required.',
    category: 'Gigs',
    inHours: 12,
    minutes: 7 * 8 * 60,
    area: 'Madiwala · Market Rd',
    km: 0.7,
    exchange: ExchangeMode.paid,
    amount: 900 * 7,
    capacity: 2,
    applicants: 6,
    risk: TaskRisk.low,
    meeting: 'At the shop',
    checkin: false,
  ),
  _task(
    id: 'g2',
    creator: kSeedMembers[6],
    type: PostType.task,
    kind: PostKind.gig,
    creatorNameOverride: 'Madiwala Cafe Corner',
    payoutNote: '₹700/day · 3 days',
    title: 'Weekend barista helper',
    desc:
        'Weekend rush cover — washing, packing, and handing orders. '
        'Breakfast + evening snacks on the house every shift.',
    category: 'Gigs',
    inHours: 30,
    minutes: 3 * 8 * 60,
    area: 'Madiwala · Jyoti Nivas Lane',
    km: 1.1,
    exchange: ExchangeMode.paid,
    amount: 700 * 3,
    capacity: 1,
    applicants: 3,
    risk: TaskRisk.low,
    meeting: 'At the cafe',
    checkin: false,
  ),

  // ── Phase 3 · Room Finder seeds ──────────────────────────
  _task(
    id: 'r1',
    creator: kSeedMembers[7],
    type: PostType.task,
    kind: PostKind.room,
    payoutNote: '1RK under ₹10,000',
    title: 'Urgent: 1RK near Madiwala market — new to city',
    desc:
        'Transferred to Bengaluru with two weeks to find a place. Need 1RK or '
        'single room walking distance from the market. Ground floor preferred. '
        'Happy to pay a scout fee for a working lead.',
    category: 'Rooms',
    inHours: 24,
    minutes: 60,
    area: 'Madiwala / BTM border',
    km: 1.3,
    exchange: ExchangeMode.paid,
    amount: 1000,
    capacity: 1,
    applicants: 4,
    risk: TaskRisk.low,
    meeting: 'At the room',
    checkin: false,
  ),
  _task(
    id: 'r2',
    creator: kSeedMembers[4],
    type: PostType.task,
    kind: PostKind.room,
    payoutNote: '2BHK under ₹28,000',
    genderPref: GenderPreference.femaleOnly,
    title: 'Girls-only: 2BHK flatmate hunt near JP Park',
    desc:
        'Found a great 2BHK near JP Park — need one more flatmate to split '
        'rent. Female flat only. Scouts who know vacant flats in BTM get the fee.',
    category: 'Rooms',
    inHours: 40,
    minutes: 60,
    area: 'BTM Layout · JP Park',
    km: 2.6,
    exchange: ExchangeMode.paid,
    amount: 800,
    capacity: 1,
    applicants: 2,
    risk: TaskRisk.low,
    meeting: 'At the room',
    checkin: false,
  ),

  // ── Phase 4 · Team & Trip seeds ──────────────────────────
  _task(
    id: 'm1',
    creator: kSeedMembers[5],
    type: PostType.company,
    kind: PostKind.team,
    title: 'Need 8 people for reels shoot — Sunday morning',
    desc:
        'Shooting a fun street-food reel series around Madiwala. Need 8 '
        'energetic people to be the crowd + one spot as taster-in-chief. '
        'Breakfast covered!',
    category: 'Teams',
    inHours: 18,
    minutes: 180,
    area: 'Madiwala Market stretch',
    km: 0.9,
    exchange: ExchangeMode.free,
    amount: 0,
    capacity: 8,
    applicants: 5,
    risk: TaskRisk.low,
    meeting: 'Public meeting point',
    checkin: false,
  ),
  _task(
    id: 'm2',
    creator: kSeedMembers[1],
    type: PostType.company,
    kind: PostKind.trip,
    payoutNote: 'Nandi Hills sunrise',
    title: 'Bike convoy to Nandi Hills — sunrise trip',
    genderPref: GenderPreference.maleOnly,
    desc:
        'Leaving 4:30 AM, reaching for sunrise, breakfast on the way back. '
        'Own bike or pillion (fuel split). Venue cost of ~₹2,400 split per head.',
    category: 'Trips',
    inHours: 30,
    minutes: 8 * 60,
    area: 'Departure: Madiwala Metro Gate B',
    km: 25,
    exchange: ExchangeMode.expensesCovered,
    amount: 400,
    capacity: 6,
    applicants: 3,
    risk: TaskRisk.medium,
    meeting: 'Public meeting point',
    checkin: true,
  ),
  _task(
    id: 'm3',
    creator: kSeedMembers[3],
    type: PostType.company,
    kind: PostKind.trip,
    genderPref: GenderPreference.femaleOnly,
    payoutNote: 'Skandagiri trek',
    title: 'Girls-only night trek — Skandagiri full moon',
    desc:
        'Guided night trek under the full moon. Fees, transport and '
        'breakfast ≈ ₹1,800 total, split per head. Two verified Guardians '
        'already joining.',
    category: 'Trips',
    inHours: 50,
    minutes: 8 * 60,
    area: 'Departure: Madiwala · 5th Block',
    km: 30,
    exchange: ExchangeMode.expensesCovered,
    amount: 600,
    capacity: 10,
    applicants: 7,
    risk: TaskRisk.medium,
    meeting: 'Public meeting point',
    checkin: true,
  ),
];

Task _task({
  required String id,
  required Member creator,
  required PostType type,
  required String title,
  required String desc,
  required String category,
  required int inHours,
  required int minutes,
  required String area,
  required double km,
  required ExchangeMode exchange,
  required double amount,
  required int capacity,
  required int applicants,
  required TaskRisk risk,
  required String meeting,
  required bool checkin,
  GenderPreference genderPref = GenderPreference.anyone,
  PostKind kind = PostKind.regular,
  String payoutNote = '',
  String? creatorNameOverride,
}) {
  final scheduled = DateTime.now().add(Duration(hours: inHours));
  return Task(
    id: id,
    creatorId: creator.id,
    creatorName: creatorNameOverride ?? creator.publicName,
    creatorPhotoUrl: creator.photoUrl,
    creatorVerified: creator.verifiedBadge,
    creatorRating: creator.rating,
    creatorCompleted: creator.completedCount,
    type: type,
    kind: kind,
    payoutNote: payoutNote,
    title: title,
    description: desc,
    category: category,
    scheduledAt: scheduled,
    durationMinutes: minutes,
    area: area,
    distanceKm: km,
    exchange: exchange,
    rewardAmount: amount,
    capacity: capacity,
    applicantCount: applicants,
    genderPreference: genderPref,
    risk: risk,
    status: TaskStatus.published,
    createdAt: scheduled.subtract(const Duration(days: 1)),
    meetingPreference: meeting,
    hasCheckin: checkin,
  );
}

/// Application record (one per member per task).
class MockApplication {
  MockApplication({
    required this.id,
    required this.taskId,
    required this.memberId,
    required this.introMessage,
    required this.status,
    required this.createdAt,
    this.unreadForCreator = 1,
    this.unreadForApplicant = 0,
  });

  final String id;
  final String taskId;
  final String memberId;
  final String introMessage;
  ApplicationStatus status;
  final DateTime createdAt;
  int unreadForCreator;
  int unreadForApplicant;
}

/// Chat message inside an application room.
class MockMessage {
  MockMessage({
    required this.id,
    required this.applicationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String applicationId;
  final String senderId;
  final String body;
  final DateTime createdAt;
}

/// In-app notification centre item.
class MockNotification {
  MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;
}

/// In-memory backend implementing every use-case the app needs.
class MockBackend extends ChangeNotifier {
  // ── Auth / signup state ──────────────────────────────────────────
  bool signedIn = false;
  String? pendingEmail;
  String? pendingOtp;
  DateTime? otpExpiresAt;
  DateTime? signupDob;
  String signupIntent = 'both';
  String signupName = '';
  String signupBio = '';
  List<String> signupCategories = [];

  // ── Marketplace state ────────────────────────────────────────────
  final List<Member> members = List.of(kSeedMembers);
  final List<Task> tasks = List.of(kSeedTasks);
  final List<MockApplication> applications = [];
  final Map<String, List<MockMessage>> roomMessages = {};
  final List<MockNotification> notifications = [
    MockNotification(
      id: _Ids.next('n'),
      title: 'Welcome to nuvra',
      body: 'Your Madiwala feed is live. Start with a tea walk?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      read: true,
    ),
  ];
  final Set<String> savedTaskIds = {};
  final Set<String> repostedTaskIds = {};

  // ── Preferences ──────────────────────────────────────────────────
  String feedSource = 'nearby';
  double radiusKm = 3;
  Set<PostType> filterTypes = {};
  Set<ExchangeMode> filterExchanges = {};
  Set<GenderPreference> filterGenderPrefs = {};
  bool filterFreeOnly = false;
  String filterQuery = '';
  String filterCategory = 'All';

  // ── Current user ─────────────────────────────────────────────────
  Member? me;
  Member? get currentUser => me;

  /// Set when postTask is blocked by the moderation screen; the UI
  /// reads + clears it to show the reason.
  String? _pendingModerationBlock;
  String? consumeModerationBlock() {
    final v = _pendingModerationBlock;
    _pendingModerationBlock = null;
    return v;
  }

  List<String> get categories => const [
        'All',
        'Errands',
        'Company',
        'Food',
        'Sports',
        'Study',
        'Culture',
        'Transport',
      ];

  static final Member _demoMember = _member(
    'u_me',
    'You',
    'New in Madiwala. Happy to help with errands and tea walks.',
    photo: _p('1517841905240-472988babdf9'),
    gender: Gender.other,
    completed: 7,
    rating: 4.8,
    ratings: 9,
    months: 4,
    verified: true,
  );

  void _ensureMe() {
    me ??= _demoMember;
  }

  MockBackend() {
    initFromPrefs();
  }

  Future<void> initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSavedSignedIn = prefs.getBool('auth_signed_in') ?? false;
      if (isSavedSignedIn) {
        signedIn = true;
        pendingEmail = prefs.getString('auth_email') ?? 'user@nuvra.app';
        signupName = prefs.getString('auth_name') ?? 'You';
        signupBio = prefs.getString('auth_bio') ?? 'New in Madiwala.';
        final photo = prefs.getString('auth_photo') ?? _p('1517841905240-472988babdf9');
        final genderStr = prefs.getString('auth_gender') ?? 'other';
        final cats = prefs.getStringList('auth_categories') ?? const ['Errands', 'Tea & walks'];
        signupCategories = cats;

        final gender = Gender.values.firstWhere(
          (g) => g.name == genderStr,
          orElse: () => Gender.other,
        );

        me = Member(
          id: 'u_me',
          publicName: signupName.isNotEmpty ? signupName : 'You',
          email: pendingEmail!,
          photoUrl: photo,
          gender: gender,
          bio: signupBio,
          completedCount: 7,
          rating: 4.8,
          ratingCount: 9,
          cancellations: 1,
          noShows: 0,
          accountAgeMonths: 4,
          verifiedBadge: true,
          isEstablished: false,
          joinedAt: DateTime.now().subtract(const Duration(days: 120)),
          dateOfBirth: DateTime(1998, 5, 12),
          ageGatePassed: true,
          categories: cats,
          isEmailVerified: true,
          safetyContactName: null,
          safetyContactPhone: null,
          availabilityHours: 'Flexible',
          karma: 320,
          badges: const {TrustBadge.punctual},
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading prefs: $e');
    }
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_signed_in', signedIn);
      if (pendingEmail != null) await prefs.setString('auth_email', pendingEmail!);
      await prefs.setString('auth_name', signupName.isNotEmpty ? signupName : (me?.publicName ?? 'You'));
      await prefs.setString('auth_bio', signupBio.isNotEmpty ? signupBio : (me?.bio ?? ''));
      if (me?.photoUrl != null) await prefs.setString('auth_photo', me!.photoUrl);
      if (me?.gender != null) await prefs.setString('auth_gender', me!.gender.name);
      if (signupCategories.isNotEmpty) await prefs.setStringList('auth_categories', signupCategories);
    } catch (e) {
      debugPrint('Error saving prefs: $e');
    }
  }

  Future<void> clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_signed_in');
      await prefs.remove('auth_email');
      await prefs.remove('auth_name');
      await prefs.remove('auth_bio');
      await prefs.remove('auth_photo');
      await prefs.remove('auth_gender');
      await prefs.remove('auth_categories');
    } catch (e) {
      debugPrint('Error clearing prefs: $e');
    }
  }

  // ── Auth ─────────────────────────────────────────────────────────
  void requestOtp(String email) {
    pendingEmail = email;
    pendingOtp = '424242';
    otpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
    notifyListeners();
  }

  bool verifyOtp(String code) {
    final ok = pendingOtp == code &&
        otpExpiresAt != null &&
        DateTime.now().isBefore(otpExpiresAt!);
    if (ok) {
      pendingOtp = null;
      _ensureMe();
      signedIn = true;
      if (signupName.isEmpty) {
        signupName = me?.publicName ?? 'You';
      }
      saveToPrefs();
      notifyListeners();
    }
    return ok;
  }

  void setSignupIntent(String intent) {
    signupIntent = intent;
    notifyListeners();
  }

  void completeSignupProfile({
    required String name,
    required Gender gender,
    required String bio,
    required List<String> categories,
    String? photoUrl,
  }) {
    signupName = name;
    signupBio = bio;
    signupCategories = categories;
    _ensureMe();
    // Persist the signup profile onto the current member (name, gender,
    // bio, categories chosen during onboarding).
    final m = me!;
    me = Member(
      id: m.id,
      publicName: name,
      email: m.email,
      photoUrl: photoUrl ?? m.photoUrl,
      gender: gender,
      bio: bio,
      completedCount: m.completedCount,
      rating: m.rating,
      ratingCount: m.ratingCount,
      cancellations: m.cancellations,
      noShows: m.noShows,
      accountAgeMonths: m.accountAgeMonths,
      verifiedBadge: m.verifiedBadge,
      isEstablished: m.isEstablished,
      joinedAt: m.joinedAt,
      dateOfBirth: m.dateOfBirth,
      ageGatePassed: m.ageGatePassed,
      categories: categories,
      isEmailVerified: m.isEmailVerified,
      safetyContactName: m.safetyContactName,
      safetyContactPhone: m.safetyContactPhone,
      availabilityHours: m.availabilityHours,
    );
    signedIn = true;
    saveToPrefs();
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    clearPrefs();
    notifyListeners();
  }

  // ── Feed & filters ───────────────────────────────────────────────
  void setFeedSource(String source) {
    feedSource = source;
    notifyListeners();
  }

  void setRadius(double km) {
    radiusKm = km;
    notifyListeners();
  }

  void toggleTypeFilter(PostType t) {
    filterTypes.contains(t) ? filterTypes.remove(t) : filterTypes.add(t);
    notifyListeners();
  }

  void toggleExchangeFilter(ExchangeMode m) {
    filterExchanges.contains(m)
        ? filterExchanges.remove(m)
        : filterExchanges.add(m);
    notifyListeners();
  }

  void toggleGenderFilter(GenderPreference g) {
    filterGenderPrefs.contains(g)
        ? filterGenderPrefs.remove(g)
        : filterGenderPrefs.add(g);
    notifyListeners();
  }

  void setFreeOnly(bool v) {
    filterFreeOnly = v;
    notifyListeners();
  }

  void setQuery(String q) {
    filterQuery = q;
    notifyListeners();
  }

  void setCategory(String c) {
    filterCategory = c;
    notifyListeners();
  }

  void clearFilters() {
    filterTypes.clear();
    filterExchanges.clear();
    filterGenderPrefs.clear();
    filterFreeOnly = false;
    filterQuery = '';
    filterCategory = 'All';
    notifyListeners();
  }

  bool get hasActiveFilters =>
      filterTypes.isNotEmpty ||
      filterExchanges.isNotEmpty ||
      filterGenderPrefs.isNotEmpty ||
      filterFreeOnly ||
      filterQuery.isNotEmpty ||
      filterCategory != 'All';

  List<Task> get feed {
    Iterable<Task> list = tasks.where((t) => t.status == TaskStatus.published);
    final maxKm = feedSource == 'myCity' ? 25.0 : radiusKm;
    list = list.where((t) => t.distanceKm <= maxKm);
    if (filterTypes.isNotEmpty) {
      list = list.where((t) => filterTypes.contains(t.type));
    }
    if (filterExchanges.isNotEmpty) {
      list = list.where((t) => filterExchanges.contains(t.exchange));
    }
    if (filterGenderPrefs.isNotEmpty) {
      list = list.where((t) => filterGenderPrefs.contains(t.genderPreference));
    }
    if (filterFreeOnly) {
      list = list.where((t) => t.isFreeLike);
    }
    if (filterCategory != 'All') {
      list = list.where((t) => t.category == filterCategory);
    }
    if (filterQuery.isNotEmpty) {
      final q = filterQuery.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q));
    }
    return list.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Task> myPosts() =>
      tasks.where((t) => t.creatorId == (me?.id ?? 'u_me')).toList();

  // ── Save / repost ────────────────────────────────────────────────
  bool isSaved(String taskId) => savedTaskIds.contains(taskId);

  void toggleSaved(String taskId) {
    savedTaskIds.contains(taskId)
        ? savedTaskIds.remove(taskId)
        : savedTaskIds.add(taskId);
    notifyListeners();
  }

  bool isReposted(String taskId) => repostedTaskIds.contains(taskId);

  void toggleRepost(String taskId) {
    repostedTaskIds.contains(taskId)
        ? repostedTaskIds.remove(taskId)
        : repostedTaskIds.add(taskId);
    notifyListeners();
  }

  // ── Create ───────────────────────────────────────────────────────
  void postTask(TaskDraft d) {
    _ensureMe();
    final creator = me!;
    // Phase 8 — pre-publication moderation screen.
    final violation = Moderation.screen(d.title, d.description);
    if (violation != null) {
      _pendingModerationBlock = violation;
      notifyListeners();
      return;
    }
    final t = Task(
      id: _Ids.next('t'),
      creatorId: creator.id,
      creatorName: creator.publicName,
      creatorPhotoUrl: creator.photoUrl,
      creatorVerified: creator.verifiedBadge,
      creatorRating: creator.rating,
      creatorCompleted: creator.completedCount,
      genderPreference: d.genderPreference,
      type: d.type,
      kind: d.kind,
      payoutNote: d.payoutNote,
      title: d.title,
      description: d.description,
      category: d.category,
      scheduledAt: d.scheduledAt,
      durationMinutes: d.durationMinutes,
      area: d.area,
      distanceKm: 1.0,
      exchange: d.exchange,
      rewardAmount: d.rewardAmount,
      capacity: d.capacity,
      applicantCount: 0,
      risk: _riskFor(d),
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: d.meetingPreference,
      hasCheckin: d.hasCheckin,
    );
    tasks.add(t);
    notifyListeners();
  }

  TaskRisk _riskFor(TaskDraft d) {
    if (d.scheduledAt.hour >= 21 || d.scheduledAt.hour <= 5) {
      return TaskRisk.high;
    }
    if (d.durationMinutes > 180) return TaskRisk.medium;
    return TaskRisk.low;
  }

  // ── Applications & selection ─────────────────────────────────────
  List<MockApplication> applicationsForTask(String taskId) =>
      applications.where((a) => a.taskId == taskId).toList();

  List<MockApplication> myApplications() =>
      applications.where((a) => a.memberId == (me?.id ?? 'u_me')).toList();

  bool hasApplied(String taskId) =>
      myApplications().any((a) => a.taskId == taskId);

  MockApplication? applyToTask(String taskId, String intro) {
    if (hasApplied(taskId)) return null;
    // Gender-restricted posts (girls-only / boys-only) are a safety
    // feature: eligibility is enforced here, not just in the UI.
    final t = taskById(taskId);
    if (t != null && !t.genderPreference.admits(me?.gender)) {
      return null;
    }
    final app = MockApplication(
      id: _Ids.next('a'),
      taskId: taskId,
      memberId: me?.id ?? 'u_me',
      introMessage: intro,
      status: ApplicationStatus.chatting,
      createdAt: DateTime.now(),
    );
    applications.add(app);
    if (t != null) {
      _replaceTask(t, t.copyWith(applicantCount: t.applicantCount + 1));
    }
    sendMessage(
      app.id,
      'Hi! Thanks for showing interest. Tell me a bit about yourself?',
      fromCreator: true,
    );
    notifyListeners();
    return app;
  }

  void withdrawApplication(String appId) {
    for (final a in applications) {
      if (a.id == appId) {
        a.status = ApplicationStatus.withdrawn;
        final t = taskById(a.taskId);
        if (t != null && t.applicantCount > 0) {
          _replaceTask(t, t.copyWith(applicantCount: t.applicantCount - 1));
        }
      }
    }
    notifyListeners();
  }

  void selectApplicant(String appId) {
    MockApplication? target;
    for (final a in applications) {
      if (a.id == appId) {
        a.status = ApplicationStatus.selected;
        target = a;
        break;
      }
    }
    if (target != null) {
      for (final a in applications) {
        if (a.taskId == target.taskId &&
            a.id != appId &&
            a.status != ApplicationStatus.withdrawn) {
          a.status = ApplicationStatus.declined;
        }
      }
      final t = taskById(target.taskId);
      if (t != null) {
        _replaceTask(t, t.copyWith(status: TaskStatus.confirmed));
      }
    }
    notifyListeners();
  }

  void startTask(String taskId) {
    final t = taskById(taskId);
    if (t != null) _replaceTask(t, t.copyWith(status: TaskStatus.active));
    notifyListeners();
  }

  void completeTask(String taskId) {
    final t = taskById(taskId);
    if (t != null) _replaceTask(t, t.copyWith(status: TaskStatus.completed));
    notifyListeners();
  }

  void cancelTask(String taskId) {
    final t = taskById(taskId);
    if (t != null) _replaceTask(t, t.copyWith(status: TaskStatus.cancelled));
    notifyListeners();
  }

  // ── Chat ─────────────────────────────────────────────────────────
  List<MockMessage> messagesFor(String applicationId) =>
      roomMessages[applicationId] ?? const [];

  void sendMessage(String applicationId, String body,
      {bool fromCreator = false}) {
    final list = roomMessages.putIfAbsent(applicationId, () => []);
    list.add(MockMessage(
      id: _Ids.next('m'),
      applicationId: applicationId,
      senderId: fromCreator ? 'creator' : (me?.id ?? 'u_me'),
      body: body,
      createdAt: DateTime.now(),
    ));
    if (fromCreator) {
      for (final a in applications) {
        if (a.id == applicationId) a.unreadForApplicant += 1;
      }
    }
    notifyListeners();
  }

  void markRoomRead(String applicationId) {
    for (final a in applications) {
      if (a.id == applicationId) {
        a.unreadForApplicant = 0;
        a.unreadForCreator = 0;
      }
    }
    notifyListeners();
  }

  int get totalUnreadRooms => myApplications()
      .where((a) => a.status != ApplicationStatus.withdrawn)
      .fold(0, (sum, a) => sum + a.unreadForApplicant);

  // ── Ratings & safety ─────────────────────────────────────────────
  void submitRating(String taskId, double stars, String note) {
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Rating submitted',
        body: 'Thanks — you rated $stars★${note.isEmpty ? '' : ' with a note'}.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ── Notifications ────────────────────────────────────────────────
  int get unreadNotifications => notifications.where((n) => !n.read).length;

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  // ── Auctions System ──────────────────────────────────────────────
  List<AuctionItem> get auctions => _auctions;
  final List<AuctionItem> _auctions = List.from(kSeedAuctions);

  AuctionItem? getAuctionById(String id) {
    try {
      return _auctions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  bool placeBid(String auctionId, double amount) {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx < 0) return false;
    final auc = _auctions[idx];
    if (amount <= auc.currentBid) return false;

    final user = me ?? kSeedMembers[0];
    final newBid = AuctionBid(
      id: _Ids.next('b'),
      bidderId: user.id,
      bidderName: user.publicName,
      bidderPhotoUrl: user.photoUrl,
      amount: amount,
      timestamp: DateTime.now(),
    );

    final updatedHistory = List<AuctionBid>.from(auc.bidHistory)..insert(0, newBid);
    _auctions[idx] = auc.copyWith(
      currentBid: amount,
      totalBids: auc.totalBids + 1,
      bidHistory: updatedHistory,
    );

    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Bid Placed Successfully! 🔨',
        body:
            'Your bid of ₹${amount.toStringAsFixed(0)} for "${auc.title}" is now the highest bid.',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  AuctionItem createAuction({
    required String title,
    required String description,
    required String category,
    required String imageUrl,
    required double basePrice,
    double? buyItNowPrice,
    required int durationHours,
    required String area,
  }) {
    final user = me ?? kSeedMembers[0];
    final newAuc = AuctionItem(
      id: _Ids.next('auc'),
      title: title,
      description: description,
      category: category,
      imageUrl: imageUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&auto=format&fit=crop'
          : imageUrl,
      sellerId: user.id,
      sellerName: user.publicName,
      sellerPhotoUrl: user.photoUrl,
      sellerVerified: user.verifiedBadge,
      sellerRating: user.rating,
      basePrice: basePrice,
      currentBid: basePrice,
      buyItNowPrice: buyItNowPrice,
      serviceFeePercent: 5.0,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: durationHours)),
      totalBids: 0,
      status: AuctionStatus.active,
      bidHistory: [],
      area: area.isEmpty ? 'Madiwala Central' : area,
      distanceKm: 0.5,
    );

    _auctions.insert(0, newAuc);

    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Auction Published 🎉',
        body: '"$title" is now live for bidding!',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return newAuc;
  }

  // ── Phase 1 · Emergency Helpers ───────────────────────────────
  List<Task> get emergencyFeed => tasks
      .where((t) =>
          t.kind == PostKind.emergency &&
          !quarantinedTaskIds.contains(t.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Member> get availableHelpers =>
      members.where((m) => m.availableNow || m.isGuardian).toList();

  int get guardianCount => members.where((m) => m.isGuardian).length;

  int get availableNowCount => members.where((m) => m.availableNow).length;

  void toggleAvailableNow() {
    _ensureMe();
    me = me!.copyMemberWith(availableNow: !me!.availableNow);
    notifyListeners();
  }

  void toggleGuardianShield() {
    _ensureMe();
    me = me!.copyMemberWith(isGuardian: !me!.isGuardian);
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: me!.isGuardian
            ? 'Guardian Shield active 🛡️'
            : 'Guardian Shield paused',
        body: me!.isGuardian
            ? 'You now receive priority SOS dispatches in Madiwala.'
            : 'You can re-enable any time from your profile.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Broadcast an SOS emergency request — high priority, wide radius.
  Task broadcastEmergency({
    required String title,
    required String description,
    required String area,
    int durationMinutes = 60,
    GenderPreference genderPref = GenderPreference.anyone,
  }) {
    _ensureMe();
    final creator = me!;
    final t = Task(
      id: _Ids.next('t'),
      creatorId: creator.id,
      creatorName: creator.publicName,
      creatorPhotoUrl: creator.photoUrl,
      creatorVerified: creator.verifiedBadge,
      creatorRating: creator.rating,
      creatorCompleted: creator.completedCount,
      type: PostType.task,
      kind: PostKind.emergency,
      title: title,
      description: description,
      category: 'Emergency',
      scheduledAt: DateTime.now(),
      durationMinutes: durationMinutes,
      area: area,
      distanceKm: 0.4,
      exchange: ExchangeMode.free,
      rewardAmount: 0,
      capacity: 1,
      applicantCount: 0,
      genderPreference: genderPref,
      risk: TaskRisk.high,
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: 'Shared in chat',
      hasCheckin: true,
    );
    tasks.add(t);
    final helpers = availableHelpers.length;
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'SOS broadcast sent',
        body: '$helpers nearby helpers (incl. $guardianCount Guardians) alerted.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return t;
  }

  // ── Phase 2 · Shop Gigs ──────────────────────────────────────
  List<Task> get gigFeed => tasks
      .where((t) => t.kind == PostKind.gig && !quarantinedTaskIds.contains(t.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Task postGig({
    required String shopName,
    required String role,
    required String description,
    required String area,
    required double dailyPay,
    required int days,
    required int workers,
  }) {
    _ensureMe();
    final creator = me!;
    final t = Task(
      id: _Ids.next('t'),
      creatorId: creator.id,
      creatorName: shopName,
      creatorPhotoUrl: creator.photoUrl,
      creatorVerified: creator.verifiedBadge,
      creatorRating: creator.rating,
      creatorCompleted: creator.completedCount,
      type: PostType.task,
      kind: PostKind.gig,
      payoutNote: '₹${dailyPay.toStringAsFixed(0)}/day · $days days',
      title: role,
      description: description,
      category: 'Gigs',
      scheduledAt: DateTime.now().add(const Duration(hours: 12)),
      durationMinutes: days * 8 * 60,
      area: area,
      distanceKm: 0.9,
      exchange: ExchangeMode.paid,
      rewardAmount: dailyPay * days,
      capacity: workers,
      applicantCount: 0,
      risk: TaskRisk.low,
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: 'At the shop',
      hasCheckin: false,
    );
    tasks.add(t);
    notifyListeners();
    return t;
  }

  // ── Phase 3 · Room Finder ────────────────────────────────────
  List<Task> get roomFeed => tasks
      .where((t) => t.kind == PostKind.room && !quarantinedTaskIds.contains(t.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Task postRoomRequest({
    required String title,
    required String description,
    required String area,
    required double budget,
    required String roomType,
    double finderFee = 500,
    GenderPreference genderPref = GenderPreference.anyone,
  }) {
    _ensureMe();
    final creator = me!;
    final t = Task(
      id: _Ids.next('t'),
      creatorId: creator.id,
      creatorName: creator.publicName,
      creatorPhotoUrl: creator.photoUrl,
      creatorVerified: creator.verifiedBadge,
      creatorRating: creator.rating,
      creatorCompleted: creator.completedCount,
      type: PostType.task,
      kind: PostKind.room,
      payoutNote: '$roomType under ₹${budget.toStringAsFixed(0)}',
      title: title,
      description: description,
      category: 'Rooms',
      scheduledAt: DateTime.now().add(const Duration(hours: 24)),
      durationMinutes: 60,
      area: area,
      distanceKm: 1.2,
      exchange: ExchangeMode.paid,
      rewardAmount: finderFee,
      capacity: 1,
      applicantCount: 0,
      genderPreference: genderPref,
      risk: TaskRisk.low,
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: 'At the room',
      hasCheckin: false,
    );
    tasks.add(t);
    notifyListeners();
    return t;
  }

  // ── Phase 4 · Make Team & Trips ──────────────────────────
  List<Task> get teamFeed => tasks
      .where((t) =>
          (t.kind == PostKind.team || t.kind == PostKind.trip) &&
          !quarantinedTaskIds.contains(t.id))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  Task postTeamPost({
    required PostKind kind,
    required String title,
    required String description,
    required String area,
    required DateTime when,
    required int headcount,
    String destination = '',
    ExchangeMode exchange = ExchangeMode.free,
    double splitPerHead = 0,
    GenderPreference genderPref = GenderPreference.anyone,
  }) {
    _ensureMe();
    final creator = me!;
    final t = Task(
      id: _Ids.next('t'),
      creatorId: creator.id,
      creatorName: creator.publicName,
      creatorPhotoUrl: creator.photoUrl,
      creatorVerified: creator.verifiedBadge,
      creatorRating: creator.rating,
      creatorCompleted: creator.completedCount,
      type: PostType.company,
      kind: kind,
      payoutNote: destination,
      title: title,
      description: description,
      category: kind == PostKind.trip ? 'Trips' : 'Teams',
      scheduledAt: when,
      durationMinutes: kind == PostKind.trip ? 8 * 60 : 120,
      area: area,
      distanceKm: kind == PostKind.trip ? 25 : 1.0,
      exchange: exchange,
      rewardAmount: splitPerHead,
      capacity: headcount,
      applicantCount: 0,
      genderPreference: genderPref,
      risk: kind == PostKind.trip ? TaskRisk.medium : TaskRisk.low,
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: 'Public meeting point',
      hasCheckin: kind == PostKind.trip,
    );
    tasks.add(t);
    notifyListeners();
    return t;
  }

  /// UPI split helper — per-head amount for a group post.
  String upiSplitPerHead(double total, int heads) {
    if (heads <= 0) return '₹0';
    return '₹${(total / heads).toStringAsFixed(0)} per head';
  }

  // ── Karma wallet (Time Credits) ──────────────────────────
  void earnKarma(int amount, String reason) {
    _ensureMe();
    me = me!.copyMemberWith(karma: me!.karma + amount);
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: '+$amount Time Credits',
        body: reason,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool spendKarma(int amount, String reason) {
    _ensureMe();
    if (me!.karma < amount) return false;
    me = me!.copyMemberWith(karma: me!.karma - amount);
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Voucher claimed',
        body: reason,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  // ── Phase 6 · Play & Earn ────────────────────────────────
  final Set<String> _playedChallenges = {};

  bool hasPlayedToday(String challengeId) =>
      _playedChallenges.contains(challengeId);

  void recordPlay({
    required String challengeId,
    required int score,
    required int target,
    required int rewardKarma,
  }) {
    _playedChallenges.add(challengeId);
    if (score >= target) {
      earnKarma(rewardKarma, 'You beat the target in a Play & Earn challenge!');
    } else {
      earnKarma(10, 'Thanks for playing — come back tomorrow!');
    }
  }

  // ── Phase 7 · Partner Perks ──────────────────────────────
  final Set<String> _claimedPerks = {};

  bool isPerkClaimed(String perkId) => _claimedPerks.contains(perkId);

  bool claimPerk(PartnerPerk perk) {
    if (_claimedPerks.contains(perk.id)) return false;
    if (!spendKarma(
        perk.costKarma, '${perk.merchant} voucher claimed — show the app at the counter.')) {
      return false;
    }
    _claimedPerks.add(perk.id);
    return true;
  }

  // ── Phase 8 · Moderation, badges, quarantine ─────────────
  final Set<String> quarantinedTaskIds = {};

  void quarantineTask(String taskId, String reason) {
    quarantinedTaskIds.add(taskId);
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Post quarantined',
        body: 'A post was hidden pending review — $reason',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void reportTask(String taskId, String reason, String details) {
    quarantineTask(taskId, 'reported as $reason');
    notifications.insert(
      0,
      MockNotification(
        id: _Ids.next('n'),
        title: 'Report received',
        body: 'Our safety team will review "$reason" within 24 hours.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void awardBadge(TrustBadge badge) {
    _ensureMe();
    final next = Set<TrustBadge>.from(me!.badges)..add(badge);
    me = me!.copyMemberWith(badges: next);
    notifyListeners();
  }

  // ── Phase 9 · Community board ────────────────────────────
  List<BoardIdea> get boardIdeas => _boardIdeas.toList()
    ..sort((a, b) => b.upvotes.compareTo(a.upvotes));

  final List<BoardIdea> _boardIdeas = List.from(kSeedBoardIdeas);

  void submitIdea(String title, String details, String tag) {
    _ensureMe();
    _boardIdeas.insert(
      0,
      BoardIdea(
        id: _Ids.next('i'),
        authorId: me!.id,
        authorName: me!.publicName,
        authorPhotoUrl: me!.photoUrl,
        title: title,
        details: details,
        tag: tag,
        upvotes: 1,
        createdAt: DateTime.now(),
        votedByMe: true,
      ),
    );
    earnKarma(15, 'Idea published on the community board.');
  }

  void toggleIdeaVote(String ideaId) {
    for (var i = 0; i < _boardIdeas.length; i++) {
      final idea = _boardIdeas[i];
      if (idea.id == ideaId) {
        _boardIdeas[i] = idea.copyWithVoted(
          voted: !idea.votedByMe,
          upvotes: idea.votedByMe ? idea.upvotes - 1 : idea.upvotes + 1,
        );
      }
    }
    notifyListeners();
  }

  // ── Internal ─────────────────────────────────────────────────────
  void _replaceTask(Task oldT, Task newT) {
    final i = tasks.indexOf(oldT);
    if (i >= 0) tasks[i] = newT;
  }
}

/// Seed Auctions for Madiwala micro-marketplace.
final List<AuctionItem> kSeedAuctions = [
  AuctionItem(
    id: 'auc_1',
    title: 'Wooden Gaming Desk & Ergonomic Chair Set',
    description:
        'Vacating flat in Madiwala 5th Block. Selling high-grade teak desk + ergonomic mesh chair. Perfect condition, 6 months old.',
    category: 'Home & Room',
    imageUrl:
        'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&auto=format&fit=crop',
    sellerId: 'u1',
    sellerName: 'Ayesha Khan',
    sellerPhotoUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=256&h=256&fit=crop&crop=faces&auto=format',
    sellerVerified: true,
    sellerRating: 4.9,
    basePrice: 1500,
    currentBid: 2800,
    buyItNowPrice: 4500,
    serviceFeePercent: 5.0,
    startTime: DateTime.now().subtract(const Duration(hours: 12)),
    endTime: DateTime.now().add(const Duration(hours: 4, minutes: 25)),
    totalBids: 14,
    status: AuctionStatus.active,
    area: 'Madiwala · 5th Block',
    distanceKm: 0.6,
    bidHistory: [
      AuctionBid(
        id: 'b1',
        bidderId: 'u5',
        bidderName: 'Karthik S',
        bidderPhotoUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=256&h=256&fit=crop&crop=faces&auto=format',
        amount: 2800,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      AuctionBid(
        id: 'b2',
        bidderId: 'u2',
        bidderName: 'Ravi Kumar',
        bidderPhotoUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=256&h=256&fit=crop&crop=faces&auto=format',
        amount: 2500,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
  ),
  AuctionItem(
    id: 'auc_2',
    title: '1-on-1 Flutter & UI/UX Portfolio Consultation (2 Hours)',
    description:
        'Offering 2 hours of live code review, portfolio critique, and Flutter architecture mentoring. Verified senior dev.',
    category: 'Time & Service',
    imageUrl:
        'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=600&auto=format&fit=crop',
    sellerId: 'u2',
    sellerName: 'Ravi Kumar',
    sellerPhotoUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=256&h=256&fit=crop&crop=faces&auto=format',
    sellerVerified: true,
    sellerRating: 4.8,
    basePrice: 500,
    currentBid: 1200,
    buyItNowPrice: 2000,
    serviceFeePercent: 5.0,
    startTime: DateTime.now().subtract(const Duration(hours: 6)),
    endTime: DateTime.now().add(const Duration(hours: 1, minutes: 10)),
    totalBids: 9,
    status: AuctionStatus.endingSoon,
    area: 'Online / Madiwala Cafe',
    distanceKm: 0.3,
    bidHistory: [
      AuctionBid(
        id: 'b3',
        bidderId: 'u7',
        bidderName: 'Imran Ali',
        bidderPhotoUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=256&h=256&fit=crop&crop=faces&auto=format',
        amount: 1200,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  ),
  AuctionItem(
    id: 'auc_3',
    title: 'Sony WH-1000XM4 Noise Canceling Headphones',
    description:
        'Barely used for 2 months, original box and bill available. Selling because I upgraded.',
    category: 'Gadgets',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop',
    sellerId: 'u4',
    sellerName: 'Sana Reddy',
    sellerPhotoUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=256&h=256&fit=crop&crop=faces&auto=format',
    sellerVerified: true,
    sellerRating: 4.9,
    basePrice: 5000,
    currentBid: 9500,
    buyItNowPrice: 14000,
    serviceFeePercent: 5.0,
    startTime: DateTime.now().subtract(const Duration(hours: 24)),
    endTime: DateTime.now().add(const Duration(hours: 18, minutes: 40)),
    totalBids: 22,
    status: AuctionStatus.active,
    area: 'Madiwala · Jyoti Nivas Lane',
    distanceKm: 1.1,
    bidHistory: [],
  ),
  AuctionItem(
    id: 'auc_4',
    title: 'Vintage Leather Jacket (Unisex, Size M)',
    description:
        'Genuine vintage dark brown leather jacket. Excellent condition, polished.',
    category: 'Fashion & Wear',
    imageUrl:
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop',
    sellerId: 'u8',
    sellerName: 'Divya Sharma',
    sellerPhotoUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=256&h=256&fit=crop&crop=faces&auto=format',
    sellerVerified: false,
    sellerRating: 4.8,
    basePrice: 800,
    currentBid: 1400,
    buyItNowPrice: 2500,
    serviceFeePercent: 5.0,
    startTime: DateTime.now().subtract(const Duration(hours: 18)),
    endTime: DateTime.now().add(const Duration(hours: 8, minutes: 15)),
    totalBids: 7,
    status: AuctionStatus.active,
    area: 'Madiwala · Koramangala Border',
    distanceKm: 1.4,
    bidHistory: [],
  ),
];

extension _TaskCopy on Task {
  Task copyWith({
    int? applicantCount,
    TaskStatus? status,
    GenderPreference? genderPreference,
  }) {
    return Task(
      id: id,
      creatorId: creatorId,
      creatorName: creatorName,
      creatorPhotoUrl: creatorPhotoUrl,
      creatorVerified: creatorVerified,
      creatorRating: creatorRating,
      creatorCompleted: creatorCompleted,
      type: type,
      title: title,
      description: description,
      category: category,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      area: area,
      distanceKm: distanceKm,
      exchange: exchange,
      rewardAmount: rewardAmount,
      capacity: capacity,
      applicantCount: applicantCount ?? this.applicantCount,
      risk: risk,
      status: status ?? this.status,
      createdAt: createdAt,
      meetingPreference: meetingPreference,
      hasCheckin: hasCheckin,
    );
  }
}

// ── Seeds for the new phases ───────────────────────────────────────

/// Phase 9 — community board seed ideas.
final List<BoardIdea> kSeedBoardIdeas = [
  BoardIdea(
    id: 'i1',
    authorId: 'u1',
    authorName: 'Ayesha Khan',
    authorPhotoUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=256&h=256&fit=crop&crop=faces&auto=format',
    title: 'Madiwala Lake morning walk club',
    details:
        'A daily 7 AM walk around the lake — 3 laps, filter coffee after. Slowly it becomes the neighbourhood\'s alarm clock.',
    tag: 'Walk',
    upvotes: 34,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    scheduled: true,
  ),
  BoardIdea(
    id: 'i2',
    authorId: 'u2',
    authorName: 'Ravi Kumar',
    authorPhotoUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=256&h=256&fit=crop&crop=faces&auto=format',
    title: 'Sunday football at JP Park ground',
    details:
        'Casual 7-a-side, 6:30 AM every Sunday. All skill levels — we rotate teams so it stays friendly.',
    tag: 'Sports',
    upvotes: 27,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  BoardIdea(
    id: 'i3',
    authorId: 'u8',
    authorName: 'Divya Sharma',
    authorPhotoUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=256&h=256&fit=crop&crop=faces&auto=format',
    title: 'Weekend sketching meetup at the museum steps',
    details:
        'Bring anything that draws — pencils, pens, charcoal. Two hours of quiet sketching together, then chai.',
    tag: 'Meetup',
    upvotes: 19,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  BoardIdea(
    id: 'i4',
    authorId: 'u7',
    authorName: 'Imran Ali',
    authorPhotoUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=256&h=256&fit=crop&crop=faces&auto=format',
    title: 'Skill-swap evening: teach 1, learn 1',
    details:
        'Everyone teaches something for 15 minutes — guitar chords, Excel tricks, bike repair. Monthly at the library cafe.',
    tag: 'Feature',
    upvotes: 12,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

/// Phase 7 — partner merchant perks (voucher cost in Time Credits).
final List<PartnerPerk> kSeedPerks = [
  PartnerPerk(
    id: 'p1',
    merchant: 'Brahmins\' Coffee Bar',
    title: 'Free filter coffee',
    details: 'Any brew on the menu, on the house when you show the voucher.',
    emojiIcon: Icons.local_cafe_rounded,
    costKarma: 120,
    area: 'Shankarapuram, 5 min away',
    validHours: 24,
    gradient: [AppColors.auroraAmber, AppColors.auroraCoral],
  ),
  PartnerPerk(
    id: 'p2',
    merchant: 'Nagarjuna Meals',
    title: '20% off biryani (2+ people)',
    details: 'Flat discount on dine-in for groups of two or more nuvra members.',
    emojiIcon: Icons.restaurant_rounded,
    costKarma: 200,
    area: 'Madiwala Main Rd',
    validHours: 72,
    gradient: [AppColors.auroraCoral, AppColors.auroraViolet],
  ),
  PartnerPerk(
    id: 'p3',
    merchant: 'Corner House',
    title: 'Buy 1 get 1 sundae',
    details: 'Grab a friend — second sundae free with the voucher.',
    emojiIcon: Icons.icecream_rounded,
    costKarma: 90,
    area: 'Jyoti Nivas Lane',
    validHours: 48,
    gradient: [AppColors.auroraSky, AppColors.auroraMint],
  ),
  PartnerPerk(
    id: 'p4',
    merchant: 'Madiwala Cycle Works',
    title: 'Free bike tune-up',
    details: 'Brake & gear tune-up free with any purchase, or 100 credits standalone.',
    emojiIcon: Icons.pedal_bike_rounded,
    costKarma: 100,
    area: '5th Block',
    validHours: 168,
    gradient: [AppColors.auroraViolet, AppColors.auroraLilac],
  ),
];

/// Phase 6 — Play & Earn challenges.
final List<PlayChallenge> kSeedChallenges = [
  PlayChallenge(
    id: 'tap30',
    title: 'Reflex Rush',
    rules: 'Tap the glowing orb as it jumps around — 30 seconds. Beat the target to earn full Time Credits.',
    target: 25,
    rewardKarma: 60,
    icon: Icons.touch_app_rounded,
    gradient: [AppColors.auroraMint, AppColors.auroraSky],
  ),
  PlayChallenge(
    id: 'memory',
    title: 'Colour Echo',
    rules: 'Repeat the colour sequence — it grows every round. How far does your memory echo?',
    target: 6,
    rewardKarma: 80,
    icon: Icons.psychology_rounded,
    gradient: [AppColors.auroraViolet, AppColors.auroraLilac],
  ),
];

/// Bored Radar — ambient neighbourhood pulse (counts drift each minute).
final List<({String zone, int free, int tasks, int tea})> kSeedRadar = [
  (zone: 'Jyoti Nivas Lane', free: 18, tasks: 5, tea: 7),
  (zone: '5th Block', free: 11, tasks: 3, tea: 4),
  (zone: 'Madiwala Market', free: 9, tasks: 6, tea: 2),
  (zone: 'BTM Border', free: 14, tasks: 2, tea: 8),
];
