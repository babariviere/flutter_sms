import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversations/thread.dart';

class Threads extends StatefulWidget {
  @override
  State<Threads> createState() => new _ThreadsState();
}

class _ThreadsState extends State<Threads> {

  bool _loading = true;
  List<SmsThread> _threads = <SmsThread>[];
  final SmsQuery _query = new SmsQuery();
  final SmsReceiver _receiver = new SmsReceiver();

  @override
  void initState() {
    super.initState();
    _query.getAllThreads.then(_onThreadsLoaded);
    _receiver.onSmsReceived.listen(_onSmsReceived);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('SMS Conversations'),
      ),
      body: new Column(
        children: _getThreadsWidgets(),
      ),
    );
  }

  List<Widget> _getThreadsWidgets() {
    final widgets = <Widget>[];

    if (_loading) {
      widgets.add(new LinearProgressIndicator());
    }

    widgets.add(
        new Expanded(
            child: new ListView(
              children: _threads.map((thread) => new Thread(thread)).toList(),
            ),
        ),
    );

    return widgets;
  }

  void _onSmsReceived(SmsMessage sms) {
    setState((){
      var thread = _threads.singleWhere((thread)=>thread.id == sms.threadId);
      if (thread == null) {
        thread = new SmsThread(sms.id);
      }
      thread.addNewMessage(sms);
    });
  }

  void _onThreadsLoaded(List<SmsThread> threads) {
    setState((){
      _threads = threads;
      _loading = false;
    });
  }
}
