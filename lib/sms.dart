import 'dart:async';

import 'package:flutter/services.dart';

class Sms {
  static const MethodChannel _channel =
      const MethodChannel('sms');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
