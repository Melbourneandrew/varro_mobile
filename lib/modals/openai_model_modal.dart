import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/modal_states.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/util/logger.dart';
import 'package:scream_mobile/rest/model_list.dart';

class OpenAIModelModal extends StatefulWidget {
  final Function(ModalState ms) setModalState;
  final bool closable;
  const OpenAIModelModal({
    super.key,
    required this.setModalState,
    this.closable = false,
  });

  @override
  _OpenAIModelModalState createState() => _OpenAIModelModalState();
}

class _OpenAIModelModalState extends State<OpenAIModelModal> {
  late Future<List<String>> _modelsFuture;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _modelsFuture = listOpenAiModels();
  }

  void setModelName(String modelName) {
    Logger.log("Setting model name: $modelName");
    PlatformStorage.setModelName(modelName);
    setState(() {
      _selectedModel = modelName;
    });
    closeModal();
  }

  void closeModal() {
    Logger.log("Closing modal");
    widget.setModalState(ModalState.inactive);
  }

  @override
  Widget build(BuildContext context) {
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
                'Select OpenAI Model',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<String>>(
                future: _modelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No models available');
                  } else {
                    return Flexible(
                        child:DropdownButton<String>(
                          value: _selectedModel,
                          hint: const Text('Select a model'),
                          items: snapshot.data!.map((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedModel = newValue;
                            });
                          },
                        )
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_selectedModel != null)
                Text(
                  'Selected Model: $_selectedModel',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedModel != null) {
                    setModelName(_selectedModel!);
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
          if (widget.closable)
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