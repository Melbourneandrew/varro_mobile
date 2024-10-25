import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scream_mobile/ball-swirl.dart';
import 'package:scream_mobile/agent/dictate.dart';
import 'package:scream_mobile/modals/openai-key-modal.dart';
import 'package:scream_mobile/modals/welcome-modal.dart';
import 'package:scream_mobile/modals/modal-states.dart';
import 'package:scream_mobile/rest/login.dart';
import 'package:scream_mobile/rest/register.dart';
import 'package:scream_mobile/util/silence_timer.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/storage/usage_storage.dart';
import 'package:scream_mobile/util/logger.dart';
import 'FadingText.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'agent/agent.dart';
import 'modals/pay-modal.dart';

void main() {
  runApp(const MyApp());
  PlatformStorage.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(backgroundColor: Colors.white, body: ConvoView()),
    );
  }
}

class ConvoView extends StatefulWidget {
  const ConvoView({super.key});

  @override
  _ConvoViewState createState() => _ConvoViewState();
}

class _ConvoViewState extends State<ConvoView> {
  final GlobalKey<BallSwirlState> ballSwirlKey = GlobalKey();
  final GlobalKey<FadingTextButtonWidgetState> fadingTextState = GlobalKey();
  late Agent agent = Agent(model: "gpt-4o-mini");
  String dictationResult = '';
  final Dictate dictate = Dictate();
  ModalState modalState = ModalState.inactive;
  bool responseStopped = false;
  double textTopOffset = 0.0;
  bool pushTextDown = false;
  late final SilenceTimer silenceTimer;
  final int silenceTimerDuration = 10; // seconds

  @override
  void initState() {
    super.initState();
    silenceTimer = SilenceTimer(silenceTimerDuration, speakToUserAfterSilence);
    silenceTimer.start();
    firstTimeSetup();
  }

  @override
  void dispose() {
    silenceTimer.stop();
    super.dispose();
  }

  void firstTimeSetup() async {
    if (await UsageStorage.firstTimeOpeningApp()) {
      // setState(() {
      //   modalState = ModalState.welcome;
      // });
      // Store.addCredits(100);
    }
    if (!await UsageStorage.isUserRegistered()) {
      await register(speak);
    }
    await loginIfNeeded(speak);
  }

  void screenPressed() {
    print("Screen pressed");
    silenceTimer.stop();
    responseStopped = true;
    fadingTextState.currentState?.resetOpacity();
    //reset the dictation text
    //reset the fading text opacity
    dictationResult = '';
    pushTextDown = true;

    agent.stopTextToSpeech();
    ballSwirlKey.currentState?.setBallsWave();
    dictate.listen(handleDictationResult);
  }

  void screenReleased() async {
    //Pressing the screen while the assistant is responding should stop the response
    responseStopped = false;
    print("Screen released");
    ballSwirlKey.currentState?.setBallsIdleFloating();
    //Wait for the dictation to complete
    await Future.delayed(const Duration(milliseconds: 250));
    dictate.stopListen();

    String q = dictationResult;
    if (q.isEmpty) {
      print("Empty question");
      return;
    }
    if (responseStopped == true) return;
    //Fade out the dictation text
    fadingTextState.currentState?.fadeOutText();
    if (responseStopped == true) return;
    //Trigger loading animation
    ballSwirlKey.currentState?.setBallsTightCircle();
    if (responseStopped == true) return;
    //Get chat completion for the question
    String response = await agent.answerUser(q, speak);
    if (responseStopped == true) return;
    //Trigger idle animation
    ballSwirlKey.currentState?.setBallsIdleFloating();
    silenceTimer.start();
  }

  void speak(String response) async {
    Logger.speakLog(response);
    //Trigger speaking response animation
    ballSwirlKey.currentState?.setBallsExcitedFloating();
    if (responseStopped == true) return;
    //Speak the response out loud with text to speech
    await agent.textToSpeech(response);
    if (responseStopped == true) return;
    //Trigger idle animation
    ballSwirlKey.currentState?.setBallsIdleFloating();
    silenceTimer.start();
  }

  void speakToUserAfterSilence() async {
    agent.questionUser(speak);
    print("Speaking to user after $silenceTimerDuration seconds of silence.");
    // String somethingToSay = await agent.thinkOfSomethingToSay();
    // speak(somethingToSay);
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void handleDictationResult(SpeechRecognitionResult result) {
    print("Speech result: ${result.recognizedWords}");
    setState(() {
      dictationResult = result.recognizedWords;
      if (pushTextDown) {
        textTopOffset = 0.0;
        pushTextDown = false;
        return;
      }
      //If text is going to wrap, move it up
      final RenderBox textRenderBox = fadingTextState
          .currentState?.textKey.currentContext!
          .findRenderObject() as RenderBox;
      textTopOffset = textRenderBox.size.height;
    });
  }

  void setModalState(ModalState newState) {
    setState(() {
      modalState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails details) {
          if (modalState != ModalState.inactive) return;
          setState(() {
            textTopOffset = 0.0;
          });
          screenPressed();
        },
        onTapUp: (TapUpDetails details) {
          if (modalState != ModalState.inactive) return;
          screenReleased();
        },
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3 -
                  textTopOffset, // Adjust this value as needed
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: FadingText(dictationResult, key: fadingTextState),
              ),
            ),
            BallSwirl(key: ballSwirlKey),
            if (modalState == ModalState.welcome)
              Center(child: WelcomeModal(setModalState: setModalState)),
            if (modalState == ModalState.openAIKey)
              Center(child: OpenAIKeyModal(setModalState: setModalState)),
            if (modalState == ModalState.pay)
              Center(child: PayModal(setModalState: setModalState)),
          ],
        ));
  }
}
