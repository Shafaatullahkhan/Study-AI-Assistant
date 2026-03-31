import 'package:hive_ce/hive.dart';

import '../models/voice_note_model.dart';

class VoiceNotesRepository {
  VoiceNotesRepository(this._box);

  final Box<VoiceNoteModel> _box;

  List<VoiceNoteModel> getAll() => _box.values.toList().reversed.toList();

  Future<void> add(VoiceNoteModel note) async {
    await _box.put(note.id, note);
  }
}
