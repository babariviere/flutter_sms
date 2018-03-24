import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/sms.dart';


class Message extends StatelessWidget {

  final SmsMessage message;

  Message(this.message) : super();

  bool get sent => message.kind == SmsMessageKind.Sent;

  @override
  Widget build(BuildContext context) {
    return sent ? _sentWidget : _receivedWidget;
  }

  Widget get _sentWidget {
    return new Container(
      margin: new EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 3.0
      ),
      child: new Row(
        children: <Widget>[
          new Expanded(child: new Text('')),
          new Container(
            child: new Text(message.body),
            padding: new EdgeInsets.all(10.0),
            margin: new EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 3.0
            ),
            decoration: new BoxDecoration(
                color: Colors.red
            ),
          ),
          new CircleAvatar(
            child: new Text('C'),
          )
        ],
      ),
    );
  }

  Widget get _receivedWidget {
    return new Container(
      margin: new EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 3.0
      ),
      child: new Row(
        children: <Widget>[
          new CircleAvatar(
            child: new Text('C'),
          ),
          new Container(
            child: new Text(message.body),
            padding: new EdgeInsets.all(10.0),
            margin: new EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 3.0
            ),
            decoration: new BoxDecoration(
                color: Colors.pinkAccent
            ),
          ),
          new Expanded(child: new Text('')),
        ],
      ),
    );
  }
}