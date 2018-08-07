import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sms/sms.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    var receiver = SmsReceiver();
    receiver.listen((sms) {
      print("Address: " + sms.address + ", body: " + sms.body);
    });

    var sender = SmsSender();
    sender.send(SmsMessage("0782428978", "Hello World"));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Testing\n'),
        ),
      ),
    );
  }
}
