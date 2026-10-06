// ApiBackend — drop-in replacement for MockBackend.
//
// Same method names as MockBackend so screens never change; every call
// fires the network request in the background and applies results to a
// local cache that notifies listeners (optimistic updates, offline
// tolerant). Toggle via --dart-define=NEEDY_USE_API=true.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/models.dart';
import '../../core/moderation.dart';
import '../backend_contract.dart';
import '../mock_backend.dart';
import 'api_client.dart';
import 'api_dto.dart';
import 'api_models.dart';

class ApiBackend extends ChangeNotifier implements BackendContract {
  ApiBackend({ApiClient? client}) : _api = client ?? ApiClient() {
    _bootstrap();
  }

  final ApiClient _api;

  /// User-facing rejections (see BackendContract.errors).
  final _errors = StreamController<String>.broadcast();

  // ── Local cache (what the UI renders) ──────────────────────────────
  List<Task> tasks = [];
  List<Member> members = [];
  List<MockApplication> applications = [];
  final Map<String, List<MockMessage>> roomMessages = {};
  List<MockNotification> notifications = [];
  List<AuctionItem> auctions = [];
  List<BoardIdea> boardIdeas = [];
  List<RadarZoneData> radarZones = List.of(kSeedRadarZones);
  final Set<String> savedTaskIds = {};
  final Set<String> repostedTaskIds = {}; // 'repost:<taskId>' keys
  final Set<String> quarantinedTaskIds = {}; // server-truth via feed filter
  final Set<String> playedToday = {};
  final Map<String, String> _roomIds = {}; // applicationId -> roomId
  final Set<String> claimedPerks = {};
  int karmaBalance = 0;

  // Auth state (field names mirror MockBackend — the UI reads these).
  bool signedIn = false;
  bool profileCompleted = false;
  bool booted = false;
  String? pendingEmail;
  String signupName = '';
  String signupBio = '';
  String signupIntent = 'both';
  List<String> signupCategories = [];
  Member? me;

  // Filter state — identical fields to MockBackend (Discover owns them).
  String feedSource = 'nearby';
  double radiusKm = 3;
  final Set<PostType> filterTypes = {};
  final Set<ExchangeMode> filterExchanges = {};
  final Set<GenderPreference> filterGenderPrefs = {};
  bool filterFreeOnly = false;
  String filterQuery = '';
  String filterCategory = 'All';

  // Catalogs: server-driven, seed lists as offline fallback.
  List<PartnerPerk> perks = List.of(kSeedPerks);
  List<PlayChallenge> challenges = List.of(kSeedChallenges);

  void _changed() => notifyListeners();

  /// Failures that are background refreshes or have dedicated inline UI —
  /// logged for debugging but never surfaced as a global snackbar.
  static const _silentFailures = {
    'me', '_loadLocalSession', '_saveLocalSession', //
    '_refreshFeed', '_refreshMembers', '_refreshAuctions', //
    '_refreshNotifications', '_refreshKarma', '_refreshRooms', //
    'perks', 'challenges', 'ideas', '_syncMessages', 'markRoomRead', //
    'requestOtp', 'verifyOtp', // auth screens have inline error text
  };

  void _log(String where, Object error) {
    debugPrint('[needy-api] $where: $error');
    if (error is ApiError && !_silentFailures.contains(where)) {
      _errors.add(error.message);
    }
  }

  @override
  Stream<String> get errors => _errors.stream;

