import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/modal_states.dart';
import 'package:scream_mobile/storage/token_storage.dart';
import 'package:scream_mobile/util/logger.dart';

class OpenAIKeyModal extends StatelessWidget {
  final Function(ModalState ms) setModalState;
  final bool closable;
  const OpenAIKeyModal({
    super.key,
    required this.setModalState,
    this.closable = false,
  });

  void setPersonalKey(String apiKey) {
    Logger.log("Setting personal OpenAI key: $apiKey");
    TokenStorage.saveToken(apiKey);
    closeModal();
  }

  void closeModal() {
    Logger.log("Closing modal");
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
            offset: const Offset(4, 4),
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
      child: Stack(
        children: [
          Column(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
          if (closable)
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: closeModal,
              ),
            ),
        ],
      ),
    );
  }
}
