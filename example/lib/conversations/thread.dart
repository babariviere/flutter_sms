import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/conversation.dart';
import 'package:sms_example/conversations/avatar.dart';
import 'package:sms_example/conversations/badge.dart';

class Thread extends StatelessWidget {

  final SmsThread thread;

  Thread(this.thread): super(key: new ObjectKey(thread));

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Avatar(thread.contact),
      title: new Text(thread.contact.fullName != null ? thread.contact.fullName : thread.contact.address),
      subtitle: new Text(
          thread.messages.first.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
      ),
      trailing: new Badge(thread.messages),
      onTap: () => _showConversation(context),
    );
  }

  void _showConversation(BuildContext context) {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) => new Conversation(thread)
        )
    );
  }
}