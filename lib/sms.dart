/// An SMS library for flutter
library sms;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sms/contact.dart';

typedef OnError(Object error);

enum SmsMessageState {
  Sending,
  Sent,
  Delivered,
  Fail,
  None,
}

enum SmsMessageKind {
  Sent,
  Received,
  Draft,
}

/// A SMS Message
///
/// Used to send message or used to read message.
class SmsMessage implements Comparable<SmsMessage> {
  int _id;
  int _threadId;
  String _address;
  String _body;
  bool _read;
  DateTime _date;
  DateTime _dateSent;
  SmsMessageKind _kind;
  SmsMessageState _state = SmsMessageState.None;
  StreamController<SmsMessageState> _stateStreamController =
      new StreamController<SmsMessageState>();

  SmsMessage(this._address, this._body,
      {int id,
      int threadId,
      bool read,
      DateTime date,
      DateTime dateSent,
      SmsMessageKind kind}) {
    this._id = id;
    this._threadId = threadId;
    this._read = read;
    this._date = date;
    this._dateSent = dateSent;
    this._kind = kind;
  }

  /// Read message from JSON
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
    if (data.containsKey("_id")) {
      this._id = data["_id"];
    }
    if (data.containsKey("thread_id")) {
      this._threadId = data["thread_id"];
    }
    if (data.containsKey("read")) {
      this._read = data["read"] as int == 1;
    }
    if (data.containsKey("kind")) {
      this._kind = data["kind"];
    }
    if (data.containsKey("date")) {
      this._date = new DateTime.fromMillisecondsSinceEpoch(data["date"]);
    }
    if (data.containsKey("date_sent")) {
      this._dateSent =
          new DateTime.fromMillisecondsSinceEpoch(data["date_sent"]);
    }
  }

  /// Convert SMS to map
  Map get toMap {
    Map res = {};
    if (_address != null) {
      res["address"] = _address;
    }
    if (_body != null) {
      res["body"] = _body;
    }
    if (_id != null) {
      res["_id"] = _id;
    }
    if (_threadId != null) {
      res["thread_id"] = _threadId;
    }
    if (_read != null) {
      res["read"] = _read;
    }
    if (_date != null) {
      res["date"] = _date.millisecondsSinceEpoch;
    }
    if (_dateSent != null) {
      res["dateSent"] = _dateSent.millisecondsSinceEpoch;
    }
    return res;
  }

  /// Get message id
  int get id => this._id;

  /// Get thread id
  int get threadId => this._threadId;

  /// Get sender, alias phone number
  String get sender => this._address;

  /// Get address, alias phone number
  String get address => this._address;

  /// Get message body
  String get body => this._body;

  /// Check if message is read
  bool get isRead => this._read;

  /// Get date
  DateTime get date => this._date;

  /// Get date sent
  DateTime get dateSent => this._dateSent;

  /// Get message kind
  SmsMessageKind get kind => this._kind;

  Stream<SmsMessageState> get onStateChanged => _stateStreamController.stream;

  /// Set message kind
  set kind(SmsMessageKind kind) => this._kind = kind;

  /// Set message date
  set date(DateTime date) => this._date = date;

  /// Get message state
  get state => this._state;

  set state(SmsMessageState state) {
    if (this._state != state) {
      this._state = state;
      _stateStreamController.add(state);
    }
  }

  @override
  int compareTo(SmsMessage other) {
    return other._id - this._id;
  }
}

/// A SMS thread
class SmsThread {
  int _id;
  String _address;
  Contact _contact;
  List<SmsMessage> _messages = [];

  SmsThread(int id) : this._id = id;

  /// Create a thread from a list of message, the id will be taken from
  /// the first message
  SmsThread.fromMessages(List<SmsMessage> messages) {
    if (messages == null || messages.length == 0) {
      return;
    }
    this._id = messages[0].threadId;

    for (var msg in messages) {
      if (msg.threadId == _id && msg.address != null) {
        this._address = msg.address;
        break;
      }
    }

    for (var msg in messages) {
      if (msg.threadId == _id) {
        this._messages.add(msg);
      }
    }
  }

