import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math';

class CredentialStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<void> _storePassword(String password) async {
    String deviceId = await getDeviceId();
    await _secureStorage.write(key: deviceId, value: password);
  }

  static Future<String?> getPassword() async {
    String deviceId = await getDeviceId();
    String? storedPassword = await _secureStorage.read(key: deviceId);
    
    if (storedPassword == null) {
      String generatedPassword = _generatePassword();
      await _storePassword(generatedPassword);
      return generatedPassword;
    }
    
    return storedPassword;
  }

  static String _generatePassword({int length = 16}) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<String> getDeviceId() async {
    IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? 'unknown';
  }
}
