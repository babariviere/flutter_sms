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

class SmsMessage implements Comparable<SmsMessage> {
  int _id;
  int _threadId;
  String _address;
  String _body;
  SmsMessageState _state;
  SmsMessageKind _kind;
  DateTime _date;
  DateTime _dateSent;
  StreamController<SmsMessageState> _stateStream;

  /// Create a new SMS Message
  ///
  /// [this._address]: Address of the sender or receiver
  ///
  /// [this._body]: Message's body
  SmsMessage(
    this._address,
    this._body, {
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

  /// Stream returning each change
  Stream<SmsMessageState> get onStateChanged {
    if (_stateStream == null) {
      _stateStream = StreamController<SmsMessageState>();
    }
    return _stateStream.stream;
  }

  /// Set message state
  set state(SmsMessageState state) {
    if (this._state != state) {
      this._state = state;
      if (_stateStream != null) {
        _stateStream.add(state);
      }
    }
  }

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

  @override
  int compareTo(SmsMessage other) {
    return other._id - this._id;
  }
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
  static SmsReceiver _instance;
  final EventChannel _channel;
  final MethodChannel _methodChannel;
  Stream<SmsMessage> _stream;

  factory SmsReceiver() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel(
          "plugins.babariviere.io/receiveSMS", const JSONMethodCodec());
      final MethodChannel methodChannel = const MethodChannel(
        "plugins.babariviere.io/receiveSMSmeth", const JSONMethodCodec()
      );
      _instance = new SmsReceiver._private(eventChannel, methodChannel);
    }
    return _instance;
  }

  SmsReceiver._private(this._channel, this._methodChannel);

  /// Legacy function for received SMS
  @deprecated
  Stream<SmsMessage> get onSmsReceived {
    return this.stream;
  }

  /// Get stream that return all received SMS
  Stream<SmsMessage> get stream {
    if (this._stream == null) {
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

  /// Get needed permissions
  Future<List<String>> permissions() {
    return _methodChannel.invokeMethod("permissions", null);
  }
}

/// A SMS sender
///
/// Usage:
///
/// ```dart
/// var sender = SmsSender();
/// sender.send(SmsMessage("0xxxxxxxxx", "Hello, World"));
/// ```
class SmsSender {
  static SmsSender _instance;
  final MethodChannel _sendChannel;
  final EventChannel _statusChannel;
  Map<int, SmsMessage> _sentMessages;
  int _lastSentId = 0;
  final StreamController<SmsMessage> _deliveredStreamController =
      new StreamController<SmsMessage>();

  factory SmsSender() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/sendSMS", const JSONMethodCodec());
      final EventChannel statusChannel = const EventChannel(
          "plugins.babariviere.com/statusSMS", const JSONMethodCodec());

      _instance = new SmsSender._private(methodChannel, statusChannel);
    }
    return _instance;
  }

  SmsSender._private(this._sendChannel, this._statusChannel) {
    //_statusChannel.receiveBroadcastStream().listen(this._onSmsStateChanged);
    _sentMessages = new Map<int, SmsMessage>();
  }

  /// Legacy code for sending an SMS
  @deprecated
  Future<SmsMessage> sendSms(SmsMessage msg) async {
    return this.send(msg);
  }

  /// Send an SMS.
  ///
  /// Address and body are in msg variable
  Future<SmsMessage> send(SmsMessage msg) async {
    if (msg == null || msg.address == null || msg.body == null) {
      if (msg == null) {
        throw ("no given message");
      } else if (msg.address == null) {
        throw ("no given address");
      } else if (msg.body == null) {
        throw ("no given body");
      }
      return null;
    }

    msg.state = SmsMessageState.Sending;
    Map map = msg.toMap;
    this._sentMessages.putIfAbsent(this._lastSentId, () => msg);
    map['sentId'] = this._lastSentId;
    this._lastSentId += 1;
    msg.date = new DateTime.now();
    return _sendChannel.invokeMethod("send", map).then((_) => msg);
  }

  /// Legacy code
  @deprecated
  Stream<SmsMessage> get onSmsDelivered => this.stream;

  /// Return a stream for each delivered messages
  Stream<SmsMessage> get stream => _deliveredStreamController.stream;

  /// Listen for delivered messages
  StreamSubscription<SmsMessage> listen(void onData(SmsMessage msg)) {
    return this.stream.listen(onData);
  }

  void _onSmsStateChanged(dynamic stateChange) {
    int id = stateChange['sentId'];
    if (_sentMessages.containsKey(id)) {
      switch (stateChange['state']) {
        case 'sent':
          {
            _sentMessages[id].state = SmsMessageState.Sent;
            break;
          }
        case 'delivered':
          {
            _sentMessages[id].state = SmsMessageState.Delivered;
            _deliveredStreamController.add(_sentMessages[id]);
            _sentMessages.remove(id);
            break;
          }
      }
    }
  }

  /// Get needed permissions
  Future<List<String>> permissions() {
    return _sendChannel.invokeMethod("permissions", null);
  }
}
