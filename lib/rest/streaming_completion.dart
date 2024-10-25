import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/agent/dialogue.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/storage/token_storage.dart';
import 'package:scream_mobile/util/logger.dart';

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, String> toJson() {
    return {
      "role": role,
      "content": content
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static Message fromJsonString(String jsonString) {
    Map<String, String> json = jsonDecode(jsonString);
    return Message.fromJson(json);
  }
}

class CompletionRequestPayload {
  final String systemPrompt;
  final List<Message> chatHistory;

  CompletionRequestPayload({
    required this.systemPrompt,
    required this.chatHistory,
  });

  // https://platform.openai.com/docs/api-reference/chat
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "model": PlatformStorage.modelName,
      "stream": true,
      "messages": [
        {
          "role": "system",
          "content": systemPrompt,
        },
        ...chatHistory.map((message) => message.toJson()).toList(),
      ],
    };

    return json;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

Future<Stream<String>> streamingCompletion(List<Message> chatHistory,
    String systemPrompt, Function(String) speak) async {
  return _attemptStreamingCompletion(chatHistory, systemPrompt, speak,
      isRetry: false);
}

Future<Stream<String>> _attemptStreamingCompletion(
    List<Message> chatHistory, String systemPrompt, Function(String) speak,
    {required bool isRetry}) async {
  Logger.log(
      'Getting streaming completion at ${PlatformStorage.chatCompletionUrl}...');
  final url = Uri.parse(PlatformStorage.chatCompletionUrl);

  final token = await TokenStorage.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final payload = CompletionRequestPayload(
    systemPrompt: systemPrompt,
    chatHistory: chatHistory,
  );

  print('Chat history:');
  for (var message in chatHistory) {
    print('${message.role}: ${message.content}');
  }

  final body = payload.toJsonString();

  final request = http.Request('POST', url);
  request.headers.addAll(headers);
  request.body = body;

  final streamedResponse = await request.send();

  if (streamedResponse.statusCode == 200) {
    return streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
  } else {
    speak(Dialogue.StreamingCompletionFailed);
    final responseBody = await streamedResponse.stream.bytesToString();
    throw Exception(
        'Failed to get streaming completion: ${streamedResponse.statusCode} - $responseBody');
  }
}
