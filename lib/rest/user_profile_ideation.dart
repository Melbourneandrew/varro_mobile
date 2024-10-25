import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/rest/login.dart';
import 'package:scream_mobile/rest/streaming_completion.dart';
import 'package:scream_mobile/storage/profile_storage.dart';
import '../agent/dialogue.dart';
import '../storage/platform_storage.dart';
import '../storage/token_storage.dart';
import '../util/logger.dart';

class ProfileUpdateResponse {
  final UserProfile profile;
  final List<String> questions;

  ProfileUpdateResponse({required this.profile, required this.questions});
}

Future<ProfileUpdateResponse?> updateUserProfileAndGenerateQuestions(
    List<String> recentQuestions, Function(String) speak) async {
  return _attemptUpdateUserProfileAndGenerateQuestions(recentQuestions, speak,
      isRetry: false);
}

Future<ProfileUpdateResponse?> _attemptUpdateUserProfileAndGenerateQuestions(
    List<String> recentQuestions, Function(String) speak,
    {required bool isRetry}) async {
  Logger.log('Updating user profile and generating questions...');
  final url = Uri.parse(PlatformStorage.userProfileIdeationUrl);

  final token = await TokenStorage.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final payload = {
    'recent_questions': recentQuestions,
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(payload),
  );
  if (response.statusCode == 208) {
    Logger.log("Profile is already up to date");
    return null;
  } else if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return ProfileUpdateResponse(
      profile: UserProfile.fromJson(responseData['profile']),
      questions: List<String>.from(responseData['questions']),
    );
  } else if (response.statusCode == 401 && !isRetry) {
    speak(Dialogue.UserNotLoggedIn);
    await login(speak);
    return _attemptUpdateUserProfileAndGenerateQuestions(recentQuestions, speak,
        isRetry: true);
  } else {
    speak(Dialogue.ProfileUpdateFailed);
    throw Exception(
        'Failed to update profile and generate questions: ${response.statusCode} - ${response.body}');
  }
}
