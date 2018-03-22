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
    SmsQuery query = new SmsQuery();
    List<SmsMessage> msgs = await query.querySms(
        start: 0,
        count: 2,
        kinds: [SmsQueryKind.Sent]);
    for (var msg in msgs) {
      setState(() {
        smsList += msg.threadId.toString() +
            " => " +
            msg.address +
            ": " +
            msg.body +
            "\n";
        if (text.isEmpty) {
          lastMessage = msg;
          text = "sender: " +
              lastMessage.sender.toString() +
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
            lastMessage.sender.toString() +
            "\nbody: " +
            lastMessage.body;
      });
    });
    _smsSubscription
        .onDone(() => setState(() => text = "Stream in now closed"));
    readSms();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Card(
                child: new Container(
              child: new Text(text),
              padding: new EdgeInsets.all(10.0),
            )),
            new Card(
                child: new Container(
              child: new Column(
                children: <Widget>[
                  new TextField(
                    controller: _controller,
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        labelStyle: new TextStyle(fontSize: 16.0),
                        labelText: "Reply with:"),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      var text = _controller.text;
                      _controller.clear();
                      SmsMessage msg = new SmsMessage(lastMessage.sender, text);
                      sender.sendSms(msg).catchError((Object e) => print(e.toString()));
                    },
                    child: new Text("REPLY"),
                  )
                ],
              ),
              padding: new EdgeInsets.all(10.0),
            )),
            new Card(
              child: new Container(
                child: new Text(smsList),
                padding: new EdgeInsets.all(10.0),
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
