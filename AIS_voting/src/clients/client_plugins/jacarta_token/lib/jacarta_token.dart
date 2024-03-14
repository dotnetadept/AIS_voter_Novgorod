import 'dart:async';
import 'package:flutter/services.dart';

class JacartaTokenPlugin {
  static const MethodChannel _channel = const MethodChannel('jacarta_token');
  static Future<int> initialize() async {
    int result;

    try {
      await _channel
          .invokeMethod('initialize')
          .then((value) => result = int.parse(value.toString()));
    } finally {}

    return result;
  }

  static Future<int> finalize() async {
    int result;

    try {
      await _channel
          .invokeMethod('finalize')
          .then((value) => result = int.parse(value.toString()));
    } finally {}

    return result;
  }

  static Future<int> getSlots() async {
    int result;

    try {
      await _channel
          .invokeMethod('get_slots')
          .then((value) => result = int.parse(value.toString()));
    } finally {}

    return result;
  }

  static Future<String> getToken() async {
    String result;

    try {
      await _channel
          .invokeMethod('get_token')
          .then((value) => result = value.toString());
    } finally {}

    return result;
  }
}
