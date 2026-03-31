class FlashcardModel {
  FlashcardModel({
    required this.id,
    required this.topic,
    required this.front,
    required this.back,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String front;
  final String back;
  final DateTime createdAt;
}
