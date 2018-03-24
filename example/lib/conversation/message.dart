import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/sms.dart';


class Message extends StatelessWidget {

  final SmsMessage message;

  Message(this.message) : super(key: new ObjectKey(message));

  bool get sent => message.kind == SmsMessageKind.Sent;

  @override
  Widget build(BuildContext context) {
    return sent ? _sentWidget : _receivedWidget;
  }

  Widget get _sentWidget {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Text(
                  message.body,
                  textAlign: TextAlign.left,
              ),
              margin: new EdgeInsets.only(left: 50.0),
              padding: new EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                  color: Colors.yellow[100]
              ),
            ),
          ),
          new Container(
            child: new CircleAvatar(
              child: new Text('C'),
            ),
            margin: new EdgeInsets.only(left: 10.0),
          ),
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
    );
  }

  Widget get _receivedWidget {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Container(
              child: new CircleAvatar(
                  child: new Text('C'),
              ),
              margin: new EdgeInsets.only(right: 10.0),
          ),
          new Expanded(
            child: new Container(
              child: new Text(
                  message.body,
                  textAlign: TextAlign.left,
              ),
              margin: new EdgeInsets.only(right: 50.0),
              padding: new EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                color: Colors.grey[300]
              ),
            ),
          )
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    );
  }
}