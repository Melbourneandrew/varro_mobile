import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionStorage {
  static const String _key = 'assistant_questions';
  static const String _askedQuestionsKey = 'already_asked_questions';

  static Future<void> addQuestions(List<String> newQuestions) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingQuestions = await getQuestions();
    existingQuestions.insertAll(0, newQuestions);
    await prefs.setString(_key, jsonEncode(existingQuestions));
  }

  static Future<bool> removeQuestion(String question) async {
    if (question.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    List<String> questions = await getQuestions();
    List<String> askedQuestions = await getAskedQuestions();

    if (questions.remove(question)) {
      askedQuestions.add(question);
      if (askedQuestions.length > 10) {
        askedQuestions = askedQuestions.sublist(0, 10);
      }
      await prefs.setString(_key, jsonEncode(questions));
      await prefs.setString(_askedQuestionsKey, jsonEncode(askedQuestions));
      return true;
    }
    return false;
  }

  static Future<List<String>> getQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    String? questionsJson = prefs.getString(_key);
    if (questionsJson == null) return [];
    return List<String>.from(jsonDecode(questionsJson));
  }

  static Future<List<String>> getAskedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    String? askedQuestionsJson = prefs.getString(_askedQuestionsKey);
    if (askedQuestionsJson == null) return [];
    return List<String>.from(jsonDecode(askedQuestionsJson));
  }

  static Future<void> clearQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> clearAskedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_askedQuestionsKey);
  }
}
