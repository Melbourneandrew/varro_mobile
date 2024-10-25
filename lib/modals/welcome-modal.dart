import 'package:flutter/material.dart';
import '../main.dart';
import 'package:scream_mobile/modals/modal-states.dart';

class WelcomeModal extends StatelessWidget {
  final Function(ModalState ms) setModalState;
  WelcomeModal({required this.setModalState});

  void enterPersonalKey(){
    print("Entering personal key");
    setModalState(ModalState.openAIKey);
  }
  void closeModal(){
    print("Closing modal");
    setModalState(ModalState.inactive);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
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
        children: [
          const SizedBox(height: 10),
          const Text(
            'Welcome to Eros',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Eros is a voice assistant. Simply speak your questions, and hear the answers.',
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
              "Eros runs on a costly language model. First chats are free; then you'll have to purchase credits for \$0.99" ,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(50, 50, 50, 1) ,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: closeModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(onPressed: enterPersonalKey, child: Text("I have my own OpenAI API key"))
        ],
      ),
    );
  }
}