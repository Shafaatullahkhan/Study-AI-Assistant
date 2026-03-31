class VoiceNoteModel {
  VoiceNoteModel({
    required this.id,
    required this.transcript,
    required this.createdAt,
  });

  final String id;
  final String transcript;
  final DateTime createdAt;
}
