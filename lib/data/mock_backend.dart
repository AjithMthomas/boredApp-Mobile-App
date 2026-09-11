// Madiwala seed content + in-memory mock backend.
// Swap `MockBackend` for the API implementation in Stage 2 — interfaces match.
import 'package:flutter/foundation.dart';

import '../core/models/models.dart';
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
      completed: 42, rating: 4.9, ratings: 50, months: 8, verified: true),
  _member('u2', 'Ravi Kumar', 'Bike mechanic near Jyoti Nivas. Weekend cricketer.',
      photo: _p('1507003211169-0a1dd7228f2d'),
      gender: Gender.male,
      completed: 67, rating: 4.7, ratings: 80, months: 11, verified: true),
  _member('u3', 'Meera Nair', 'Final year BA. Happy to accompany for errands.',
      photo: _p('1438761681033-6461ffad8d80'),
      completed: 18, rating: 4.8, ratings: 22, months: 3, verified: false),
  _member('u4', 'Sana Reddy', 'Nursing student. Free Sunday mornings.',
      photo: _p('1544005313-94ddf0286df2'),
      completed: 25, rating: 4.9, ratings: 30, months: 5, verified: true),
  _member('u5', 'Karthik S', 'IT guy. Can carry heavy stuff, has a bike.',
      photo: _p('1500648767791-00dcc994a43e'),
      gender: Gender.male,
      completed: 31, rating: 4.6, ratings: 36, months: 6, verified: false),
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
  );
}

/// Madiwala seed feed — every post type and exchange mode represented.
final List<Task> kSeedTasks = [
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
}) {
  final scheduled = DateTime.now().add(Duration(hours: inHours));
  return Task(
    id: id,
    creatorId: creator.id,
    creatorName: creator.publicName,
    creatorPhotoUrl: creator.photoUrl,
    creatorVerified: creator.verifiedBadge,
    creatorRating: creator.rating,
    creatorCompleted: creator.completedCount,
    type: type,
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
      title: 'Welcome to TIME~NEED',
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
      photoUrl: m.photoUrl,
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
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
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

  void reportTask(String taskId, String reason, String details) {
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

  // ── Notifications ────────────────────────────────────────────────
  int get unreadNotifications => notifications.where((n) => !n.read).length;

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  // ── Internal ─────────────────────────────────────────────────────
  void _replaceTask(Task oldT, Task newT) {
    final i = tasks.indexOf(oldT);
    if (i >= 0) tasks[i] = newT;
  }
}

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
      genderPreference: genderPreference ?? this.genderPreference,
      risk: risk,
      status: status ?? this.status,
      createdAt: createdAt,
      meetingPreference: meetingPreference,
      hasCheckin: hasCheckin,
    );
  }
}
