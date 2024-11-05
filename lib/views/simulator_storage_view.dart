import 'package:flutter/material.dart';
import 'package:scream_mobile/storage/message_storage.dart';
import 'package:scream_mobile/storage/usage_storage.dart';
import 'package:scream_mobile/storage/question_storage.dart';
import 'package:scream_mobile/storage/profile_storage.dart';
import 'package:scream_mobile/storage/platform_storage.dart';

void main() {
  runApp(const MyApp());
  PlatformStorage.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Debug View',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimulatorStorageView(),
    );
  }
}

class SimulatorStorageView extends StatefulWidget {
  const SimulatorStorageView({super.key});

  @override
  State<SimulatorStorageView> createState() => _SimulatorStorageViewState();
}

class _SimulatorStorageViewState extends State<SimulatorStorageView> {
  Map<String, dynamic> _storageData = {};

  @override
  void initState() {
    super.initState();
    _refreshStorageData();
  }

  Future<void> _refreshStorageData() async {
    final messageCount = await UsageStorage.getMessageCount();
    final messageHistory = await UsageStorage.getMessageHistory();
    final isRegistered = await UsageStorage.isUserRegistered();
    final lastLogin = await UsageStorage.getLastLogin();
    final questions = await QuestionStorage.getQuestions();
    final askedQuestions = await QuestionStorage.getAskedQuestions();
    final profile = await ProfileStorage.getProfile();
    final messages = MessageStorage.messages;

    setState(() {
      _storageData = {
        'Usage Storage': {
          'Message Count': messageCount,
          'Message History': messageHistory,
          'Is Registered': isRegistered,
          'Last Login': lastLogin?.toString() ?? 'Never',
        },
        'Question Storage': {
          'Available Questions': questions,
          'Asked Questions': askedQuestions,
        },
        'Profile Storage': {
          'Profile': profile?.toString() ?? 'No profile',
        },
        'Message Storage': {
          'Messages Count': messages.length,
          'Messages': messages.map((m) => m.toString()).toList(),
        },
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Debug View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStorageData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await MessageStorage.clearMessages();
                  _refreshStorageData();
                },
                child: const Text('Clear Messages'),
              ),
              const SizedBox(height: 16),
              ..._storageData.entries.map((entry) => _buildStorageSection(
                    entry.key,
                    entry.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageSection(String title, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
