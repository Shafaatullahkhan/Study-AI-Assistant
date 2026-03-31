class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String summary;
  final DateTime createdAt;
}
