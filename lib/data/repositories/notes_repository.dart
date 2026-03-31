import 'package:hive_ce/hive.dart';

import '../models/note_model.dart';

class NotesRepository {
  NotesRepository(this._box);

  final Box<NoteModel> _box;

  List<NoteModel> getAll() => _box.values.toList().reversed.toList();

  Future<void> add(NoteModel note) async {
    await _box.put(note.id, note);
  }
}
