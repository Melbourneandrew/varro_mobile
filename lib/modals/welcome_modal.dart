import 'package:flutter/material.dart';
import '../main.dart';
import 'package:scream_mobile/modals/modal_states.dart';

import '../util/logger.dart';

class WelcomeModal extends StatelessWidget {
  static const String TITLE = "Meet Varro";
  static const String VARRO_DESCRIPTION = "Varro is a speak-first voice assistant. You can initiate a conversation at any time by pressing anywhere on the screen and talking out-load. If you wait a while, Varro will speak to you without any prompting!";
  static const String PROFILE_IDEATON_DESCRIPTION = "The questions Varro asks are based on your 'profile' that is built up over time. This profile is stored on your device and is never shared with anyone.";
  static const String OPENAI_API_KEY_DESCRIPTION = "To chat with Varro, you will need and OpenAI API key.";
  static const String GET_STARTED_BUTTON_TEXT = "Get Started";

  final Function(ModalState ms) setModalState;
  const WelcomeModal({super.key, required this.setModalState});

  void routeToAboutPage(){
    Logger.log("Routing to about page");
    // TODO: Open the about page
  }

  void enterPersonalKey(){
    Logger.log("Switching to OpenAI key modal");
    setModalState(ModalState.openAIKey);
  }
  void closeModal(){
    Logger.log("Closing modal");
    setModalState(ModalState.inactive);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text(
            TITLE,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              VARRO_DESCRIPTION,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(50, 50, 50, 1) ,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              PROFILE_IDEATON_DESCRIPTION,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(50, 50, 50, 1) ,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              OPENAI_API_KEY_DESCRIPTION,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(50, 50, 50, 1) ,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: enterPersonalKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              GET_STARTED_BUTTON_TEXT,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(onPressed: routeToAboutPage, child: const Text("Learn More"))
        ],
      ),
    );
  }
}