  /// Add a message at the end
  void addMessage(SmsMessage msg) {
    if (msg.threadId == _id) {
      _messages.add(msg);
      if (this._address == null) {
        this._address = msg.address;
      }
    }
  }

  /// Add a message at the start
  void addNewMessage(SmsMessage msg) {
    if (msg.threadId == _id) {
      _messages.insert(0, msg);
      if (this._address == null) {
        this._address = msg.address;
      }
    }
  }

  /// Set contact through contact query
  Future findContact() async {
    ContactQuery query = new ContactQuery();
    Contact contact = await query.queryContact(this._address);
    if (contact != null) {
      this._contact = contact;
    }
  }

  /// Get messages from thread
  List<SmsMessage> get messages => this._messages;

  /// Get address
  String get address => this._address;

  /// Set messages in thread
  set messages(List<SmsMessage> messages) => this._messages = messages;

  /// Get thread id
  int get id => this._id;

  /// Get thread id (for compatibility)
  int get threadId => this._id;

  /// Get contact info
  Contact get contact => this._contact;

  /// Set contact info
  set contact(Contact contact) => this._contact = contact;
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
      _onSmsReceived = _channel.receiveBroadcastStream().map((dynamic event) {
        SmsMessage msg = new SmsMessage.fromJson(event);
        msg.kind = SmsMessageKind.Received;
        return msg;
      });
    }
    return _onSmsReceived;
  }
}

/// A SMS sender
class SmsSender {
  static SmsSender _instance;
  final MethodChannel _channel;
  final EventChannel _stateChannel;
  Map<int, SmsMessage> _sentMessages;
  int _sentId = 0;
  final StreamController<SmsMessage> _deliveredStreamController =
      new StreamController<SmsMessage>();

  factory SmsSender() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/sendSMS", const JSONMethodCodec());
      final EventChannel stateChannel = const EventChannel(
          "plugins.babariviere.com/statusSMS", const JSONMethodCodec());

      _instance = new SmsSender._private(methodChannel, stateChannel);
    }
    return _instance;
  }

  SmsSender._private(this._channel, this._stateChannel) {
    _stateChannel.receiveBroadcastStream().listen(this._onSmsStateChanged);

    _sentMessages = new Map<int, SmsMessage>();
  }

  /// Send an SMS
  ///
  /// Take a message in argument + 2 functions that will be called on success or on error
  ///
  /// This function will not set automatically thread id, you have to do it
  Future<SmsMessage> sendSms(SmsMessage msg, {SimCard simCard}) async {
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
    this._sentMessages.putIfAbsent(this._sentId, () => msg);
    map['sentId'] = this._sentId;
    if (simCard != null) {
      map['subId'] = simCard.slot;
    }
    this._sentId += 1;

    if (simCard != null) {
      map['simCard'] = simCard.imei;
    }

    await _channel.invokeMethod("sendSMS", map);
    msg.date = new DateTime.now();

    return msg;
  }

  Stream<SmsMessage> get onSmsDelivered => _deliveredStreamController.stream;

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
        case 'fail':
          {
            _sentMessages[id].state = SmsMessageState.Fail;
            _sentMessages.remove(id);
            break;
          }
      }
    }
  }
}

enum SmsQueryKind { Inbox, Sent, Draft }

/// A SMS query
class SmsQuery {
  static SmsQuery _instance;
  final MethodChannel _channel;

