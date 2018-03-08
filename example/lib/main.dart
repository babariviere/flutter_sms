import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SmsReceiver receiver = new SmsReceiver();
  String lastMessage = "No new message";
  StreamSubscription<SmsMessage> _smsSubscription;

  @override
  void initState() {
    super.initState();
    _smsSubscription = receiver.onSmsReceived.listen((SmsMessage msg) {
      print("Receive new msg");
      setState(() =>
      lastMessage = "sender: " + msg.sender + "\nbody: " + msg.body);
    }, onError: (Object err) {
      print("ERROR");
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('$lastMessage\n'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_smsSubscription != null) {
      _smsSubscription.cancel();
    }
  }
}
