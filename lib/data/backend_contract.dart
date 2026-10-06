// BackendContract — the typed surface shared by MockBackend (demo) and
// ApiBackend (server-backed). Mirrors MockBackend's public API 1:1.
//
// Screens receive `BackendContract` from storeProvider: full static
// typing, zero `dynamic`, and demo/API parity enforced at compile time
// (both classes `implements BackendContract`).
import 'package:flutter/foundation.dart';

import '../core/models/auction.dart';
import '../core/models/models.dart';
import 'mock_backend.dart' show MockApplication, MockMessage, MockNotification;
import 'task_draft.dart';

export 'task_draft.dart';

abstract class BackendContract extends ChangeNotifier {
  /// Broadcast of user-facing rejection messages ("Select an applicant
  /// before starting.", "Bid must be higher than the current bid").
  /// Background refresh failures never appear here. Demo mode emits
  /// nothing (offline rules are permissive); the app shell shows these
  /// as snackbars.
  Stream<String> get errors;

  // ── Auth / signup state ─────────────────────────────────────────────
  bool get signedIn;
  String? pendingEmail;
  String signupName = '';
  String signupBio = '';
  String signupIntent = 'both';
  List<String> signupCategories = [];
  Member? me;
  Member? get currentUser;

  // ── Marketplace state ─────────────────────────────────────────────
  List<Member> get members;
  List<Task> get tasks;
  List<MockApplication> get applications;
  Map<String, List<MockMessage>> get roomMessages;
  List<MockNotification> get notifications;
  Set<String> get savedTaskIds;
  Set<String> get repostedTaskIds;
  List<BoardIdea> get boardIdeas;
  List<AuctionItem> get auctions;
  List<RadarZoneData> get radarZones;
  Set<String> get quarantinedTaskIds;

  // ── Preferences / filters ─────────────────────────────────────────
  String get feedSource;
  double get radiusKm;
  Set<PostType> get filterTypes;
  Set<ExchangeMode> get filterExchanges;
  Set<GenderPreference> get filterGenderPrefs;
  bool get filterFreeOnly;
  String get filterQuery;
  String get filterCategory;
  bool get hasActiveFilters;
  List<String> get categories;

  // ── Auth ──────────────────────────────────────────────────────────
  void requestOtp(String email);
  bool verifyOtp(String code);
  void setSignupIntent(String intent);
  void completeSignupProfile({
    required String name,
    required Gender gender,
    required String bio,
    required List<String> categories,
    String? photoUrl,
  });
  void signOut();

  // ── Feed & filters ────────────────────────────────────────────────
  void setFeedSource(String source);
  void setRadius(double km);
  void toggleTypeFilter(PostType t);
  void toggleExchangeFilter(ExchangeMode m);
  void toggleGenderFilter(GenderPreference g);
  void setFreeOnly(bool v);
  void setQuery(String q);
  void setCategory(String c);
  void clearFilters();
  List<Task> get feed;
  Task? taskById(String id);
  List<Task> myPosts();

  // ── Save / repost ─────────────────────────────────────────────────
  bool isSaved(String taskId);
  void toggleSaved(String taskId);
  bool isReposted(String taskId);
  void toggleRepost(String taskId);

  // ── Create ────────────────────────────────────────────────────────
  void postTask(TaskDraft d);
  String? consumeModerationBlock();

  // ── Applications & lifecycle ──────────────────────────────────────
  List<MockApplication> applicationsForTask(String taskId);
  List<MockApplication> myApplications();
  bool hasApplied(String taskId);
  MockApplication? applyToTask(String taskId, String intro);
  void withdrawApplication(String appId);
  void selectApplicant(String appId);
  void startTask(String taskId);
  void completeTask(String taskId);
  void cancelTask(String taskId);

  // ── Chat ──────────────────────────────────────────────────────────
  List<MockMessage> messagesFor(String applicationId);
  void sendMessage(String applicationId, String body, {bool fromCreator = false});
  void markRoomRead(String applicationId);
  int get totalUnreadRooms;

  // ── Ratings & notifications ───────────────────────────────────────
  void submitRating(String taskId, double stars, String note);
  int get unreadNotifications;
  void markAllNotificationsRead();

  // ── Auctions ──────────────────────────────────────────────────────
  AuctionItem? getAuctionById(String id);
  bool placeBid(String auctionId, double amount);

  /// Uploads a product photo and resolves to a URL usable as
  /// [createAuction]'s imageUrl (API mode: server upload; demo mode:
  /// inline data URL). Throws on failure — callers surface the message.
  Future<String> uploadImage(
    Uint8List bytes, {
    required String filename,
    required String mimeType,
  });

  AuctionItem createAuction({
    required String title,
    required String description,
    required String category,
    required String imageUrl,
    required double basePrice,
    double? buyItNowPrice,
    required int durationHours,
    required String area,
  });

  // ── Emergency helpers ─────────────────────────────────────────────
  List<Task> get emergencyFeed;
  List<Member> get availableHelpers;
  int get guardianCount;
  int get availableNowCount;
  void toggleAvailableNow();
  void toggleGuardianShield();
  Task broadcastEmergency({
    required String title,
    required String description,
    required String area,
    int durationMinutes,
    GenderPreference genderPref,
  });

  // ── Hubs ──────────────────────────────────────────────────────────
  List<Task> get gigFeed;
  Task postGig({
    required String shopName,
    required String role,
    required String description,
    required String area,
    required double dailyPay,
    required int days,
    required int workers,
  });
  List<Task> get roomFeed;
  Task postRoomRequest({
    required String title,
    required String description,
    required String area,
    required double budget,
    required String roomType,
    double finderFee,
    GenderPreference genderPref,
  });
  List<Task> get teamFeed;
  Task postTeamPost({
    required PostKind kind,
    required String title,
    required String description,
    required String area,
    required DateTime when,
    required int headcount,
    String destination,
    ExchangeMode exchange,
    double splitPerHead,
    GenderPreference genderPref,
  });
  String upiSplitPerHead(double total, int heads);

  // ── Karma ─────────────────────────────────────────────────────────
  void earnKarma(int amount, String reason);
  bool spendKarma(int amount, String reason);

  // ── Play & Earn ───────────────────────────────────────────────────
  bool hasPlayedToday(String challengeId);
  void recordPlay({
    required String challengeId,
    required int score,
    required int target,
    required int rewardKarma,
  });

  // ── Perks ─────────────────────────────────────────────────────────
  bool isPerkClaimed(String perkId);
  bool claimPerk(PartnerPerk perk);

  // ── Moderation ────────────────────────────────────────────────────
  void quarantineTask(String taskId, String reason);
  void reportTask(String taskId, String reason, String details);
  void awardBadge(TrustBadge badge);

  // ── Community board ───────────────────────────────────────────────
  void submitIdea(String title, String details, String tag);
  void toggleIdeaVote(String ideaId);
}
