import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:sms/sms.dart';


class ThreadStore extends InheritedWidget {
  const ThreadStore({
    Key key,
    @required this.thread,
    @required Widget child
  }): super(key: key, child: child);

  final SmsThread thread;

  static ThreadStore of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ThreadStore);
  }

  @override
  bool updateShouldNotify(ThreadStore old) => thread != old.thread;

}