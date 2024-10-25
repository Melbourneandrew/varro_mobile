import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class GreetingStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _greetingsKey = 'greetings';
  static const String _namePlaceholder = '{name}';

  static Future<void> storeGreetings(List<String> greetings) async {
    String encodedGreetings = jsonEncode(greetings);
    await _secureStorage.write(key: _greetingsKey, value: encodedGreetings);
  }

  static Future<List<String>> getGreetings({String? name}) async {
    String? encodedGreetings = await _secureStorage.read(key: _greetingsKey);

    List<String> greetings;
    if (encodedGreetings == null) {
      greetings = _getDefaultGreetings();
      await storeGreetings(greetings);
    } else {
      greetings = List<String>.from(jsonDecode(encodedGreetings));
    }

    if (name != null && name.isNotEmpty) {
      greetings = greetings
          .map((greeting) => greeting.replaceAll(_namePlaceholder, name))
          .toList();
    } else {
      greetings = greetings
          .map((greeting) => greeting.replaceAll(_namePlaceholder, ''))
          .toList();
    }

    return greetings;
  }

  static List<String> _getDefaultGreetings() {
    return [
      'Hello, {name}!',
      'Hi there, {name}!',
      'Greetings, {name}!',
      'Welcome, {name}!',
      'Good to see you, {name}!'
    ];
  }

  static Future<void> addGreeting(String greeting) async {
    List<String> greetings = await getGreetings();
    greetings.add(greeting);
    await storeGreetings(greetings);
  }

  static Future<void> removeGreeting(String greeting) async {
    List<String> greetings = await getGreetings();
    greetings.remove(greeting);
    await storeGreetings(greetings);
  }
}
