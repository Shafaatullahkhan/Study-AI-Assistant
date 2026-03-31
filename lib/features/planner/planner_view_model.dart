import 'package:flutter/material.dart';

import '../../core/services/notifications/notification_service.dart';
import '../../data/models/study_task_model.dart';
import '../../data/repositories/study_tasks_repository.dart';

class PlannerViewModel extends ChangeNotifier {
  PlannerViewModel(this._repository, this._notifications) {
    _load();
  }

  final StudyTasksRepository _repository;
  final NotificationService _notifications;

  List<StudyTaskModel> tasks = [];
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List<StudyTaskModel> get tasksForSelectedDay {
    return tasks.where((task) {
      return task.date.year == selectedDay.year &&
          task.date.month == selectedDay.month &&
          task.date.day == selectedDay.day;
    }).toList();
  }

  Future<void> _load() async {
    tasks = _repository.getAll();
    if (tasks.isEmpty) {
      final seed = [
        StudyTaskModel(
          id: '1',
          subject: 'Flutter',
          task: 'Learn Widgets',
          date: DateTime.now().add(const Duration(days: 1)),
          status: StudyTaskStatus.pending,
        ),
        StudyTaskModel(
          id: '2',
          subject: 'Networking',
          task: 'Summarize chapter 4',
          date: DateTime.now().add(const Duration(days: 3)),
          status: StudyTaskStatus.inProgress,
        ),
        StudyTaskModel(
          id: '3',
          subject: 'AI Basics',
          task: 'Flashcards review',
          date: DateTime.now().add(const Duration(days: 5)),
          status: StudyTaskStatus.done,
        ),
      ];
      await _repository.addAll(seed);
      tasks = _repository.getAll();
    }
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime day) {
    selectedDay = day;
    notifyListeners();
  }

  Future<void> addOrUpdateTask({
    String? id,
    required String subject,
    required String task,
    required DateTime date,
    required StudyTaskStatus status,
    DateTime? reminderAt,
    RecurrenceRule recurrence = RecurrenceRule.none,
    DateTime? repeatUntil,
  }) async {
    StudyTaskModel? existing;
    if (id != null) {
      try {
        existing = tasks.firstWhere((item) => item.id == id);
      } catch (_) {
        existing = null;
      }
    }
    final model = StudyTaskModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      task: task,
      date: date,
      status: status,
      reminderAt: reminderAt,
      recurrence: recurrence,
      repeatUntil: repeatUntil,
    );
    await _repository.add(model);
    if (existing != null) {
      if (existing.reminderAt != null && reminderAt == null) {
        await _notifications.cancelTaskReminder(existing);
      }
    }
    if (reminderAt != null) {
      await _notifications.scheduleTaskReminder(model);
    }
    tasks = _repository.getAll();
    notifyListeners();
  }

  Future<void> deleteTask(StudyTaskModel task) async {
    await _repository.delete(task.id);
    await _notifications.cancelTaskReminder(task);
    tasks = _repository.getAll();
    notifyListeners();
  }
}
