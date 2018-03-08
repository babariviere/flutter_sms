/// An SMS library for flutter
library sms;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// A SMS Message
class SmsMessage {
  String _sender;
  String _body;

  SmsMessage(this._sender, this._body);

  /// Read message fron JSON
  ///
  /// Format:
  ///
  /// ```json
  /// {
  ///   "sender": "phone-number-here",
  ///   "body": "text message here"
  /// }
  /// ```
  SmsMessage.fromJson(String json) {
    Map data = JSON.decode(json);
    this._sender = data["sender"];
    this._body = data["body"];
  }

  String get sender => this._sender;

  String get body => this._body;
}

/// A SMS receiver that creates a stream of SMS
///
///
/// Usage:
///
/// ```dart
/// SmsReceiver().onSmsReceived.listen((SmsMessage msg) => ...);
/// ```
class SmsReceiver {
  static SmsReceiver _instance;
  final EventChannel _channel;
  Stream<SmsMessage> _onSmsReceived;

  factory SmsReceiver() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel(
          "plugins.babariviere.com/recvSms");
      _instance = new SmsReceiver._private(eventChannel);
    }
    return _instance;
  }

  SmsReceiver._private(this._channel);

  /// Create a stream that collect received SMS
  Stream<SmsMessage> get onSmsReceived {
    if (_onSmsReceived == null) {
      print("Creating sms receiver");
      _onSmsReceived = _channel.receiveBroadcastStream()
          .map((dynamic event) => SmsMessage.fromJson(event));
    }
    return _onSmsReceived;
  }
}

// TODO: Sms Server, Sms Delivery, Sms