import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversations/thread.dart';

class Threads extends StatefulWidget {
  @override
  State<Threads> createState() => new _ThreadsState();
}

class _ThreadsState extends State<Threads> with TickerProviderStateMixin {
  bool _loading = true;
  List<SmsThread> _threads = <SmsThread>[];
  final SmsQuery _query = new SmsQuery();
  final SmsReceiver _receiver = new SmsReceiver();

  // Animation
  AnimationController opacityController;

  @override
  void initState() {
    super.initState();
    _query.getAllThreads.then(_onThreadsLoaded);
    _receiver.onSmsReceived.listen(_onSmsReceived);

    // Animation
    opacityController = new AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this, value: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('SMS Conversations'),
      ),
      body: _getThreadsWidgets(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget _getThreadsWidgets() {
    if (_loading) {
      return new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text('Loading conversations...'),
          ],
        ),
      );
    } else {
      return new FadeTransition(
        opacity: opacityController,
        child: new ListView.builder(
            itemCount: _threads.length,
            itemBuilder: (context, index) {
              return new Thread(_threads[index]);
            }),
      );
    }
  }

  void _onSmsReceived(SmsMessage sms) async {
    var thread = _threads.singleWhere((thread) {
      return thread.id == sms.threadId;
    }, orElse: () {
      var thread = new SmsThread(sms.threadId);
      _threads.insert(0, thread);
      return thread;
    });

    thread.addNewMessage(sms);
    await thread.findContact();

    int index = _threads.indexOf(thread);
    if (index != 0) {
      _threads.removeAt(index);
      _threads.insert(0, thread);
    }

    setState(() {});
  }

  void _onThreadsLoaded(List<SmsThread> threads) {
    setState(() {
      _threads = threads;
      _loading = false;
    });
    opacityController.animateTo(1.0, curve: Curves.easeIn);
  }
}
