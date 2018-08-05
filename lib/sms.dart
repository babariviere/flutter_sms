library sms;

import 'dart:async';

import 'package:flutter/services.dart';

enum SmsMessageState {
  Sending,
  Sent,
  Delivered,
}

enum SmsMessageKind {
  Sent,
  Received,
  Draft,
}

class SmsMessage {
  int             _id;
  int             _threadId;
  String          _address;
  String          _body;
  SmsMessageState _state;
  SmsMessageKind  _kind;
  DateTime        _date;
  DateTime        _dateSent;

  /// Create a new SMS Message
  ///
  /// [this._address]: Address of the sender or receiver
  ///
  /// [this._body]: Message's body
  SmsMessage(this._address, this._body, {
    int id,
    int threadId,
    DateTime date,
    DateTime dateSent,
    SmsMessageKind kind,
  }) {
    this._id = id;
    this._threadId = id;
    this._date = date;
    this._dateSent = dateSent;
    this._kind = kind;
  }

  /// Deserialize map into an SMS message
  ///
  /// # Format:
  ///
  /// ```json
  /// {
  ///   "address": "...",
  ///   "body": "...",
  ///   // everything else is optional
  ///   "id": 10,
  ///   "thread_id": 11,
  ///   "date": epoch_time,
  ///   "date_sent": epoch_time
  /// }
  /// ```
  SmsMessage.fromJson(Map data) {
    if (!data.containsKey("address") || !data.containsKey("body")) {
      throw new Exception("missing key `address` and/or `body`");
    }
    this._address = data["address"];
    this._body = data["body"];
    this._id = data["id"];
    this._threadId = data["thread_id"];
    if (data.containsKey("date")) {
      this._date = new DateTime.fromMillisecondsSinceEpoch(data["date"]);
    }
    if (data.containsKey("date_sent")) {
      this._dateSent =
      new DateTime.fromMillisecondsSinceEpoch(data["date_sent"]);
    }
  }

  /// Serialize SMS message into a Map
  Map get toMap {
    Map res = {};
    res["address"] = this._address;
    res["body"] = this._body;
    res["id"] = this._id;
    res["thread_id"] = this._threadId;
    if (_date != null) {
      res["date"] = _date.millisecondsSinceEpoch;
    }
    if (_dateSent != null) {
      res["date_sent"] = _dateSent.millisecondsSinceEpoch;
    }
    return res;
  }

  /// Message id stored in Android database.
  ///
  /// This can be used to sort messages by time.
  get id => this._id;

  /// Thread id on which the message was sent.
  get threadId => this._threadId;

  /// Address of the sender or receiver.
  get address => this._address;

  /// Message's body
  get body => this._body;

  /// State of the message
  get state => this._state;

  /// Kind of the message
  get kind => this._kind;

  /// Set message kind
  set kind(SmsMessageKind kind) => this._kind = kind;

  /// Date when received or delivered
  get date => this._date;

  /// Set message's date
  set date(DateTime date) => this._date = date;

  /// Date when sent
  get dateSent => this._dateSent;
}

/// A SMS receiver that creates a stream of SMS
///
///
/// Usage:
///
/// ```dart
/// var receiver = SmsReceiver();
/// receiver.stream.listen((SmsMessage msg) => ...);
/// // or you can directly call listen
/// receiver.listen((SmsMessage msg) => ...);
/// ```
class SmsReceiver {
  static SmsReceiver  _instance;
  final EventChannel  _channel;
  Stream<SmsMessage>  _stream;

  factory SmsReceiver() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel(
          "plugins.babariviere.io/recvSMS", const JSONMethodCodec());
      _instance = new SmsReceiver._private(eventChannel);
    }
    return _instance;
  }

  SmsReceiver._private(this._channel);

  /// Legacy function for received SMS
  Stream<SmsMessage> get onSmsReceived {
    return this.stream;
  }

  /// Get stream that return all received SMS
  Stream<SmsMessage> get stream {
    if (this._stream == null) {
      print("Creating sms receiver");
      this._stream = _channel.receiveBroadcastStream().map((dynamic event) {
        SmsMessage msg = new SmsMessage.fromJson(event);
        msg.kind = SmsMessageKind.Received;
        return msg;
      });
    }
    return this._stream;
  }

  /// Listen for SMS
  StreamSubscription<SmsMessage> listen(void onData(SmsMessage sms)) {
    return this.stream.listen(onData);
  }
}