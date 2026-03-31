import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/models/adapters.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/study_task_model.dart';
import '../../../data/models/voice_note_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(AppSettingsAdapter())
      ..registerAdapter(NoteModelAdapter())
      ..registerAdapter(VoiceNoteModelAdapter())
      ..registerAdapter(FlashcardModelAdapter())
      ..registerAdapter(QuizModelAdapter())
      ..registerAdapter(QuizQuestionAdapter())
      ..registerAdapter(StudyTaskModelAdapter());

    await Hive.openBox<AppSettings>('settings');
    await Hive.openBox<NoteModel>('notes');
    await Hive.openBox<VoiceNoteModel>('voice_notes');
    await Hive.openBox<FlashcardModel>('flashcards');
    await Hive.openBox<QuizModel>('quizzes');
    await Hive.openBox<StudyTaskModel>('study_tasks_v4');
  }
}
