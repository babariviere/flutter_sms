import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/message.dart';


class Messages extends StatelessWidget {

  final List<SmsMessage> messages;

  Messages(this.messages): super();

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: messages.reversed.map((message) => new Message(message)).toList(),
    );
  }
}