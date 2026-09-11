import '../core/models/models.dart';

/// Draft state assembled during the Create wizard.
/// Passed to TaskRepository.create() in Stage 2.
class TaskDraft {
  PostType type = PostType.task;
  String title = '';
  String description = '';
  String category = 'Errands';
  DateTime scheduledAt = DateTime.now().add(const Duration(hours: 2));
  int durationMinutes = 30;
  String area = 'Madiwala';
  ExchangeMode exchange = ExchangeMode.paid;
  double rewardAmount = 0;
  int capacity = 1;
  GenderPreference genderPreference = GenderPreference.anyone;
  String meetingPreference = 'Public meeting point';
  bool hasCheckin = false;
}
