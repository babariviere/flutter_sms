import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

typedef void MessageSentCallback(SmsMessage message);

class FormSend extends StatelessWidget {

  FormSend(this.thread, {this.onMessageSent});

  final SmsThread thread;
  final MessageSentCallback onMessageSent;
  final TextEditingController _textField = new TextEditingController();
  final SmsSender _sender = new SmsSender();

  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: 4.0,
      child: new Row(
        children: [
          new Expanded(
            child: new Container(
              child: new TextField(
                controller: _textField,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  labelStyle: new TextStyle(fontSize: 16.0),
                  hintText: "Send message:"
                ),
              ),
              padding: new EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
            ),
          ),
          new IconButton(
            icon: new Row(
              children: [
                new Icon(Icons.sim_card, color: Colors.grey,),
                new Text('1'),
              ],
            ),
            onPressed: (){}
          ),
          new IconButton(
            icon: new Icon(Icons.send),
            onPressed: () {
              _sendMessage(context);
            },
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) async {
    SmsMessage message = new SmsMessage(
        thread.address,
        _textField.text,
        threadId: thread.id
    );
    message.onStateChanged.listen((SmsMessageState state) {
      if (state == SmsMessageState.Delivered) {
        print('Message delivered to ${message.address}');
        _notifyMsgDelivery(message, context);
      }
      if (state == SmsMessageState.Sent) {
        print('Message sent to ${message.address}');
      }
    });

    await _sender.sendSms(message);
    _textField.clear();
    onMessageSent(message);
  }

  void _notifyMsgDelivery(SmsMessage message, BuildContext context) async {
    final contacts = new ContactQuery();
    Contact contact = await contacts.queryContact(message.address);
    final snackBar = new SnackBar(
      content: new Text('Message to ${contact.fullName} delivered')
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
