import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  UserPreferences _preferences = UserPreferences();
  bool _isLoading = true;

  PreferencesProvider() {
    _loadPreferences();
  }

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? prefsJson = prefs.getString('user_preferences');

    if (prefsJson != null) {
      _preferences = UserPreferences.fromJson(jsonDecode(prefsJson));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> savePreferences(UserPreferences newPreferences) async {
    _preferences = newPreferences;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user_preferences', jsonEncode(newPreferences.toJson()));

    notifyListeners();
  }

  Future<void> updatePriorityItems(List<String> items) async {
    final newPrefs = _preferences.copyWith(priorityItems: items);
    await savePreferences(newPrefs);
  }

  Future<void> updateAssistantCharacter(String character) async {
    final newPrefs = _preferences.copyWith(assistantCharacter: character);
    await savePreferences(newPrefs);
  }

  Future<void> updateThemeColor(String color) async {
    final newPrefs = _preferences.copyWith(themeColor: color);
    await savePreferences(newPrefs);
  }

  Future<void> completeTutorial() async {
    final newPrefs = _preferences.copyWith(tutorialCompleted: true);
    await savePreferences(newPrefs);
  }
}
