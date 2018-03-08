import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class SmsMessage {
  String _sender;
  String _body;

  SmsMessage(this._sender, this._body);

  SmsMessage.fromJson(String json) {
    Map data = JSON.decode(json);
    this._sender = data["sender"];
    this._body = data["body"];
  }

  String get sender => this._sender;

  String get body => this._body;
}

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

  Stream<SmsMessage> get onSmsReceived {
    if (_onSmsReceived == null) {
      print("Creating sms receiver");
      _onSmsReceived = _channel.receiveBroadcastStream()
          .map((dynamic event) => SmsMessage.fromJson(event));
    }
    return _onSmsReceived;
  }
}
