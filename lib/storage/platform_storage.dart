import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformStorage {
  static const String _productionApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _developmentApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String modelListUrl = 'https://api.openai.com/v1/models';

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
    modelName = await getModelName();
  }

  static void setModelName(String name) {
    modelName = name;
  }

  static Future<String> getModelName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('modelName') ?? 'gpt-4o-mini';
  }
}
