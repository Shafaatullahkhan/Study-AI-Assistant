import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce/hive.dart';

import 'core/services/ai/ai_repository.dart';
import 'core/services/ai/openai_client.dart';
import 'core/services/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'data/models/app_settings.dart';
import 'data/models/flashcard_model.dart';
import 'data/models/note_model.dart';
import 'data/models/quiz_model.dart';
import 'data/models/study_task_model.dart';
import 'data/models/voice_note_model.dart';
import 'data/repositories/flashcards_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'data/repositories/quizzes_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/study_tasks_repository.dart';
import 'data/repositories/voice_notes_repository.dart';
import 'features/root/root_view.dart';
import 'core/services/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  final notifications = await NotificationService.init();
  await notifications.requestPermissions();
  runApp(StudyAssistantApp(notifications: notifications));
}

class StudyAssistantApp extends StatelessWidget {
  const StudyAssistantApp({super.key, required this.notifications});

  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => SettingsRepository(Hive.box<AppSettings>('settings')),
        ),
        Provider(
          create: (_) => NotesRepository(Hive.box<NoteModel>('notes')),
        ),
        Provider(
          create: (_) =>
              VoiceNotesRepository(Hive.box<VoiceNoteModel>('voice_notes')),
        ),
        Provider(
          create: (_) =>
              FlashcardsRepository(Hive.box<FlashcardModel>('flashcards')),
        ),
        Provider(
          create: (_) => QuizzesRepository(Hive.box<QuizModel>('quizzes')),
        ),
        Provider(
          create: (_) =>
              StudyTasksRepository(Hive.box<StudyTaskModel>('study_tasks_v4')),
        ),
        Provider(
          create: (_) => notifications,
        ),
        Provider(
          create: (context) => AiRepository(
            context.read<SettingsRepository>(),
            OpenAiClient(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Study Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootView(),
      ),
    );
  }
}