  @override
  void dispose() {
    _errors.close();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _api.loadTokens();
    await _loadLocalSession();
    booted = true;
    _changed();
    if (signedIn) unawaited(refreshAll());
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _refreshFeed(),
      _refreshMembers(),
      _refreshAuctions(),
      _refreshNotifications(),
      _refreshKarma(),
      _refreshRooms(),
      _refreshEngagement(),
    ]);
    _changed();
  }

  // ── Auth ───────────────────────────────────────────────────────────
  void requestOtp(String email) {
    pendingEmail = email;
    _changed();
    unawaited(() async {
      try {
        await _api.post('/api/v1/auth/otp/request', {'email': email});
      } on ApiError catch (e) {
        _log('requestOtp', e);
      }
    }());
  }

  /// Synchronous facade (the OTP screen navigates on `true`):
  /// verification runs in the background and notifies when the session
  /// lands.
  bool verifyOtp(String code) {
    final email = pendingEmail;
    if (email == null) return false;
    unawaited(() async {
      try {
        final data = await _api
            .post('/api/v1/auth/otp/verify', {'email': email, 'code': code})
            .timeout(const Duration(seconds: 10));
        await _applyAuthPayload(data as Map<String, dynamic>);
      } on ApiError catch (e) {
        _log('verifyOtp', e);
      }
    }());
    return true;
  }

  Future<void> _applyAuthPayload(Map<String, dynamic> data) async {
    await _api.saveTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
    );
    me = memberFromJson(data['member'] as Map<String, dynamic>);
    profileCompleted = data['profile_completed'] as bool? ?? false;
    signedIn = true;
    signupName = me!.publicName;
    await _saveLocalSession();
    unawaited(refreshAll());
  }

  Future<void> _loadLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      signedIn = prefs.getBool('needy_signed_in') ?? prefs.getBool('needy_signed_in') ?? false;
      pendingEmail = prefs.getString('needy_email') ?? prefs.getString('needy_email');
      signupName = prefs.getString('needy_name') ?? prefs.getString('needy_name') ?? '';
      signupBio = prefs.getString('needy_bio') ?? prefs.getString('needy_bio') ?? '';
      signupCategories = prefs.getStringList('needy_categories') ?? prefs.getStringList('needy_categories') ?? [];
      if (signedIn && _api.hasToken) {
        try {
          final data = await _api.get('/api/v1/me') as Map<String, dynamic>;
          me = memberFromJson(data);
          profileCompleted =
              me!.categories.isNotEmpty; // heuristic: onboarded members picked categories
        } on ApiError catch (e) {
          _log('me', e);
        }
      }
    } catch (e) {
      _log('_loadLocalSession', e);
    }
  }

  Future<void> _saveLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('needy_signed_in', signedIn);
      if (pendingEmail != null) await prefs.setString('needy_email', pendingEmail!);
      await prefs.setString('needy_name', signupName);
      await prefs.setString('needy_bio', signupBio);
      await prefs.setStringList('needy_categories', signupCategories);
    } catch (e) {
      _log('_saveLocalSession', e);
    }
  }

  void setSignupIntent(String intent) {
    signupIntent = intent;
    _changed();
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
    signedIn = true;
    _changed();
    unawaited(() async {
      try {
        final data = await _api
            .post('/api/v1/me/complete-profile', {
          'name': name,
          'gender': gender.name,
          'bio': bio,
          'categories': categories,
          if (photoUrl != null) 'photo_url': photoUrl,
        }) as Map<String, dynamic>;
        me = memberFromJson(data['member'] as Map<String, dynamic>);
        profileCompleted = true;
        await _api.saveTokens(
          access: data['access'] as String,
          refresh: data['refresh'] as String,
        );
        await _saveLocalSession();
        unawaited(refreshAll());
      } on ApiError catch (e) {
        _log('completeSignupProfile', e);
      }
      _changed();
    }());
  }

  void signOut() {
    signedIn = false;
    me = null;
    _changed();
    unawaited(_api.clearTokens());
  }

  Member? get currentUser => me;

  // ── Feed & filters ─────────────────────────────────────────────────
  void setFeedSource(String source) {
    feedSource = source;
    _changed();
    unawaited(_refreshFeed());
  }

  void setRadius(double km) {
    radiusKm = km;
    _changed();
    unawaited(_refreshFeed());
  }

  void toggleTypeFilter(PostType t) => _toggleAndReload(filterTypes, t);

  void toggleExchangeFilter(ExchangeMode m) => _toggleAndReload(filterExchanges, m);

  void toggleGenderFilter(GenderPreference g) => _toggleAndReload(filterGenderPrefs, g);

  void setFreeOnly(bool v) {
    filterFreeOnly = v;
    _changed();
    unawaited(_refreshFeed());
  }

  void setQuery(String q) {
    filterQuery = q;
    _changed();
    unawaited(_refreshFeed());
  }

  void setCategory(String c) {
    filterCategory = c;
    _changed();
    unawaited(_refreshFeed());
  }

  void clearFilters() {
    filterTypes.clear();
    filterExchanges.clear();
    filterGenderPrefs.clear();
    filterFreeOnly = false;
    filterQuery = '';
    filterCategory = 'All';
    _changed();
    unawaited(_refreshFeed());
  }

  bool get hasActiveFilters =>
      filterTypes.isNotEmpty ||
      filterExchanges.isNotEmpty ||
      filterGenderPrefs.isNotEmpty ||
      filterFreeOnly ||
      filterQuery.isNotEmpty ||
      filterCategory != 'All';

  void _toggleAndReload<T>(Set<T> set, T value) {
    set.contains(value) ? set.remove(value) : set.add(value);
    _changed();
    unawaited(_refreshFeed());
  }

  List<Task> get feed {
    final maxKm = feedSource == 'myCity' ? 25.0 : radiusKm;
    final filtered = tasks.where((t) {
      if (t.status != TaskStatus.published) return false;
      if (t.distanceKm > maxKm) return false;
      if (filterTypes.isNotEmpty && !filterTypes.contains(t.type)) return false;
      if (filterExchanges.isNotEmpty && !filterExchanges.contains(t.exchange)) return false;
      if (filterGenderPrefs.isNotEmpty && !filterGenderPrefs.contains(t.genderPreference)) {
        return false;
      }
      if (filterFreeOnly && !t.isFreeLike) return false;
      if (filterCategory != 'All' && t.category != filterCategory) return false;
      if (filterQuery.isNotEmpty) {
        final q = filterQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) && !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filtered;
  }

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Task> get emergencyFeed => tasks
      .where((t) => t.kind == PostKind.emergency)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> get gigFeed => tasks
      .where((t) => t.kind == PostKind.gig)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> get roomFeed => tasks
      .where((t) => t.kind == PostKind.room)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> get teamFeed => tasks
      .where((t) => t.kind == PostKind.team || t.kind == PostKind.trip)
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<Task> myPosts() => tasks.where((t) => t.creatorId == (me?.id ?? '')).toList();

  // ── Save / repost (optimistic; server syncs in background) ─────────
  bool isSaved(String taskId) => savedTaskIds.contains(taskId);

  void toggleSaved(String taskId) {
    savedTaskIds.contains(taskId) ? savedTaskIds.remove(taskId) : savedTaskIds.add(taskId);
    _changed();
    unawaited(_api.post('/api/v1/posts/$taskId/save').then((_) => null).catchError((_) => null));
  }

  @override
  bool isReposted(String taskId) => repostedTaskIds.contains(taskId);

  @override
  List<String> get categories => const [
        'All', 'Errands', 'Company', 'Food', 'Sports', 'Study', 'Culture', 'Transport',
      ];

  void toggleRepost(String taskId) {
    repostedTaskIds.contains(taskId) ? repostedTaskIds.remove(taskId) : repostedTaskIds.add(taskId);
    _changed();
    unawaited(
      _api.post('/api/v1/posts/$taskId/repost').then((_) => null).catchError((_) => null),
    );
  }

  // ── Server fetchers ────────────────────────────────────────────────
  Map<String, String> get _feedQuery => {
        'source': feedSource == 'myCity' ? 'city' : 'nearby',
        if (feedSource != 'myCity') 'radius_km': radiusKm.toStringAsFixed(1),
        if (filterTypes.isNotEmpty) 'types': filterTypes.map((t) => t.name).join(','),
        if (filterExchanges.isNotEmpty)
          'exchanges': filterExchanges.map((e) => e.name).join(','),
        if (filterGenderPrefs.isNotEmpty)
          'gender': filterGenderPrefs.map((g) => g.name).join(','),
        if (filterFreeOnly) 'free': '1',
        if (filterQuery.isNotEmpty) 'q': filterQuery,
        if (filterCategory != 'All') 'category': filterCategory,
        'page_size': '60',
      };

  Future<void> _refreshFeed() async {
    try {
      tasks = tasksFromJson(await _api.get('/api/v1/posts', query: _feedQuery));
      _changed();
    } on ApiError catch (e) {
      _log('_refreshFeed', e);
    }
  }

  Future<void> _refreshMembers() async {
    try {
      final data = await _api.get('/api/v1/members');
      members = ((data as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(memberFromJson)
          .toList();
      _changed();
    } on ApiError catch (e) {
      _log('_refreshMembers', e);
    }
  }

  Future<void> _refreshAuctions() async {
    try {
      auctions = auctionsFromJson(
        await _api.get('/api/v1/auctions', query: {'page_size': '60'}),
      );
      _changed();
    } on ApiError catch (e) {
      _log('_refreshAuctions', e);
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      notifications = notificationsFromJson(
        await _api.get('/api/v1/notifications', query: {'page_size': '40'}),
      );
      _changed();
    } on ApiError catch (e) {
      _log('_refreshNotifications', e);
    }
  }

  Future<void> _refreshKarma() async {
    try {
      final data = await _api.get('/api/v1/karma') as Map<String, dynamic>;
      karmaBalance = (data['balance'] as num?)?.toInt() ?? 0;
      if (me != null && karmaBalance != me!.karma) {
        me = me!.copyMemberWith(karma: karmaBalance);
      }
      _changed();
    } on ApiError catch (e) {
      _log('_refreshKarma', e);
    }
  }

  Future<void> _refreshRooms() async {
    try {
      final data = await _api.get('/api/v1/chat/rooms');
      final list = data is Map && data['results'] is List
          ? data['results'] as List
          : data as List? ?? const [];
      final rows = <MockApplication>[];
      for (final r in list.whereType<Map<String, dynamic>>()) {
        final counterpart = r['counterpart'] as Map<String, dynamic>? ?? const {};
        final app = MockApplication(
          id: r['application_id'] as String? ?? r['id'] as String,
          taskId: r['task_id'] as String? ?? '',
          memberId: counterpart['id'] as String? ?? '',
          introMessage: '',
          status: applicationStatusFrom(r['application_status'] as String?),
          createdAt: dtParse(r['created_at'] as String?),
          unreadForApplicant: (r['unread_for_me'] as num?)?.toInt() ?? 0,
        );
        rows.add(app);
        _roomIds[app.id] = r['id'] as String? ?? '';
      }
      applications = rows;
      _changed();
    } on ApiError catch (e) {
      _log('_refreshRooms', e);
    }
  }

  Future<void> _refreshEngagement() async {
    try {
      final data = await _api.get('/api/v1/perks');
      final list = data is Map && data['results'] is List
          ? data['results'] as List
          : data as List? ?? const [];
      if (list.isNotEmpty) {
        perks = list
            .whereType<Map<String, dynamic>>()
            .map(perkFromJson)
            .toList();
      }
    } on ApiError catch (e) {
      _log('perks', e);
    }
    try {
      final data = await _api.get('/api/v1/challenges');
      final list = data is Map && data['results'] is List
          ? data['results'] as List
          : data as List? ?? const [];
      if (list.isNotEmpty) {
        challenges = list
            .whereType<Map<String, dynamic>>()
            .map(challengeFromJson)
            .toList();
      }
    } on ApiError catch (e) {
      _log('challenges', e);
    }
    try {
      boardIdeas = ideasFromJson(
        await _api.get('/api/v1/community/ideas', query: {'page_size': '60'}),
      );
    } on ApiError catch (e) {
      _log('ideas', e);
    }
    try {
      final radarData = await _api.get('/api/v1/radar');
      if (radarData is Map<String, dynamic> && radarData['zones'] is List) {
        final list = radarData['zones'] as List;
        if (list.isNotEmpty) {
          radarZones = list
              .whereType<Map<String, dynamic>>()
              .map(RadarZoneData.fromJson)
              .toList();
        }
      }
    } on ApiError catch (e) {
      _log('radar', e);
    }
    _changed();
  }

  // ═══════════════════════════════════════════════════════════════
  // Mutations — same signatures as MockBackend, network-backed.
  // ═══════════════════════════════════════════════════════════════

  Task _optimisticTask({
    required String title,
    required String description,
    required String category,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String area,
    required double distanceKm,
    required ExchangeMode exchange,
    required double rewardAmount,
    required int capacity,
    GenderPreference genderPref = GenderPreference.anyone,
    PostKind kind = PostKind.regular,
    PostType type = PostType.task,
    String payoutNote = '',
    String meeting = 'Public meeting point',
    bool checkin = false,
    TaskRisk risk = TaskRisk.low,
  }) {
    final m = me;
    return Task(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      creatorId: m?.id ?? '',
      creatorName: m?.publicName ?? 'You',
      creatorPhotoUrl: m?.photoUrl ?? '',
      creatorVerified: m?.verifiedBadge ?? false,
      creatorRating: m?.rating ?? 5,
      creatorCompleted: m?.completedCount ?? 0,
      type: type,
      kind: kind,
      payoutNote: payoutNote,
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
      applicantCount: 0,
      genderPreference: genderPref,
      risk: risk,
      status: TaskStatus.published,
      createdAt: DateTime.now(),
      meetingPreference: meeting,
      hasCheckin: checkin,
    );
  }

  // ── Create flows ──────────────────────────────────────────────────
  void postTask(TaskDraft d) {
    final violation = Moderation.screen(d.title, d.description);
    if (violation != null) {
      _pendingModerationBlock = violation;
      _changed();
      return;
    }
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts', {
          'type': d.type.name,
          'kind': d.kind.name,
          'title': d.title,
          'description': d.description,
          'category': d.category,
          'scheduled_at': d.scheduledAt.toUtc().toIso8601String(),
          'duration_minutes': d.durationMinutes,
          'area': d.area,
          'exchange': d.exchange.name,
          'reward_amount': d.rewardAmount,
          'capacity': d.capacity,
          'gender_preference': d.genderPreference.name,
          'meeting_preference': d.meetingPreference,
          'has_checkin': d.hasCheckin,
          'payout_note': d.payoutNote,
        });
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('postTask', e);
      }
    }());
  }

  String? _pendingModerationBlock;

  String? consumeModerationBlock() {
    final v = _pendingModerationBlock;
    _pendingModerationBlock = null;
    return v;
  }

  Task broadcastEmergency({
    required String title,
    required String description,
    required String area,
    int durationMinutes = 60,
    GenderPreference genderPref = GenderPreference.anyone,
  }) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts', {
          'type': 'task',
          'kind': 'emergency',
          'title': title,
          'description': description,
          'category': 'Emergency',
          'scheduled_at': DateTime.now().toUtc().toIso8601String(),
          'duration_minutes': durationMinutes,
          'area': area,
          'exchange': 'free',
          'reward_amount': 0,
          'capacity': 1,
          'gender_preference': genderPref.name,
          'meeting_preference': 'Shared in chat',
          'has_checkin': true,
        });
        await _refreshFeed();
        final helpers = members.where((m) => m.availableNow || m.isGuardian).length;
        final guardians = members.where((m) => m.isGuardian).length;
        notifications.insert(
          0,
          MockNotification(
            id: 'sos-${DateTime.now().millisecondsSinceEpoch}',
            title: 'SOS broadcast sent',
            body: '$helpers nearby helpers (incl. $guardians Guardians) alerted.',
            createdAt: DateTime.now(),
          ),
        );
        _changed();
      } on ApiError catch (e) {
        _log('broadcastEmergency', e);
      }
    }());
    final optimistic = _optimisticTask(
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
      genderPref: genderPref,
      kind: PostKind.emergency,
      meeting: 'Shared in chat',
      checkin: true,
      risk: TaskRisk.high,
    );
    tasks.add(optimistic);
    return optimistic;
  }

  Task postGig({
    required String shopName,
    required String role,
    required String description,
    required String area,
    required double dailyPay,
    required int days,
    required int workers,
  }) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts', {
          'type': 'task',
          'kind': 'gig',
          'title': role,
          'description': description,
          'category': 'Gigs',
          'scheduled_at': DateTime.now().add(const Duration(hours: 12)).toUtc().toIso8601String(),
          'duration_minutes': days * 8 * 60,
          'area': area,
          'exchange': 'paid',
          'reward_amount': dailyPay * days,
          'capacity': workers,
          'meeting_preference': 'At the shop',
          'payout_note': '₹${dailyPay.toStringAsFixed(0)}/day · $days days',
        });
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('postGig', e);
      }
    }());
    final optimistic = _optimisticTask(
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
      kind: PostKind.gig,
      payoutNote: '₹${dailyPay.toStringAsFixed(0)}/day · $days days',
      meeting: 'At the shop',
    );
    tasks.add(optimistic);
    return optimistic;
  }

  Task postRoomRequest({
    required String title,
    required String description,
    required String area,
    required double budget,
    required String roomType,
    double finderFee = 500,
    GenderPreference genderPref = GenderPreference.anyone,
  }) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts', {
          'type': 'task',
          'kind': 'room',
          'title': title,
          'description': description,
          'category': 'Rooms',
          'scheduled_at': DateTime.now().add(const Duration(hours: 24)).toUtc().toIso8601String(),
          'duration_minutes': 60,
          'area': area,
          'exchange': 'paid',
          'reward_amount': finderFee,
          'capacity': 1,
          'gender_preference': genderPref.name,
          'meeting_preference': 'At the room',
          'payout_note': '$roomType under ₹${budget.toStringAsFixed(0)}',
        });
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('postRoomRequest', e);
      }
    }());
    final optimistic = _optimisticTask(
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
      genderPref: genderPref,
      kind: PostKind.room,
      payoutNote: '$roomType under ₹${budget.toStringAsFixed(0)}',
      meeting: 'At the room',
    );
    tasks.add(optimistic);
    return optimistic;
  }

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
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts', {
          'type': 'company',
          'kind': kind.name,
          'title': title,
          'description': description,
          'category': kind == PostKind.trip ? 'Trips' : 'Teams',
          'scheduled_at': when.toUtc().toIso8601String(),
          'duration_minutes': kind == PostKind.trip ? 8 * 60 : 120,
          'area': area,
          'exchange': exchange.name,
          'reward_amount': splitPerHead,
          'capacity': headcount,
          'gender_preference': genderPref.name,
          'meeting_preference': 'Public meeting point',
          'has_checkin': kind == PostKind.trip,
          'payout_note': destination,
        });
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('postTeamPost', e);
      }
    }());
    final optimistic = _optimisticTask(
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
      genderPref: genderPref,
      kind: kind,
      type: PostType.company,
      payoutNote: destination,
      checkin: kind == PostKind.trip,
      risk: kind == PostKind.trip ? TaskRisk.medium : TaskRisk.low,
    );
    tasks.add(optimistic);
    return optimistic;
  }

  String upiSplitPerHead(double total, int heads) {
    if (heads <= 0) return '₹0';
    return '₹${(total / heads).toStringAsFixed(0)} per head';
  }

  // ── Applications & lifecycle ──────────────────────────────────────
  List<MockApplication> applicationsForTask(String taskId) =>
      applications.where((a) => a.taskId == taskId).toList();

  List<MockApplication> myApplications() =>
      applications.where((a) => a.memberId == (me?.id ?? '')).toList();

  bool hasApplied(String taskId) =>
      myApplications().any((a) => a.taskId == taskId);

  MockApplication? applyToTask(String taskId, String intro) {
    if (hasApplied(taskId)) return null;
    final t = taskById(taskId);
    if (t != null && !t.genderPreference.admits(me?.gender)) return null;
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts/$taskId/apply', {'intro_message': intro});
        await _refreshRooms();
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('applyToTask', e);
      }
    }());
    return MockApplication(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      memberId: me?.id ?? '',
      introMessage: intro,
      status: ApplicationStatus.chatting,
      createdAt: DateTime.now(),
    );
  }

  void withdrawApplication(String appId) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/applications/$appId/withdraw');
        await _refreshRooms();
      } on ApiError catch (e) {
        _log('withdrawApplication', e);
      }
    }());
  }

  void selectApplicant(String appId) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/applications/$appId/select');
        await _refreshRooms();
        await _refreshFeed();
      } on ApiError catch (e) {
        _log('selectApplicant', e);
      }
    }());
  }

  void startTask(String taskId) => _taskAction(taskId, 'start');

  void completeTask(String taskId) => _taskAction(taskId, 'complete');

  void cancelTask(String taskId) => _taskAction(taskId, 'cancel');

  void _taskAction(String taskId, String action) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts/$taskId/$action');
        final data = await _api.get('/api/v1/posts/$taskId');
        _upsertTask(taskFromJson(data as Map<String, dynamic>));
        await _refreshKarma();
      } on ApiError catch (e) {
        _log('$action', e);
      }
    }());
  }

  void _upsertTask(Task fresh) {
    final index = tasks.indexWhere((t) => t.id == fresh.id);
    if (index >= 0) {
      tasks[index] = fresh;
    } else {
      tasks.add(fresh);
    }
  }

  // ── Chat ──────────────────────────────────────────────────────────
  List<MockMessage> messagesFor(String applicationId) {
    _syncMessages(applicationId);
    return roomMessages[applicationId] ?? const [];
  }

  final Set<String> _syncingRooms = {};

  void _syncMessages(String applicationId) {
    if (_syncingRooms.contains(applicationId)) return;
    _syncingRooms.add(applicationId);
    unawaited(() async {
      try {
        final room = applications.firstWhere(
          (a) => a.id == applicationId,
          orElse: () => throw StateError('no room'),
        );
        final existing = roomMessages[applicationId] ?? const <MockMessage>[];
        final sinceSeq = existing.isEmpty ? 0 : existing.length;
        final roomId = _roomIds[room.id];
        if (roomId == null || roomId.isEmpty) return;
        final data = await _api
            .get('/api/v1/chat/rooms/$roomId/messages', query: {'since_seq': '$sinceSeq'});
        final list = data is Map && data['results'] is List
            ? data['results'] as List
            : data as List? ?? const [];
        final fresh = list.whereType<Map<String, dynamic>>().map((m) => MockMessage(
              id: m['id'] as String,
              applicationId: applicationId,
              senderId: m['sender'] as String? ?? '',
              body: m['body'] as String? ?? '',
              createdAt: dtParse(m['created_at'] as String?),
            )).toList();
        if (fresh.isNotEmpty) {
          roomMessages[applicationId] = [...existing, ...fresh];
          _changed();
        }
      } catch (e) {
        _log('_syncMessages', e);
      } finally {
        _syncingRooms.remove(applicationId);
      }
    }());
  }

  void sendMessage(String applicationId, String body, {bool fromCreator = false}) {
    if (body.trim().isEmpty) return;
    // Optimistic bubble.
    roomMessages.putIfAbsent(applicationId, () => []).add(MockMessage(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          applicationId: applicationId,
          senderId: me?.id ?? 'me',
          body: body,
          createdAt: DateTime.now(),
        ));
    _changed();
    unawaited(() async {
      try {
        final room = applications.firstWhere(
          (a) => a.id == applicationId,
          orElse: () => throw StateError('no room'),
        );
        final roomId = _roomIds[room.id];
        if (roomId == null || roomId.isEmpty) return;
        await _api.post('/api/v1/chat/rooms/$roomId/send', {'body': body});
        await _refreshRooms();
      } catch (e) {
        _log('sendMessage', e);
      }
    }());
  }

  void markRoomRead(String applicationId) {
    unawaited(() async {
      try {
        final room = applications.firstWhere(
          (a) => a.id == applicationId,
          orElse: () => throw StateError('no room'),
        );
        final roomId = _roomIds[room.id];
        if (roomId == null || roomId.isEmpty) return;
        await _api.post('/api/v1/chat/rooms/$roomId/read');
        await _refreshRooms();
      } catch (e) {
        _log('markRoomRead', e);
      }
    }());
  }

  int get totalUnreadRooms => applications.fold(0, (sum, a) => sum + a.unreadForApplicant);

  // ── Ratings & notifications ───────────────────────────────────────
  void submitRating(String taskId, double stars, String note) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/posts/$taskId/rate', {'stars': stars, 'note': note});
        notifications.insert(
          0,
          MockNotification(
            id: 'rate-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Rating submitted',
            body: 'Thanks — you rated ${stars.toStringAsFixed(0)}★${note.isEmpty ? '' : ' with a note'}.',
            createdAt: DateTime.now(),
          ),
        );
        _changed();
      } on ApiError catch (e) {
        _log('submitRating', e);
      }
    }());
  }

  int get unreadNotifications => notifications.where((n) => !n.read).length;

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    _changed();
    unawaited(_api.post('/api/v1/notifications/read-all').then((_) => null).catchError((_) => null));
  }

  // ── Auctions ──────────────────────────────────────────────────────
  AuctionItem? getAuctionById(String id) {
    for (final a in auctions) {
      if (a.id == id) return a;
    }
    return null;
  }

  bool placeBid(String auctionId, double amount) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/auctions/$auctionId/bids', {'amount': amount});
        await _refreshAuctions();
        notifications.insert(
          0,
          MockNotification(
            id: 'bid-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Bid placed',
            body: 'Your bid of ₹${amount.toStringAsFixed(0)} is now the highest bid.',
            createdAt: DateTime.now(),
          ),
        );
        _changed();
      } on ApiError catch (e) {
        _log('placeBid', e);
      }
    }());
    return true;
  }

  @override
  Future<String> uploadImage(
    Uint8List bytes, {
    required String filename,
    required String mimeType,
  }) =>
      _api.upload(
        '/api/v1/uploads',
        bytes,
        filename: filename,
        mimeType: mimeType,
      );

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
    unawaited(() async {
      try {
        await _api.post('/api/v1/auctions', {
          'title': title,
          'description': description,
          'category': category,
          'image_url': imageUrl,
          'base_price': basePrice,
          if (buyItNowPrice != null) 'buy_it_now_price': buyItNowPrice,
          'duration_hours': durationHours,
          'area': area,
        });
        await _refreshAuctions();
      } on ApiError catch (e) {
        _log('createAuction', e);
      }
    }());
    return AuctionItem(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      imageUrl: imageUrl,
      sellerId: me?.id ?? '',
      sellerName: me?.publicName ?? 'You',
      sellerPhotoUrl: me?.photoUrl ?? '',
      sellerVerified: me?.verifiedBadge ?? false,
      sellerRating: me?.rating ?? 5,
      basePrice: basePrice,
      currentBid: basePrice,
      buyItNowPrice: buyItNowPrice,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: durationHours)),
      totalBids: 0,
      status: AuctionStatus.active,
      bidHistory: [],
      area: area.isEmpty ? 'Madiwala Central' : area,
      distanceKm: 0.5,
    );
  }

  // ── Emergency roster ──────────────────────────────────────────────
  List<Member> get availableHelpers =>
      members.where((m) => m.availableNow || m.isGuardian).toList();

  int get guardianCount => members.where((m) => m.isGuardian).length;

  int get availableNowCount => members.where((m) => m.availableNow).length;

  void toggleAvailableNow() {
    if (me == null) return;
    me = me!.copyMemberWith(availableNow: !me!.availableNow);
    _changed();
    unawaited(_api.post('/api/v1/me/toggle-available').then((_) => null).catchError((_) => null));
  }

  void toggleGuardianShield() {
    if (me == null) return;
    me = me!.copyMemberWith(isGuardian: !me!.isGuardian);
    notifications.insert(
      0,
      MockNotification(
        id: 'guardian-${DateTime.now().millisecondsSinceEpoch}',
        title: me!.isGuardian ? 'Guardian Shield active 🛡️' : 'Guardian Shield paused',
        body: me!.isGuardian
            ? 'You now receive priority SOS dispatches in Madiwala.'
            : 'You can re-enable any time from your profile.',
        createdAt: DateTime.now(),
      ),
    );
    _changed();
    unawaited(_api.post('/api/v1/me/toggle-guardian').then((_) => null).catchError((_) => null));
  }

  // ── Karma wallet ──────────────────────────────────────────────────
  void earnKarma(int amount, String reason) {
    // Earned server-side (task completion, challenges); client mirrors.
    if (me != null) me = me!.copyMemberWith(karma: me!.karma + amount);
    _changed();
    unawaited(_refreshKarma());
  }

  bool spendKarma(int amount, String reason) {
    if ((me?.karma ?? 0) < amount) return false;
    if (me != null) me = me!.copyMemberWith(karma: me!.karma - amount);
    _changed();
    unawaited(_refreshKarma());
    return true;
  }

  // ── Play & Earn ───────────────────────────────────────────────────
  bool hasPlayedToday(String challengeId) => playedToday.contains(challengeId);

  void recordPlay({
    required String challengeId,
    required int score,
    required int target,
    required int rewardKarma,
  }) {
    playedToday.add(challengeId);
    final challenge = challenges.where((c) => c.id == challengeId).firstOrNull;
    final serverId = challenge?.id ?? challengeId;
    unawaited(() async {
      try {
        await _api.post('/api/v1/challenges/$serverId/play', {'score': score});
        await _refreshKarma();
      } on ApiError catch (e) {
        _log('recordPlay', e);
      }
    }());
    _changed();
  }

  // ── Perks ─────────────────────────────────────────────────────────
  bool isPerkClaimed(String perkId) => claimedPerks.contains(perkId);

  bool claimPerk(PartnerPerk perk) {
    if (claimedPerks.contains(perk.id)) return false;
    if ((me?.karma ?? 0) < perk.costKarma) return false;
    claimedPerks.add(perk.id);
    if (me != null) me = me!.copyMemberWith(karma: me!.karma - perk.costKarma);
    _changed();
    unawaited(() async {
      try {
        await _api.post('/api/v1/perks/${perk.id}/claim');
        await _refreshKarma();
      } on ApiError catch (e) {
        _log('claimPerk', e);
      }
    }());
    return true;
  }

  // ── Moderation, badges ────────────────────────────────────────────
  void reportTask(String taskId, String reason, String details) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/reports', {
          'task_id': taskId,
          'reason': reason,
          'details': details,
        });
        notifications.insert(
          0,
          MockNotification(
            id: 'report-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Report received',
            body: 'Our safety team will review "$reason" within 24 hours.',
            createdAt: DateTime.now(),
          ),
        );
        await _refreshFeed();
        _changed();
      } on ApiError catch (e) {
        _log('reportTask', e);
      }
    }());
  }

  void quarantineTask(String taskId, String reason) {
    reportTask(taskId, 'inappropriate', reason);
  }

  void awardBadge(TrustBadge badge) {
    if (me == null) return;
    final next = Set<TrustBadge>.from(me!.badges)..add(badge);
    me = me!.copyMemberWith(badges: next);
    _changed();
  }

  // ── Community board ───────────────────────────────────────────────
  void submitIdea(String title, String details, String tag) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/community/ideas/create', {
          'title': title,
          'details': details,
          'tag': tag,
        });
        await Future.wait([_refreshEngagement(), _refreshKarma()]);
      } on ApiError catch (e) {
        _log('submitIdea', e);
      }
    }());
  }

  void toggleIdeaVote(String ideaId) {
    unawaited(() async {
      try {
        await _api.post('/api/v1/community/ideas/$ideaId/vote');
        boardIdeas = ideasFromJson(
          await _api.get('/api/v1/community/ideas', query: {'page_size': '60'}),
        );
        _changed();
      } on ApiError catch (e) {
        _log('toggleIdeaVote', e);
      }
    }());
  }
}
