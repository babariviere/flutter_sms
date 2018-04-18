import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import './conversationStore.dart';
import '../conversations/avatar.dart';

class Message extends StatelessWidget {
  Message(SmsMessage message)
      : message = message,
        super(key: new ObjectKey(message));

  final SmsMessage message;

  bool get sent => message.kind == SmsMessageKind.Sent;

  @override
  Widget build(BuildContext context) {
    return sent ? _buildSentWidget(context) : _buildReceivedWidget(context);
  }

  Widget _buildSentWidget(BuildContext context) {
    final userProfile = ConversationStore.of(context).userProfile;
    return new Container(
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text(message.body.trim()),
                  new Align(
                    child: new Padding(
                      padding: new EdgeInsets.only(top: 5.0),
                      child: new Text(
                        _time.format(context),
                        style: new TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  )
                ],
              ),
              margin: new EdgeInsets.only(left: 50.0),
              padding: new EdgeInsets.all(10.0),
              decoration: new BoxDecoration(color: Colors.yellow[100]),
            ),
          ),
          new Container(
            child: new Avatar(userProfile.photo, userProfile.fullName),
            margin: new EdgeInsets.only(left: 10.0),
          ),
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
    );
  }

  Widget _buildReceivedWidget(BuildContext context) {
    final thread = ConversationStore.of(context).thread;
    return new Container(
      child: new Row(
        children: <Widget>[
          new Container(
            child: new Avatar(thread.contact.photo, thread.contact.fullName),
            margin: new EdgeInsets.only(right: 10.0),
          ),
          new Expanded(
            child: new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text(message.body.trim()),
                  new Align(
                    child: new Padding(
                      padding: new EdgeInsets.only(top: 5.0),
                      child: new Text(
                        _time.format(context),
                        style: new TextStyle(color: Colors.grey),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
              margin: new EdgeInsets.only(right: 50.0),
              padding: new EdgeInsets.all(10.0),
              decoration: new BoxDecoration(color: Colors.grey[300]),
            ),
          ),
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
    );
  }

  get _time {
    return new TimeOfDay(hour: message.date.hour, minute: message.date.minute);
  }
}
