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
          "schema": {
            "type": "object",
            "properties": {
              "profile": UserProfile.toJsonSchema(),
              "questions": {
                "type": "array",
                "items": {
                  "type": "string",
                },
              },
            },
            'required': ['profile', 'questions'],
            'additionalProperties': false,
          },
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

  static ProfileUpdateResponse fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      profile: UserProfile.fromJson(json['profile']),
      questions: List<String>.from(json['questions']),
    );
  }

  static ProfileUpdateResponse fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return ProfileUpdateResponse.fromJson(json);
  }
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
    chatHistory: [userPrompt],
  );

  Logger.log(payload.toJsonString());
  final response = await http.post(
    url,
    headers: headers,
    body: payload.toJsonString(),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    Logger.log("Json Decoded");
    Logger.log(response.body);
    return ProfileUpdateResponse.fromJsonString(responseData['choices'][0]['message']['content']);
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
