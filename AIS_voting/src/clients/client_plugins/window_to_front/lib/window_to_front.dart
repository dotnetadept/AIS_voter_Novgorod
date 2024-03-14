import 'dart:async';

import 'package:flutter/services.dart';

class WindowToFrontPlugin {
  static const MethodChannel _channel = const MethodChannel('window_to_front');
  static Future<void> focus() async {
    await _channel.invokeMethod('focus');
  }

  static Future<void> unfocus() async {
    await _channel.invokeMethod('unfocus');
  }
}
