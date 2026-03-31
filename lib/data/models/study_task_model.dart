enum StudyTaskStatus { pending, inProgress, done }
enum RecurrenceRule { none, daily, weekly }

class StudyTaskModel {
  StudyTaskModel({
    required this.id,
    required this.subject,
    required this.task,
    required this.date,
    required this.status,
    this.reminderAt,
    this.recurrence = RecurrenceRule.none,
    this.repeatUntil,
  });

  final String id;
  final String subject;
  final String task;
  final DateTime date;
  final StudyTaskStatus status;
  final DateTime? reminderAt;
  final RecurrenceRule recurrence;
  final DateTime? repeatUntil;

  int get notificationId => id.hashCode;
}
