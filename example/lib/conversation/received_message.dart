import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

import 'arrow_painter.dart';
import 'message.dart';

class ReceivedMessage extends Message {
  ReceivedMessage(SmsMessage message, bool compactMode, this.contact)
      : super(message,
            compactMode: compactMode,
            backgroundColor: Colors.grey[300],
            arrowDirection: ArrowDirection.Left);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Stack(
        children: [
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                child: createAvatar(contact.thumbnail, contact.fullName),
                margin: new EdgeInsets.only(right: 8.0, top: 8.0),
              ),
              new Expanded(
                child: new Container(
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(10.0),
                    color: this.backgroundColor
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      new Text(message.body.trim()),
                      new Align(
                        child: new Padding(
                          padding: new EdgeInsets.only(top: 5.0),
                          child: new Text(
                            time.format(context),
                            style: new TextStyle(color: Colors.grey),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  margin: new EdgeInsets.only(right: 48.0),
                  padding: new EdgeInsets.all(10.0),
                ),
              ),
            ],
          ),
          this.createArrow()
        ],
      ),
      margin: new EdgeInsets.only(
          top: compactMode ? 2.0 : 10.0, bottom: 0.0, left: 15.0, right: 15.0),
    );
  }
}
