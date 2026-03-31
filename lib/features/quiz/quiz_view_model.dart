import 'package:flutter/material.dart';

import '../../core/services/ai/ai_repository.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quizzes_repository.dart';

class QuizViewModel extends ChangeNotifier {
  QuizViewModel(this._aiRepository, this._repository) {
    history = _repository.getAll();
  }

  final AiRepository _aiRepository;
  final QuizzesRepository _repository;

  final topicController = TextEditingController();

  bool _loading = false;
  bool get isLoading => _loading;

  QuizModel? currentQuiz;
  List<QuizModel> history = [];

  Future<void> generate() async {
    final topic = topicController.text.trim();
    if (topic.isEmpty) return;
    _loading = true;
    notifyListeners();

    try {
      final quiz = await _aiRepository.generateQuiz(topic);
      currentQuiz = quiz;
      await _repository.add(quiz);
      history = _repository.getAll();
    } catch (error) {
      currentQuiz = QuizModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: topic,
        questions: [
          QuizQuestion(
            question: 'Error: ${error.toString()}',
            options: const ['Try again later'],
            answer: 'Try again later',
          ),
        ],
        createdAt: DateTime.now(),
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    topicController.dispose();
    super.dispose();
  }
}
