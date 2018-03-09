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
        kinds: [SmsQueryKind.Sent],
        onError: (Object e) => print(e.toString()));
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
//    query.getAllSms.then((List<SmsMessage> msgs) {
//      int count = 0;
//      msgs.forEach((msg) {
//          print(msg.id.toString() + ": " + msg.kind.toString() + " => " +
//              msg.body + "\n");
//        count++;
//      });
//      print("Total: " + count.toString());
//    });
//    query.queryThreads([47]).then((Map val) {
//      val.forEach((dynamic k, dynamic v) {
//        int key = k as int;
//        SmsThread val = v as SmsThread;
//        print(key.toString() + ":\n");
//        for (var msg in val.messages) {
//          print(msg.body);
//        }
//      });
//    });
//    query.getAllThreads.then((Map val) {
//      val.keys.forEach((dynamic k) {
//        print(k.toString());
//      });
//    });
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
    }, onError: (Object err) {
      print(err);
      setState(() => text = err.toString());
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
                      sender.sendSms(msg, onError: (Object e) => print(e));
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
