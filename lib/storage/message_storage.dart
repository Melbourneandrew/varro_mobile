import 'package:scream_mobile/rest/streaming_completion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageStorage {
  static List<Message> messages = [];

  static Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('messages');
    if (messagesJson != null) {
      messages = messagesJson.map((e) => Message.fromJsonStringWithDate(e)).toList();
    }
  }

  static Future<List<Message>> getMessageHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('messages');
    if (messagesJson != null) {
      return messagesJson.map((e) => Message.fromJsonStringWithDate(e)).toList();
    }
    return [];
  }

  static Future<void> saveMessage(Message message) async {
    messages.add(message);

    if (messages.length > 30) {
      messages.removeAt(0);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('messages', messages.map((e) => e.toJsonStringWithDate()).toList());
  }

  static Future<void> clearMessages() async {
    messages = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('messages');
  }

  static Future<void> setLastMessageFromProfileUpdate() async {
    Message lastMessage = messages.last;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastMessageFromProfileUpdate', lastMessage.toJsonStringWithDate());
  }

  static Future<List<Message>> getMessagesSinceLastProfileUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMessageJson = prefs.getString('lastMessageFromProfileUpdate');
    if (lastMessageJson == null) {
      return messages;
    }

    Message lastMessage = Message.fromJsonStringWithDate(lastMessageJson);
    int lastMessageIndex = messages.indexOf(lastMessage);
    if (lastMessageIndex == -1) {
      return messages;
    }

    return messages.sublist(lastMessageIndex + 1);
  }
}