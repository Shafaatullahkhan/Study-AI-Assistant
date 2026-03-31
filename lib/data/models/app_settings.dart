class AppSettings {
  AppSettings({
    required this.apiKey,
    required this.model,
  });

  final String apiKey;
  final String model;

  AppSettings copyWith({
    String? apiKey,
    String? model,
  }) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }
}
