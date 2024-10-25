import 'package:scream_mobile/simulator_utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Dictate {
  late SpeechToText _speechToText;
  bool _speechEnabled = false;

  Dictate() {
    _speechToText = SpeechToText();
    _initSpeech();
    print("Dictate initialized");
  }

  //Check permissions
  _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  void listen(void Function(SpeechRecognitionResult) callback) async {
    // Dictation will not work in simulator, so we generate a random sentence
    if (isRunningInSimulator()) {
      print("Dictating (simulator)...");
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
    print("Dictating...");
    await _speechToText.listen(onResult: callback);
  }

  void stopListen() async {
    print("Stopping dictation");
    await _speechToText.stop();
  }
}
