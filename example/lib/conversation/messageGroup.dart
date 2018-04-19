import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './message.dart';
import '../utils/group.dart';

class MessageGroup extends StatelessWidget {
  final Group group;

  MessageGroup(this.group) : super();

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[
      new Container(
        child: new Text(MaterialLocalizations
            .of(context)
            .formatFullDate(group.messages[0].date)),
        margin: new EdgeInsets.only(top: 10.0),
      ),
    ];
    widgets
        .addAll(group.messages.map((message) => new Message(message)).toList());

    return new Container(
      child: new Column(
        children: widgets,
      ),
    );
  }
}
