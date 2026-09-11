import 'package:flutter_test/flutter_test.dart';
import 'package:time_need/core/models/models.dart';
import 'package:time_need/data/mock_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockBackend — application lifecycle', () {
    test('apply → chat → select transitions task to confirmed', () {
      final b = MockBackend();
      b.completeSignupProfile(
        name: 'Tester',
        gender: Gender.female,
        bio: '',
        categories: ['Errands'],
      );

      expect(b.signedIn, isTrue);
      expect(b.feed, isNotEmpty);

      final task = b.feed.first;
      expect(b.hasApplied(task.id), isFalse);

      final app = b.applyToTask(task.id, 'I can help with this today!');
      expect(app, isNotNull);
      expect(b.hasApplied(task.id), isTrue);
      expect(task.applicantCount, greaterThan(0));

      // Selecting the applicant confirms the task.
      b.selectApplicant(app!.id);
      expect(b.taskById(task.id)!.status, TaskStatus.confirmed);
    });

    test('duplicate application is rejected', () {
      final b = MockBackend();
      b.completeSignupProfile(
        name: 'Tester',
        gender: Gender.female,
        bio: '',
        categories: ['Errands'],
      );
      final task = b.feed.first;
      b.applyToTask(task.id, 'First application');
      expect(b.applyToTask(task.id, 'Second attempt'), isNull);
    });

    test('selecting one applicant declines the rest of that task only', () {
      final b = MockBackend();
      b.completeSignupProfile(
        name: 'Tester',
        gender: Gender.male,
        bio: '',
        categories: ['Errands'],
      );

      final taskA = b.feed.firstWhere((t) => t.id == 't1');
      final taskB = b.feed.firstWhere((t) => t.id == 't2');
      final appA = b.applyToTask(taskA.id, 'App for A');
      final appB = b.applyToTask(taskB.id, 'App for B');

      b.selectApplicant(appA!.id);
      expect(appA.status, ApplicationStatus.selected);
      expect(
        b.taskById('t1')!.status,
        TaskStatus.confirmed,
      );
      // Other task's application untouched.
      expect(appB!.status, ApplicationStatus.chatting);
    });
  });

  group('MockBackend — gender preference gate', () {
    test('girls-only post rejects male applicants, admits female', () {
      final b = MockBackend();
      final t4 = b.feed.firstWhere((t) => t.id == 't4');
      expect(t4.genderPreference, GenderPreference.femaleOnly);

      b.completeSignupProfile(
        name: 'Male Tester',
        gender: Gender.male,
        bio: '',
        categories: ['Food'],
      );
      expect(b.applyToTask(t4.id, 'I would love to join'), isNull);
      expect(b.hasApplied(t4.id), isFalse);

      // Same backend, female member → allowed.
      b.completeSignupProfile(
        name: 'Female Tester',
        gender: Gender.female,
        bio: '',
        categories: ['Food'],
      );
      expect(b.applyToTask(t4.id, 'I would love to join'), isNotNull);
    });

    test('boys-only post admits male, rejects female', () {
      final b = MockBackend();
      final t5 = b.feed.firstWhere((t) => t.id == 't5');
      expect(t5.genderPreference, GenderPreference.maleOnly);

      b.completeSignupProfile(
        name: 'Female Tester',
        gender: Gender.female,
        bio: '',
        categories: ['Sports'],
      );
      expect(b.applyToTask(t5.id, 'Count me in'), isNull);
    });
  });

  group('MockBackend — age gate + auth', () {
    test('email OTP flow with demo code', () {
      final b = MockBackend();
      b.requestOtp('test@example.com');
      expect(b.verifyOtp('000000'), isFalse);
      expect(b.verifyOtp('424242'), isTrue);
      expect(b.signedIn, isTrue);
    });
  });
}
