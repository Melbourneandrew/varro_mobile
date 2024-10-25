import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../rest/user_profile_ideation.dart';

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
  int? id;
  int userId;
  String name;
  String interests;
  String goals;
  String events;
  DateTime lastUpdate;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  UserProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.interests,
    required this.goals,
    required this.events,
    required this.lastUpdate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'interests': interests,
      'goals': goals,
      'events': events,
      'last_update': lastUpdate.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      interests: json['interests'],
      goals: json['goals'],
      events: json['events'],
      lastUpdate: DateTime.parse(json['last_update']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
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
    return 'UserProfile{id: $id, userId: $userId, name: $name, interests: $interests, goals: $goals, events: $events, lastUpdate: $lastUpdate, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt}';
  }
}
