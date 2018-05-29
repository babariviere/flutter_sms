import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

import 'thread.dart';

class Threads extends StatefulWidget {
  @override
  State<Threads> createState() => new _ThreadsState();
}

class _ThreadsState extends State<Threads> with TickerProviderStateMixin {
  bool _loading = true;
  List<SmsThread> _threads;
  UserProfile _userProfile;
  final SmsQuery _query = new SmsQuery();
  final SmsReceiver _receiver = new SmsReceiver();
  final UserProfileProvider _userProfileProvider = new UserProfileProvider();
  final SmsSender _smsSender = new SmsSender();

  // Animation
  AnimationController opacityController;

  @override
  void initState() {
    super.initState();
    _receiver.onSmsReceived.listen(_onSmsReceived);
    _userProfileProvider.getUserProfile().then(_onUserProfileLoaded);
    _query.getAllThreads.then(_onThreadsLoaded);
    _smsSender.onSmsDelivered.listen(_onSmsDelivered);

    // Animation
    opacityController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this, value: 0.0);
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
        child: new CircularProgressIndicator(),
      );
    } else {
      return new FadeTransition(
        opacity: opacityController,
        child: new ListView.builder(
            itemCount: _threads.length,
            itemBuilder: (context, index) {
              return new Thread(_threads[index], _userProfile);
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
    _threads = threads;
    _checkIfLoadCompleted();
  }

  void _onUserProfileLoaded(UserProfile userProfile) {
    _userProfile = userProfile;
    _checkIfLoadCompleted();
  }

  void _checkIfLoadCompleted() {
    if (_threads != null && _userProfile != null) {
      setState(() {
        _loading = false;
        opacityController.animateTo(1.0, curve: Curves.easeIn);
      });
    }
  }

  void _onSmsDelivered(SmsMessage sms) async {
    final contacts = new ContactQuery();
    Contact contact = await contacts.queryContact(sms.address);
    final snackBar = new SnackBar(
        content: new Text('Message to ${contact.fullName} delivered'));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
