/// Repository contracts — the exact shape the Django/DRF API will expose
/// in Stage 2. The mock backend implements the same use-cases
/// synchronously; the API implementation swaps in Futures + dio.
///
/// Keeping these interfaces here means the UI layer never changes
/// when the real backend lands — only `providers.dart` changes.
library;

import '../core/models/models.dart';
import 'task_draft.dart';

abstract interface class AuthRepository {
  Future<void> requestOtp(String email);
  Future<bool> verifyOtp(String code);
  Future<void> setSignupDob(DateTime dob); // must be 18+ server-side too
  Future<void> setSignupIntent(String intent);
  Future<void> completeProfile({
    required String name,
    required String avatar,
    required String bio,
    required List<String> categories,
  });
  Future<void> signOut();
  Future<void> resendOtpCooldown(); // 60s server-enforced
}

abstract interface class TaskRepository {
  Future<List<Task>> feed({
    required double radiusKm,
    required String source, // nearby | myCity
    Set<PostType>? types,
    Set<ExchangeMode>? exchanges,
    bool? freeOnly,
    String? category,
    String? query,
  });
  Future<Task?> byId(String id);
  Future<Task> create(TaskDraft draft); // runs SAFETY_CHECK server-side
  Future<void> save(String taskId);
  Future<void> unsave(String taskId);
  Future<void> repost(String taskId);
}

abstract interface class ApplicationRepository {
  Future<void> apply(String taskId, String introMessage);
  Future<void> withdraw(String applicationId);
  Future<void> select(String applicationId); // capacity enforced server-side
  Future<List<ApplicationSummary>> forTask(String taskId);
}

/// Read-only applicant summary (member PII stays server-side).
class ApplicationSummary {
  ApplicationSummary({
    required this.id,
    required this.publicName,
    required this.avatar,
    required this.verified,
    required this.rating,
    required this.completedCount,
    required this.introMessage,
    required this.status,
  });

  final String id;
  final String publicName;
  final String avatar;
  final bool verified;
  final double rating;
  final int completedCount;
  final String introMessage;
  final ApplicationStatus status;
}

abstract interface class ChatRepository {
  Future<List<ChatMessage>> messages(String roomId);
  Future<void> send(String roomId, String body);
  Future<void> markRead(String roomId);
  Future<int> unreadCount();
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final bool isMine;
}

abstract interface class SafetyRepository {
  Future<void> report({
    required String targetType, // task | user | message
    required String targetId,
    required String reason,
    required String details,
  });
  Future<void> block(String userId);
  Future<void> checkIn(String taskId);
  Future<void> sos(String taskId, {required bool shareLocation});
}

abstract interface class RatingRepository {
  Future<void> submit({
    required String taskId,
    required double stars,
    required String note,
  });
}
