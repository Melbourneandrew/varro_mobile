import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformStorage {
  static const String _productionApiUrl = 'https://api.example.com';
  static const String _developmentApiUrl = 'https://api.openai.com/v1/chat/completions';
  
  static late final bool isSimulator;
  static late final String apiUrl;
  static late final String chatCompletionUrl;
  static late String modelName;

  static Future<bool> _isRunningInSimulator() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    }
    return false;
  }

  // Update initialize method to be asynchronous
  static Future<void> initialize() async {
    isSimulator = await _isRunningInSimulator();
    apiUrl = isSimulator ? _developmentApiUrl : _productionApiUrl;
    chatCompletionUrl = apiUrl;
    modelName = 'gpt-4o-mini';
  }

  static void setModelName(String name) {
    modelName = name;
  }
}
