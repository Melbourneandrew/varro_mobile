import 'package:flutter/material.dart';
import 'package:scream_mobile/rest/streaming_completion.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import 'package:scream_mobile/util/logger.dart';
import 'agent/agent.dart';
import 'package:scream_mobile/storage/token_storage.dart';

void main() {
  runApp(const MyApp());
  PlatformStorage.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulator HUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimulatorHUD(),
    );
  }
}

class SimulatorHUD extends StatefulWidget {
  const SimulatorHUD({Key? key}) : super(key: key);

  @override
  _SimulatorHUDState createState() => _SimulatorHUDState();
}

class _SimulatorHUDState extends State<SimulatorHUD> {
  final TextEditingController _systemPromptController = TextEditingController(
    text: "You are a conversational agent having a casual chat with the user"
  );
  final TextEditingController _userPromptController = TextEditingController(
    text: "Come up with something for us to talk about"
  );
  final TextEditingController _tokenController = TextEditingController();

  String _response = '';
  Agent agent = Agent(model: "gpt-4o-mini");

  void _handleSetToken() {
    final token = _tokenController.text;
    if (token.isNotEmpty) {
      TokenStorage.saveToken(token);
      setState(() {
        _response = 'Token set';
      });
    } else {
      setState(() {
        _response = 'Token cannot be empty';
      });
    }
  }

  void _handleSend() async {
    setState(() {
      _response = 'Sending request...';
    });

    try {
      final chatHistory = [
        Message(role: 'user', content: _userPromptController.text),
      ];

      final stream = await streamingCompletion(
        chatHistory,
        _systemPromptController.text,
        Logger.speakLog
      );

      setState(() {
        _response = '';
      });

      await for (final chunk in stream) {
        setState(() {
          _response += chunk;
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: ${e.toString()}';
      });
    }
  }

  void _handleUpdateProfile() {
    setState(() {
      _response = 'Update Profile button pressed';
    });
      agent.updateProfileAndQuestions(Logger.speakLog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulator HUD')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(labelText: 'API Key'),
                  )
                ),
                ElevatedButton(
                  onPressed: _handleSetToken,
                  child: const Text('Set Token'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _systemPromptController,
              decoration: const InputDecoration(labelText: 'System Prompt'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userPromptController,
              decoration: const InputDecoration(labelText: 'User Prompt'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSend,
              child: const Text('Send'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(_response),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
