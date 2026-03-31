import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/models/voice_note_model.dart';
import '../../data/repositories/voice_notes_repository.dart';

class VoiceNotesViewModel extends ChangeNotifier {
  VoiceNotesViewModel(this._repository) {
    history = _repository.getAll();
  }

  final VoiceNotesRepository _repository;
  final SpeechToText _speech = SpeechToText();

  String transcript = '';
  bool _isListening = false;
  bool get isListening => _isListening;

  List<VoiceNoteModel> history = [];

  Future<void> toggleRecording() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      await _saveTranscript();
      notifyListeners();
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      transcript = 'Speech recognition not available.';
      notifyListeners();
      return;
    }

    _isListening = true;
    transcript = '';
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        transcript = result.recognizedWords;
        notifyListeners();
      },
    );
  }

  Future<void> _saveTranscript() async {
    if (transcript.trim().isEmpty) return;
    final note = VoiceNoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transcript: transcript.trim(),
      createdAt: DateTime.now(),
    );
    await _repository.add(note);
    history = _repository.getAll();
  }
}
