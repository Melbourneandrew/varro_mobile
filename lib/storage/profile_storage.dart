import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileStorage {
  static const String _key = 'user_profile';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, profile.toJsonString());
  }

  static Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? profileJson = prefs.getString(_key);
    if (profileJson == null) return null;

    return UserProfile.fromJsonString(profileJson);
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  static Future<void> updateProfile(UserProfile updatedProfile) async {
    await saveProfile(updatedProfile);
  }
}

class UserProfile {
  String name;
  String interests;
  String goals;
  String events;
  DateTime lastUpdate;

  UserProfile({
    required this.name,
    required this.interests,
    required this.goals,
    required this.events,
    required this.lastUpdate,
  });

  UserProfile.empty() : this(
    name: "",
    interests: "",
    goals: "",
    events: "",
    lastUpdate: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'interests': interests,
      'goals': goals,
      'events': events,
      'last_update': lastUpdate.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      interests: json['interests'],
      goals: json['goals'],
      events: json['events'],
      lastUpdate: DateTime.parse(json['last_update']),
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static UserProfile fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return UserProfile.fromJson(json);
  }

  @override
  String toString() {
    return 'UserProfile{name: $name, interests: $interests, goals: $goals, events: $events, lastUpdate: $lastUpdate}';
  }

  static Map<String, dynamic> toJsonSchema() {
    return {
      'type': 'object',
      'properties': {
        'name': {'type': 'string'},
        'interests': {'type': 'string'},
        'goals': {'type': 'string'},
        'events': {'type': 'string'},
        'last_update': {'type': 'string'},
      },
      'required': ['name', 'interests', 'goals', 'events', 'last_update'],
      'additionalProperties': false,
    };
  }
}
