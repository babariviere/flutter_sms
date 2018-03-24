import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/messages.dart';

class Conversation extends StatelessWidget {

  final SmsThread thread;

  Conversation(this.thread): super();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(thread.contact.fullName != null ? thread.contact.fullName : thread.contact.address),
      ),
      body: new Messages(thread.messages),
    );
  }

}