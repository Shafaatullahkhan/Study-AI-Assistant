import 'package:hive_ce/hive.dart';

import '../models/study_task_model.dart';

class StudyTasksRepository {
  StudyTasksRepository(this._box);

  final Box<StudyTaskModel> _box;

  List<StudyTaskModel> getAll() => _box.values.toList().reversed.toList();

  Future<void> add(StudyTaskModel task) async {
    await _box.put(task.id, task);
  }

  Future<void> addAll(List<StudyTaskModel> tasks) async {
    for (final task in tasks) {
      await _box.put(task.id, task);
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
