/// An SMS library for flutter
library sms;

import 'dart:async';

import 'package:flutter/services.dart';

/// A SMS Message
class SmsMessage {
  String _address;
  String _body;

  SmsMessage(this._address, this._body);

  /// Read message fron JSON
  ///
  /// Format:
  ///
  /// ```json
  /// {
  ///   "address": "phone-number-here",
  ///   "body": "text message here"
  /// }
  /// ```
  SmsMessage.fromJson(Map data) {
    this._address = data["address"];
    this._body = data["body"];
  }

  /// Convert SMS to map
  Map get toMap => {'address': this._address, 'body': this._body};

  /// Get sender, alias phone number
  String get sender => this._address;

  /// Get address, alias phone number
  String get address => this._address;

  /// Get message body
  String get body => this._body;
}

/// A SMS receiver that creates a stream of SMS
///
///
/// Usage:
///
/// ```dart
/// var receiver = SmsReceiver();
/// receiver.onSmsReceived.listen((SmsMessage msg) => ...);
/// ```
class SmsReceiver {
  static SmsReceiver _instance;
  final EventChannel _channel;
  Stream<SmsMessage> _onSmsReceived;

  factory SmsReceiver() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel(
          "plugins.babariviere.com/recvSMS", const JSONMethodCodec());
      _instance = new SmsReceiver._private(eventChannel);
    }
    return _instance;
  }

  SmsReceiver._private(this._channel);

  /// Create a stream that collect received SMS
  Stream<SmsMessage> get onSmsReceived {
    if (_onSmsReceived == null) {
      print("Creating sms receiver");
      _onSmsReceived = _channel.receiveBroadcastStream().map(
              (dynamic event) => SmsMessage.fromJson(event)
      );
    }
    return _onSmsReceived;
  }
}

/// Called when SMS is sent (don't check if it's delivered
typedef void SmsHandlerSucc();
/// Called when sending SMS failed
typedef void SmsHandlerFail(Object e);

/// A SMS sender
class SmsSender {
  static SmsSender _instance;
  final MethodChannel _channel;

  factory SmsSender() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/sendSMS", const JSONMethodCodec());
      _instance = new SmsSender._private(methodChannel);
    }
    return _instance;
  }

  SmsSender._private(this._channel);

  /// Send an SMS
  ///
  /// Take a message in argument + 2 functions that will be called on success or on error
  Future<Null> sendSms(SmsMessage msg, {SmsHandlerSucc onSuccess, SmsHandlerFail onError}) async {
    if (msg == null || msg.address == null || msg.body == null) {
      if (onError != null) {
        if (msg == null) {
          onError("no given message");
        } else if (msg.address == null) {
          onError("no given address");
        } else if (msg.body == null) {
          onError("no given body");
        }
      }
      return;
    }
    await _channel.invokeMethod("sendSMS", msg.toMap).then((dynamic val) {
      if (onSuccess != null) {
        onSuccess();
      }
    }, onError: (dynamic e) {
      if (onError != null) {
        onError(e);
      }
    });
  }
}