import 'dart:convert';

import '../../../data/models/app_settings.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/settings_repository.dart';
import 'openai_client.dart';

class AiRepository {
  AiRepository(this._settingsRepository, this._client);

  final SettingsRepository _settingsRepository;
  final OpenAiClient _client;

  AppSettings _requireSettings() {
    final settings = _settingsRepository.settings;
    if (settings == null || settings.apiKey.trim().isEmpty) {
      throw Exception('Missing API key. Add it in Settings.');
    }
    return settings;
  }

  Future<String> chat(String prompt) async {
    final settings = _requireSettings();
    return _client.generateText(
      apiKey: settings.apiKey,
      model: settings.model,
      systemPrompt:
          'You are a helpful AI study assistant. Answer clearly and concisely.',
      userPrompt: prompt,
    );
  }

  Stream<String> chatStream(String prompt) {
    final settings = _requireSettings();
    return _client.streamText(
      apiKey: settings.apiKey,
      model: settings.model,
      systemPrompt:
          'You are a helpful AI study assistant. Answer clearly and concisely.',
      userPrompt: prompt,
    );
  }

  Future<String> summarize(String text) async {
    final settings = _requireSettings();
    return _client.generateText(
      apiKey: settings.apiKey,
      model: settings.model,
      systemPrompt:
          'You are an expert study assistant. Summarize the text into concise bullet points.',
      userPrompt: text,
    );
  }

  Future<QuizModel> generateQuiz(String topic) async {
    final settings = _requireSettings();
    final response = await _client.generateText(
      apiKey: settings.apiKey,
      model: settings.model,
      systemPrompt:
          'You generate short quizzes. Output strict JSON only with keys: topic, questions. Each question has question, options (4 items), answer.',
      userPrompt: 'Create a 5-question quiz about: $topic',
    );

    final data = jsonDecode(_safeJson(response)) as Map<String, dynamic>;
    final questions = (data['questions'] as List<dynamic>)
        .map(
          (item) => QuizQuestion(
            question: item['question'] as String,
            options: (item['options'] as List<dynamic>).cast<String>(),
            answer: item['answer'] as String,
          ),
        )
        .toList();

    return QuizModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: data['topic'] as String? ?? topic,
      questions: questions,
      createdAt: DateTime.now(),
    );
  }

  Future<List<FlashcardModel>> generateFlashcards(String topic) async {
    final settings = _requireSettings();
    final response = await _client.generateText(
      apiKey: settings.apiKey,
      model: settings.model,
      systemPrompt:
          'You generate flashcards. Output strict JSON only with keys: topic, cards. Each card has front and back.',
      userPrompt: 'Create 6 flashcards for: $topic',
    );

    final data = jsonDecode(_safeJson(response)) as Map<String, dynamic>;
    final cards = (data['cards'] as List<dynamic>)
        .map(
          (item) => FlashcardModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            topic: data['topic'] as String? ?? topic,
            front: item['front'] as String,
            back: item['back'] as String,
            createdAt: DateTime.now(),
          ),
        )
        .toList();

    return cards;
  }

  String _safeJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }
}
