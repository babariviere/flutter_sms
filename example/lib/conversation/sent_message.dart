import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import 'arrow_painter.dart';
import 'message.dart';

class SentMessage extends Message {
  SentMessage(SmsMessage message, bool compactMode, this.userProfile)
      : super(message,
            compactMode: compactMode,
            backgroundColor: Colors.lightBlue[100],
            arrowDirection: ArrowDirection.Right);

  final UserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Stack(
        children: [
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            time.format(context),
                            style: new TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                  margin: new EdgeInsets.only(left: 48.0),
                  padding: new EdgeInsets.all(10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(10.0),
                    color: this.backgroundColor
                  ),
                ),
              ),
              new Container(
                child:
                    createAvatar(userProfile.thumbnail, userProfile.fullName),
                margin: new EdgeInsets.only(left: 8.0, top: 8.0),
              ),
            ],
          ),
          new Container(
            width: double.infinity,
            child: createArrow(),
          ),
        ],
      ),
      margin: new EdgeInsets.only(
          top: compactMode ? 2.0 : 10.0, bottom: 0.0, left: 15.0, right: 15.0),
    );
  }
}
