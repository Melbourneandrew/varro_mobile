import 'dart:async';

class SilenceTimer {
  Timer? _silenceTimer;
  int _interval = 0; // Seconds
  Function()? _callback;

  SilenceTimer(int intervalSeconds, Function() callback) {
    _interval = intervalSeconds;
    _callback = callback;
  }

  void start() {
    stop();
    _silenceTimer = Timer(Duration(seconds: _interval), _callback!);
  }

  void stop() {
    _silenceTimer?.cancel();
  }
}