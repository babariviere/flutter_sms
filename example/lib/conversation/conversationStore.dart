import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

class ConversationStore extends InheritedWidget {
  const ConversationStore(
      {Key key,
      @required this.thread,
      @required this.userProfile,
      @required Widget child})
      : super(key: key, child: child);

  final SmsThread thread;
  final UserProfile userProfile;

  static ConversationStore of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ConversationStore);
  }

  @override
  bool updateShouldNotify(ConversationStore old) =>
      thread != old.thread || userProfile != old.userProfile;
}
