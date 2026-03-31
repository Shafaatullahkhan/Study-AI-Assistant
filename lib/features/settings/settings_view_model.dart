import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository) {
    final settings = _repository.settings;
    apiKeyController.text = settings?.apiKey ?? '';
    modelController.text = settings?.model ?? 'gpt-4.1-mini';
  }

  final SettingsRepository _repository;

  final apiKeyController = TextEditingController();
  final modelController = TextEditingController();

  bool _saved = false;
  bool get saved => _saved;

  Future<void> save() async {
    final settings = AppSettings(
      apiKey: apiKeyController.text.trim(),
      model: modelController.text.trim().isEmpty
          ? 'gpt-4.1-mini'
          : modelController.text.trim(),
    );
    await _repository.save(settings);
    _saved = true;
    notifyListeners();
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    modelController.dispose();
    super.dispose();
  }
}
