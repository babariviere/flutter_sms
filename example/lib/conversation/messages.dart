import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

import '../utils/group.dart';
import 'messageGroup.dart';

class Messages extends StatelessWidget {
  final List<SmsMessage> messages;

  Messages(this.messages);

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
