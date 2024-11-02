import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/rest/streaming_completion.dart';
import 'package:scream_mobile/storage/profile_storage.dart';
import '../agent/dialogue.dart';
import '../agent/prompts.dart';
import '../storage/platform_storage.dart';
import '../storage/token_storage.dart';
import '../util/logger.dart';

class IdeationCompletionRequestPayload {
  final String systemPrompt;
  final List<Message> chatHistory;

  IdeationCompletionRequestPayload({
    required this.systemPrompt,
    required this.chatHistory,
  });

  // https://platform.openai.com/docs/api-reference/chat
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "model": PlatformStorage.modelName,
      "messages": [
        {
          "role": "system",
          "content": systemPrompt,
        },
        ...chatHistory.map((message) => message.toJson()).toList(),
      ],
      "response_format": {
        "type": "json_schema",
        "json_schema": {
          "name": "user_profile_schema",
          "schema": UserProfile.toJsonSchema(),
          "strict": true
        }
      }
    };

    return json;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
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
  final url = Uri.parse(PlatformStorage.chatCompletionUrl);

  final token = await TokenStorage.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Message systemPrompt = Message(
    role: 'system',
    content: Prompts.UpdateProfileSystemPrompt,
  );
  Message userPrompt = Message(
    role: 'user',
    content: await Prompts.buildUpdateProfilePrompt(),
  );

  final payload = IdeationCompletionRequestPayload(
    systemPrompt: Prompts.UpdateProfileSystemPrompt,
    chatHistory: [systemPrompt, userPrompt],
  );
  final body = payload.toJsonString();
  final response = await http.post(
    url,
    headers: headers,
    body: payload.toJsonString(),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return ProfileUpdateResponse(
      profile: UserProfile.fromJson(responseData['profile']),
      questions: List<String>.from(responseData['questions']),
    );
  } else if (response.statusCode == 401 && !isRetry) {
    speak(Dialogue.UserNotLoggedIn);
    return _attemptUpdateUserProfileAndGenerateQuestions(recentQuestions, speak,
        isRetry: true);
  } else {
    speak(Dialogue.ProfileUpdateFailed);
    throw Exception(
        'Failed to update profile and generate questions: ${response.statusCode} - ${response.body}');
  }
}
