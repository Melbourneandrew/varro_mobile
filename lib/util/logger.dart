import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static void speakLog(String message) {
    if (kDebugMode) {
      print("[Speaking] $message");
    }
  }

  static void errorLog(String message) {
    if (kDebugMode) {
      print("[Error] $message");
    }
  }
}
