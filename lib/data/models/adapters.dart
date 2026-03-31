import 'package:hive_ce/hive.dart';

import 'app_settings.dart';
import 'flashcard_model.dart';
import 'note_model.dart';
import 'quiz_model.dart';
import 'study_task_model.dart';
import 'voice_note_model.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final apiKey = reader.readString();
    final model = reader.readString();
    return AppSettings(apiKey: apiKey, model: model);
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.writeString(obj.apiKey);
    writer.writeString(obj.model);
  }
}

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 1;

  @override
  NoteModel read(BinaryReader reader) {
    return NoteModel(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      summary: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.summary);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

class VoiceNoteModelAdapter extends TypeAdapter<VoiceNoteModel> {
  @override
  final int typeId = 2;

  @override
  VoiceNoteModel read(BinaryReader reader) {
    return VoiceNoteModel(
      id: reader.readString(),
      transcript: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, VoiceNoteModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.transcript);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 3;

  @override
  FlashcardModel read(BinaryReader reader) {
    return FlashcardModel(
      id: reader.readString(),
      topic: reader.readString(),
      front: reader.readString(),
      back: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.topic);
    writer.writeString(obj.front);
    writer.writeString(obj.back);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

class QuizModelAdapter extends TypeAdapter<QuizModel> {
  @override
  final int typeId = 4;

  @override
  QuizModel read(BinaryReader reader) {
    final questionCount = reader.readInt();
    final questions = <QuizQuestion>[];
    for (var i = 0; i < questionCount; i++) {
      questions.add(reader.read() as QuizQuestion);
    }
    return QuizModel(
      id: reader.readString(),
      topic: reader.readString(),
      questions: questions,
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, QuizModel obj) {
    writer.writeInt(obj.questions.length);
    for (final question in obj.questions) {
      writer.write(question);
    }
    writer.writeString(obj.id);
    writer.writeString(obj.topic);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 5;

  @override
  QuizQuestion read(BinaryReader reader) {
    return QuizQuestion(
      question: reader.readString(),
      options: (reader.readList()).cast<String>(),
      answer: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer.writeString(obj.question);
    writer.writeList(obj.options);
    writer.writeString(obj.answer);
  }
}

class StudyTaskModelAdapter extends TypeAdapter<StudyTaskModel> {
  @override
  final int typeId = 6;

  @override
  StudyTaskModel read(BinaryReader reader) {
    return StudyTaskModel(
      id: reader.readString(),
      subject: reader.readString(),
      task: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      status: StudyTaskStatus.values[reader.readInt()],
      reminderAt: _readNullableDate(reader),
      recurrence: _readRecurrence(reader),
      repeatUntil: _readNullableDate(reader),
    );
  }

  @override
  void write(BinaryWriter writer, StudyTaskModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subject);
    writer.writeString(obj.task);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.reminderAt?.millisecondsSinceEpoch ?? 0);
    writer.writeInt(obj.recurrence.index);
    writer.writeInt(obj.repeatUntil?.millisecondsSinceEpoch ?? 0);
  }
}

DateTime? _readNullableDate(BinaryReader reader) {
  if (reader.availableBytes <= 0) return null;
  final value = reader.readInt();
  if (value == 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(value);
}

RecurrenceRule _readRecurrence(BinaryReader reader) {
  if (reader.availableBytes <= 0) return RecurrenceRule.none;
  final index = reader.readInt();
  if (index < 0 || index >= RecurrenceRule.values.length) {
    return RecurrenceRule.none;
  }
  return RecurrenceRule.values[index];
}
