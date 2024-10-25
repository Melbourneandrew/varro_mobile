import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/modal-states.dart';
import '../store.dart';

class OpenAIKeyModal extends StatelessWidget {
  final Function(ModalState ms) setModalState;
  OpenAIKeyModal({required this.setModalState});

  void setPersonalKey(String apiKey) {
    print("Setting personal OpenAI key: $apiKey");
    Store.setPersonalOpenAIKey(apiKey);
    closeModal();
  }

  void closeModal() {
    print("Closing modal");
    setModalState(ModalState.inactive);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController apiKeyController = TextEditingController();

    return Container(
      width: 300,
      height: 300,
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
            'Enter OpenAI API key',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                hintText: 'Enter your API key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              String apiKey = apiKeyController.text;
              if (apiKey.isNotEmpty) {
                setPersonalKey(apiKey);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Set Key',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
