import 'package:hive_ce/hive.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  final Box<AppSettings> _box;

  AppSettings? get settings => _box.get('settings');

  Future<void> save(AppSettings settings) async {
    await _box.put('settings', settings);
  }
}
