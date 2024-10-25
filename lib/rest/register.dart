import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/storage/credential_storage.dart';
import 'package:scream_mobile/storage/platform_storage.dart';
import '../agent/dialogue.dart';
import '../storage/token_storage.dart';
import '../storage/usage_storage.dart';

const int maxRetries = 3;
const Duration retryInterval = Duration(seconds: 5);

Future<void> register(Function(String) speak) async {
  print('Registering at ${PlatformStorage.registerUrl}...');
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final username = await CredentialStorage.getDeviceId();
      final password = await CredentialStorage.getPassword();

      final response = await http.post(
        Uri.parse(PlatformStorage.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['token'] ?? '';
        await TokenStorage.saveToken(token);
        await UsageStorage.setUserRegistered(true);
        await UsageStorage.setLastLoginNow();
        print('Registration successful. Token: $token');
        return token;
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      retryCount++;
      final errorMessage = 'Registration failed. Retrying in ${retryInterval.inSeconds} seconds. Attempt $retryCount of $maxRetries.';
      print(errorMessage);
      
      if (retryCount == 1) {
        speak(Dialogue.RegisterFailed);
      }

      if (retryCount < maxRetries) {
        await Future.delayed(retryInterval);
      }
    }
  }

  throw Exception('Failed to register after $maxRetries attempts');
}

