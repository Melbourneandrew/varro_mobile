import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/agent/dialogue.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/storage/token_storage.dart';
import 'package:scream_mobile/util/logger.dart';

class Message {
  final String role;
  final String content;
  final String date;

  // constructor that sets the date as the current date
  Message.withDate({
    required this.role,
    required this.content,
    required this.date
  });

  Message({
    required this.role,
    required this.content,
  }) : date = DateTime.now().toIso8601String();

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

  factory Message.fromJsonWithDate(Map<String, dynamic> json) {
    return Message.withDate(
      role: json['role'],
      content: json['content'],
      date: json['date'],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  String toJsonStringWithDate() {
    return jsonEncode({
      "role": role,
      "content": content,
      "date": date
    });
  }

  static Message fromJsonString(String jsonString) {
    Map<String, String> json = jsonDecode(jsonString);
    return Message.fromJson(json);
  }

  static Message fromJsonStringWithDate(String jsonString) {
    Map<String, String> json = jsonDecode(jsonString);
    return Message.fromJsonWithDate(json);
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

  Logger.log('Chat history:');
  for (var message in chatHistory) {
    Logger.log('${message.role}: ${message.content}');
  }

  final body = payload.toJsonString();

  final request = http.Request('POST', url);
  request.headers.addAll(headers);
  request.body = body;

  final streamedResponse = await request.send();

  if (streamedResponse.statusCode == 200) {
    return streamedResponse.stream
        .transform(utf8.decoder) // Decode bytes into UTF8 characters
        .transform(const LineSplitter()) // Split stream into lines
        .map((line) => line.startsWith('data: ') ? line.substring(6) : line) // Remove the 'data: ' prefix
        .map((line) {
          try {
            return jsonDecode(line); // Attempt to decode each line as JSON
          } catch (e) {
            return {}; // Return an empty JSON object in case of failure
          }
        })
        .where((json) => json.isNotEmpty && json['choices'] != null && json['choices'].isNotEmpty) // Filter out empty JSON and objects without 'choices'
        .map((json) => json['choices'][0]['delta']['content'] ?? ""); // Get the first 'choice'
  } else {
    speak(Dialogue.StreamingCompletionFailed);
    final responseBody = await streamedResponse.stream.bytesToString();
    throw Exception(
        'Failed to get streaming completion: ${streamedResponse.statusCode} - $responseBody');
  }
}
