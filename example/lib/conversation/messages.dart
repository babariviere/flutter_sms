import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/messageGroup.dart';
import 'package:sms_example/utils/group.dart';

class Messages extends StatelessWidget {
  final List<SmsMessage> messages;

  Messages(this.messages, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groups = MessageGroupService.of(context).groupByDate(messages);

    return new ListView.builder(
        reverse: true,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return new MessageGroup(groups[index]);
        });
  }
}