  factory SmsQuery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/querySMS", const JSONMethodCodec());
      _instance = new SmsQuery._private(methodChannel);
    }
    return _instance;
  }

  SmsQuery._private(this._channel);

  /// Wrapper for query only one kind
  Future<List<SmsMessage>> _querySmsWrapper(
      {int start,
      int count,
      String address,
      int threadId,
      SmsQueryKind kind: SmsQueryKind.Inbox}) async {
    Map arguments = {};
    if (start != null && start >= 0) {
      arguments["start"] = start;
    }
    if (count != null && count > 0) {
      arguments["count"] = count;
    }
    if (address != null && address.isNotEmpty) {
      arguments["address"] = address;
    }
    if (threadId != null && threadId >= 0) {
      arguments["thread_id"] = threadId;
    }
    String function;
    SmsMessageKind msgKind;
    if (kind == SmsQueryKind.Inbox) {
      function = "getInbox";
      msgKind = SmsMessageKind.Received;
    } else if (kind == SmsQueryKind.Sent) {
      function = "getSent";
      msgKind = SmsMessageKind.Sent;
    } else {
      function = "getDraft";
      msgKind = SmsMessageKind.Draft;
    }
    return await _channel.invokeMethod(function, arguments).then((dynamic val) {
      List<SmsMessage> list = [];
      for (Map data in val) {
        SmsMessage msg = new SmsMessage.fromJson(data);
        msg.kind = msgKind;
        list.add(msg);
      }
      return list;
    });
  }

  /// Query a list of SMS
  Future<List<SmsMessage>> querySms(
      {int start,
      int count,
      String address,
      int threadId,
      List<SmsQueryKind> kinds: const [SmsQueryKind.Inbox],
      bool sort: true}) async {
    List<SmsMessage> result = [];
    for (var kind in kinds) {
      result
        ..addAll(await this._querySmsWrapper(
          start: start,
          count: count,
          address: address,
          threadId: threadId,
          kind: kind,
        ));
    }
    if (sort == true) {
      result.sort((a, b) => a.compareTo(b));
    }
    return (result);
  }

  /// Query multiple thread by id
  Future<List<SmsThread>> queryThreads(List<int> threadsId,
      {List<SmsQueryKind> kinds: const [SmsQueryKind.Inbox]}) async {
    List<SmsThread> threads = <SmsThread>[];
    for (var id in threadsId) {
      final messages = await this.querySms(threadId: id, kinds: kinds);
      final thread = new SmsThread.fromMessages(messages);
      await thread.findContact();
      threads.add(thread);
    }
    return threads;
  }

  /// Get all SMS
  Future<List<SmsMessage>> get getAllSms async {
    return this.querySms(
        kinds: [SmsQueryKind.Sent, SmsQueryKind.Inbox, SmsQueryKind.Draft]);
  }

  /// Get all threads
  Future<List<SmsThread>> get getAllThreads async {
    List<SmsMessage> messages = await this.getAllSms;
    Map<int, List<SmsMessage>> filtered = {};
    messages.forEach((msg) {
      if (!filtered.containsKey(msg.threadId)) {
        filtered[msg.threadId] = [];
      }
      filtered[msg.threadId].add(msg);
    });
    List<SmsThread> threads = <SmsThread>[];
    for (var k in filtered.keys) {
      final thread = new SmsThread.fromMessages(filtered[k]);
      await thread.findContact();
      threads.add(thread);
    }
    return threads;
  }
}

enum SimCardState {
  Unknown,
  Absent,
  PinRequired,
  PukRequired,
  Locked,
  Ready,
}

/// Represents a device's sim card info
class SimCard {
  int slot;
  String imei;
  SimCardState state;

  SimCard({
    @required this.slot,
    @required this.imei,
    this.state = SimCardState.Unknown
  }) : assert(slot != null),
       assert(imei != null);

  SimCard.fromJson(Map map) {
    if (map.containsKey('slot')) {
      this.slot = map['slot'];
    }
    if (map.containsKey('imei')) {
      this.imei = map['imei'];
    }
    if (map.containsKey('state')) {
      switch(map['state']) {
        case 0:
          this.state = SimCardState.Unknown;
          break;
        case 1:
          this.state = SimCardState.Absent;
          break;
        case 2:
          this.state = SimCardState.PinRequired;
          break;
        case 3:
          this.state = SimCardState.PukRequired;
          break;
        case 4:
          this.state = SimCardState.Locked;
          break;
        case 5:
          this.state = SimCardState.Ready;
          break;
      }
    }
  }
}

class SimCardsProvider {
  static SimCardsProvider _instance;
  final MethodChannel _channel;

  factory SimCardsProvider() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/simCards", const JSONMethodCodec());
      _instance = new SimCardsProvider._private(methodChannel);
    }
    return _instance;
  }

  SimCardsProvider._private(this._channel);

  Future<List<SimCard>> getSimCards() async {
    final simCards = new List<SimCard>();

    dynamic response = await _channel.invokeMethod('getSimCards', null);
    for(Map map in response) {
      simCards.add(new SimCard.fromJson(map));
    }

    return simCards;
  }
}
