import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:scream_mobile/agent/prompts.dart';
import 'package:scream_mobile/agent/dialogue.dart';
import 'package:scream_mobile/rest/streaming_completion.dart';
import 'package:scream_mobile/rest/user_profile_ideation.dart';
import 'package:scream_mobile/storage/greeting_storage.dart';
import 'package:scream_mobile/storage/message_storage.dart';
import 'package:scream_mobile/storage/profile_storage.dart';
import 'package:scream_mobile/storage/question_storage.dart';
import 'package:scream_mobile/util/strip_formatting.dart';

import '../util/logger.dart';

class Agent {
  String model;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  List<Message> messageHistory = [];
  String lastQuestionAsked = "";

  late FlutterTts flutterTts;

  Agent({required this.model}) {
    initTts();
  }

  void initTts() async {
    Logger.log("tts initialized");
    flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-US");
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        // IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        // IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        // IosTextToSpeechAudioCategoryOptions.allowAirPlay,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ],
    );
    flutterTts.setStartHandler(() {
      // print("Playing");
    });

    flutterTts.setCompletionHandler(() {
      // print("Complete");
    });

    flutterTts.setCancelHandler(() {
      // print("Cancel");
    });

    flutterTts.setPauseHandler(() {
      // print("Paused");
    });

    flutterTts.setContinueHandler(() {
      // print("Continued");
    });

    flutterTts.setErrorHandler((msg) {
      Logger.log("tts error: $msg");
    });
  }

  Future<void> textToSpeech(String text) async {
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    await flutterTts.speak(text);
  }

  Future<void> stopTextToSpeech() async {
    await flutterTts.stop();
  }

  Future<String> answerUser(String text, Function(String) speak) async {
    QuestionStorage.removeQuestion(lastQuestionAsked);
    Message message = Message(role: 'user', content: text);
    messageHistory.add(message);
    MessageStorage.saveMessage(message);

    String latestResponse = '';
    try {
      final stream = await streamingCompletion(
        messageHistory,
        Prompts.DefaultSystemPrompt,
        speak,
      );

      String buffer = '';
      int chunkCount = 0;

      // Process the stream, combining every 3 chunks
      await for (String chunk in stream) {
        if (chunk != '') {
          buffer += chunk;
          chunkCount++;
        }

        if (chunkCount == 10) {
          latestResponse += buffer;
          await speak(
              stripFormatting(buffer)); // Process combined chunks for TTS
          buffer = '';
          chunkCount = 0;
        }
      }

      // Handle any remaining chunk in the buffer
      if (buffer.isNotEmpty) {
        latestResponse += buffer;
        await speak(
            stripFormatting(buffer));
      }

      Message responseMessage = Message(role: 'assistant', content: latestResponse);
      messageHistory.add(responseMessage);
      MessageStorage.saveMessage(responseMessage);

      return latestResponse;
    } catch (e) {
      Logger.errorLog("Error in streaming completion: $e");
      return "I'm sorry, I encountered an error while processing your request.";
    }
  }

  Future<String> questionUser(Function(String) speak) async {
    List<String> questions = await QuestionStorage.getQuestions();
    if (questions.isEmpty) {
      Logger.errorLog("No questions in storage (this is bad)");
      return Dialogue.NoQuestionsAvailableToAsk;
    }

    Logger.log("Questions in storage: $questions");

    if (questions.length == 1) {
      updateProfileAndQuestions(speak);
    }

    String question = questions[Random().nextInt(questions.length)];
    lastQuestionAsked = question;
    speak(question);
    return question;
  }

  Future<String> greetUser(Function(String) speak) async {
    UserProfile? profile = await ProfileStorage.getProfile();
    String? name = profile?.name;

    List<String> greetings = await GreetingStorage.getGreetings(name: name);
    String greeting = greetings[Random().nextInt(greetings.length)];

    await speak(greeting);
    return greeting;
  }

  Future<void> updateProfileAndQuestions(Function(String) speak) async {
    List<String> recentQuestions = await QuestionStorage.getAskedQuestions();

    try {
      ProfileUpdateResponse? response =
          await updateUserProfileAndGenerateQuestions(recentQuestions, speak);
      if (response == null) {
        return; // Profile is already up to date
      }

      await ProfileStorage.updateProfile(response.profile);
      Logger.log("Updated profile: ${response.profile.toString()}");

      await QuestionStorage.addQuestions(response.questions);
      Logger.log("Added questions: ${response.questions.toString()}");
    } catch (e) {
      Logger.errorLog("Error updating profile and questions: $e");
    }
  }
}
