import 'package:flutter/material.dart';

import '../../core/services/ai/ai_repository.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/repositories/flashcards_repository.dart';

class FlashcardsViewModel extends ChangeNotifier {
  FlashcardsViewModel(this._aiRepository, this._repository) {
    history = _repository.getAll();
  }

  final AiRepository _aiRepository;
  final FlashcardsRepository _repository;

  final topicController = TextEditingController();

  bool _loading = false;
  bool get isLoading => _loading;

  List<FlashcardModel> currentCards = [];
  List<FlashcardModel> history = [];

  Future<void> generate() async {
    final topic = topicController.text.trim();
    if (topic.isEmpty) return;
    _loading = true;
    notifyListeners();

    try {
      final cards = await _aiRepository.generateFlashcards(topic);
      currentCards = cards;
      await _repository.addAll(cards);
      history = _repository.getAll();
    } catch (error) {
      currentCards = [
        FlashcardModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          topic: topic,
          front: 'Error',
          back: error.toString(),
          createdAt: DateTime.now(),
        ),
      ];
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
