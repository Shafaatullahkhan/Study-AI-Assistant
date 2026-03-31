import 'package:hive_ce/hive.dart';

import '../models/flashcard_model.dart';

class FlashcardsRepository {
  FlashcardsRepository(this._box);

  final Box<FlashcardModel> _box;

  List<FlashcardModel> getAll() => _box.values.toList().reversed.toList();

  Future<void> addAll(List<FlashcardModel> cards) async {
    for (final card in cards) {
      await _box.put(card.id, card);
    }
  }
}
