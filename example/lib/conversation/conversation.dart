import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

import '../utils/colors.dart';
import 'conversationStore.dart';
import 'formSend.dart';
import 'messages.dart';

class Conversation extends StatefulWidget {
  Conversation(this.thread, this.userProfile) : super();

  final SmsThread thread;
  final UserProfile userProfile;

  @override
  State<Conversation> createState() => new _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final SmsReceiver _receiver = new SmsReceiver();

  @override
  void initState() {
    _receiver.onSmsReceived.listen((sms) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building conversation');
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.thread.contact.fullName ?? widget.thread.contact.address),
        backgroundColor: ContactColor.getColor(widget.thread.contact.fullName),
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new ConversationStore(
              widget.userProfile,
              widget.thread,
              child: new Messages(widget.thread.messages),
            ),
          ),
          new FormSend(
            widget.thread,
            onMessageSent: _onMessageSent,
          ),
        ],
      ),
    );
  }

  void _onMessageSent(SmsMessage message) {
    setState(() {
      widget.thread.addNewMessage(message);
    });
  }
}
