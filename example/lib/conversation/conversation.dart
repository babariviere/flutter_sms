import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/conversationStore.dart';
import 'package:sms_example/conversation/formSend.dart';
import 'package:sms_example/conversation/messages.dart';
import 'package:sms_example/utils/colors.dart';

class Conversation extends StatefulWidget {
  Conversation(this.thread, this.userProfile) : super();

  final SmsThread thread;
  final Contact userProfile;

  @override
  State<Conversation> createState() => new _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final SmsReceiver _receiver = new SmsReceiver();

  @override
  void initState() {
    super.initState();
    _receiver.onSmsReceived.listen((sms) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ConversationStore(
      thread: widget.thread,
      userProfile: widget.userProfile,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(
              widget.thread.contact.fullName ?? widget.thread.contact.address),
          backgroundColor: ContactColor.getColor(widget.thread.contact.address),
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new Messages(widget.thread.messages),
            ),
            new FormSend(
              widget.thread,
              onMessageSent: _onMessageSent,
            ),
          ],
        ),
      ),
    );
  }

  void _onMessageSent(SmsMessage message) {
    setState(() {
      widget.thread.addNewMessage(message);
    });
  }
}
