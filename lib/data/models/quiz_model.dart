class QuizModel {
  QuizModel({
    required this.id,
    required this.topic,
    required this.questions,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
}

class QuizQuestion {
  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  final String question;
  final List<String> options;
  final String answer;
}
