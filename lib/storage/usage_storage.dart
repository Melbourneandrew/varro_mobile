import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UsageStorage {
  static const String _messageCountKey = 'message_count';
  static const String _messageHistoryKey = 'message_history';
  static const int _maxHistoryLength = 5;
  static const String _isUserRegisteredKey = 'is_user_registered';
  static const String _lastLoginKey = 'last_login';

  static Future<void> incrementMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_messageCountKey) ?? 0;
    await prefs.setInt(_messageCountKey, currentCount + 1);
  }

  static Future<int> getMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_messageCountKey) ?? 0;
  }

  static Future<void> addMessageToHistory(String role, String content) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_messageHistoryKey) ?? [];

    String newMessage = jsonEncode({'role': role, 'content': content});
    history.add(newMessage);

    if (history.length > _maxHistoryLength) {
      history = history.sublist(history.length - _maxHistoryLength);
    }

    await prefs.setStringList(_messageHistoryKey, history);
  }

  static Future<List<Map<String, String>>> getMessageHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_messageHistoryKey) ?? [];

    return history.map((message) {
      Map<String, dynamic> decodedMessage = jsonDecode(message);
      return {
        'role': decodedMessage['role'] as String,
        'content': decodedMessage['content'] as String,
      };
    }).toList();
  }

  static Future<bool> firstTimeOpeningApp() async {
    final prefs = await SharedPreferences.getInstance();
    bool first = prefs.getBool('firstTimeOpeningApp') ?? true;
    if (first) {
      await prefs.setBool('firstTimeOpeningApp', false);
    }
    print("First time opening app: $first");
    return first;
  }

  static Future<void> setUserRegistered(bool isRegistered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isUserRegisteredKey, isRegistered);
  }

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isUserRegisteredKey) ?? false;
  }

  static Future<void> setLastLoginNow() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastLoginKey, now);
  }

  static Future<DateTime?> getLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginString = prefs.getString(_lastLoginKey);
    return lastLoginString != null ? DateTime.parse(lastLoginString) : null;
  }
}
