import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state.dart';

class AppStorage {
  static const String _stateKey = 'spin_master_state_v1';

  Future<AppState?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppState.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveState(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
  }
}
