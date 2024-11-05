import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/modal_states.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/storage/token_storage.dart';
import 'package:scream_mobile/util/logger.dart';

class OpenAIModelModal extends StatelessWidget {
  final Function(ModalState ms) setModalState;
  final bool closable;
  const OpenAIModelModal({
    super.key,
    required this.setModalState,
    this.closable = false,
  });

  void setModelName(String modelName) {
    Logger.log("Setting model name: $modelName");
    PlatformStorage.setModelName(modelName);
    closeModal();
  }

  void closeModal() {
    Logger.log("Closing modal");
    setModalState(ModalState.inactive);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController modelNameController = TextEditingController();

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
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Enter OpenAI Model Name',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: modelNameController,
                  decoration: InputDecoration(
                    hintText: 'Model name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  String modelName = modelNameController.text;
                  if (modelName.isNotEmpty) {
                    setModelName(modelName);
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
                  'Set Model Name',
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
