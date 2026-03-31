import 'package:hive_ce/hive.dart';

import '../models/quiz_model.dart';

class QuizzesRepository {
  QuizzesRepository(this._box);

  final Box<QuizModel> _box;

  List<QuizModel> getAll() => _box.values.toList().reversed.toList();

  Future<void> add(QuizModel quiz) async {
    await _box.put(quiz.id, quiz);
  }
}
