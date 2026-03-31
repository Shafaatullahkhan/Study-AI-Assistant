import 'package:flutter/material.dart';

import '../../core/services/ai/ai_repository.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/notes_repository.dart';

class SummarizerViewModel extends ChangeNotifier {
  SummarizerViewModel(this._aiRepository, this._notesRepository) {
    history = _notesRepository.getAll();
  }

  final AiRepository _aiRepository;
  final NotesRepository _notesRepository;

  final inputController = TextEditingController();

  bool _loading = false;
  bool get isLoading => _loading;

  String? summary;
  List<NoteModel> history = [];

  Future<void> summarize() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    _loading = true;
    notifyListeners();

    try {
      final result = await _aiRepository.summarize(text);
      summary = result;
      final note = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleFrom(text),
        content: text,
        summary: result,
        createdAt: DateTime.now(),
      );
      await _notesRepository.add(note);
      history = _notesRepository.getAll();
    } catch (error) {
      summary = 'Error: ${error.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _titleFrom(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.length > 40 ? '${cleaned.substring(0, 40)}…' : cleaned;
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
