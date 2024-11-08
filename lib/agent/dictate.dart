import 'package:scream_mobile/simulator_utils.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/util/logger.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Dictate {
  late SpeechToText _speechToText;

  Dictate() {
    _speechToText = SpeechToText();
    _initSpeech();
    Logger.log("Dictate initialized");
  }

  //Check permissions
  _initSpeech() async {
    await _speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  void listen(void Function(SpeechRecognitionResult) callback) async {
    // Dictation will not work in simulator, so we generate a random sentence
    if (PlatformStorage.isSimulator) {
      Logger.log("Dictating (simulator)...");
      String dicText = "";
      for (int i = 0; i < 5; i++) {
        dicText += generateRandomSentence();
        callback(SpeechRecognitionResult(
          [SpeechRecognitionWords(dicText, 1.0)],
          true,
        ));
        await Future.delayed(const Duration(milliseconds: 300));
      }
      return;
    }
    Logger.log("Dictating...");
    await _speechToText.listen(onResult: callback);
  }

  void stopListen() async {
    Logger.log("Stopping dictation");
    await _speechToText.stop();
  }
}
