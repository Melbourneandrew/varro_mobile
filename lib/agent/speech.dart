import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:scream_mobile/util/logger.dart';

class Speech {
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  late FlutterTts flutterTts;

  Speech() {
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


}