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
  SmsSender sender = new SmsSender();
  TextEditingController _controller;
  SmsMessage lastMessage = new SmsMessage(null, "No new messages");
  String text = "";
  String smsList = "Readed SMS at start:\n";
  StreamSubscription<SmsMessage> _smsSubscription;

  void readSms() async {
    SmsQuery query = SmsQuery();
    List<SmsMessage> msgs = await query.querySms(
        start: 0, count: 2, kind: SmsQueryKind.Sent, onError: (Object e) => print(e.toString()) );
    for (var msg in msgs) {
      setState(() {
        smsList +=
            msg.threadId.toString() + " => " + msg.address + ": " + msg.body +
                "\n";
        if (text.isEmpty) {
          lastMessage = msg;
          text = "sender: " +
              (lastMessage.sender == null ? "null" : lastMessage
                  .sender) +
              "\nbody: " +
              lastMessage.body;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController();
    text = "";
    _smsSubscription = receiver.onSmsReceived.listen((SmsMessage msg) {
      print("Receive new msg");
      setState(() {
        lastMessage = msg;
        text = "sender: " +
            (lastMessage.sender == null ? "null" : lastMessage
                .sender) +
            "\nbody: " +
            lastMessage.body;
      });
    }, onError: (Object err) {
      print(err);
      setState(() => text = err.toString());
    });
    _smsSubscription.onDone(() =>
        setState(() => text = "Stream in now closed"));
    readSms();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                child: Container(
                  child: new Text(text),
                  padding: EdgeInsets.all(10.0),
                )
            ),
            Card(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelStyle: TextStyle(fontSize: 16.0),
                            labelText: "Reply with:"
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          var text = _controller.text;
                          _controller.clear();
                          SmsMessage msg = SmsMessage(lastMessage.sender, text);
                          sender.sendSms(msg, onError: (Object e) => print(e));
                        },
                        child: Text("REPLY"),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                )
            ),
            Card(
              child: Container(
                child: Text(smsList),
                padding: EdgeInsets.all(10.0),
              ),
            )
          ],
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
