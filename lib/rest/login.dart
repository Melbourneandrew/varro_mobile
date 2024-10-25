import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scream_mobile/storage/credential_storage.dart';
import '../agent/dialogue.dart';
import '../storage/token_storage.dart';
import '../storage/usage_storage.dart';
import 'package:scream_mobile/storage/platform_storage.dart';

const int maxRetries = 3;
const Duration retryInterval = Duration(seconds: 5);

Future<String> login(Function(String) speak) async {
  print('Logging in at ${PlatformStorage.loginUrl}...');
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final username = await CredentialStorage.getDeviceId();
      final password = await CredentialStorage.getPassword();

      final response = await http.post(
        Uri.parse(PlatformStorage.loginUrl),
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
        await UsageStorage.setLastLoginNow();
        if(retryCount > 0){
          speak(Dialogue.LoginSuccess);
        }
        print('Login successful. Token: $token');
        return token;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      retryCount++;
      final errorMessage = 'Login failed. Retrying in ${retryInterval.inSeconds} seconds. Attempt $retryCount of $maxRetries.';
      
      if (retryCount == 1) {
        speak(Dialogue.LoginFailed);
      }
      
      print(errorMessage);
      
      if (retryCount < maxRetries) {
        await Future.delayed(retryInterval);
      } else {
        rethrow;
      }
    }
  }

  throw Exception('Failed to login after $maxRetries attempts');
}

Future<void> loginIfNeeded(Function(String) speak) async {
  final lastLogin = await UsageStorage.getLastLogin();
  final now = DateTime.now();
  
  if (lastLogin == null || now.difference(lastLogin).inDays >= 1) {
    await login(speak);
  }
}