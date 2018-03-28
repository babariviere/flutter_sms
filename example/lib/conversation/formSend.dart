import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

typedef void MessageSentCallback(SmsMessage message);

class FormSend extends StatelessWidget {

  final SmsThread thread;
  final TextEditingController _textFieldController = new TextEditingController();
  final SmsSender _sender = new SmsSender();

  final MessageSentCallback onMessageSent;

  FormSend(this.thread, {this.onMessageSent});

  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: 4.0,
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new TextField(
                controller: _textFieldController,
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
            icon: new Icon(Icons.send),
            onPressed: _sendMessage,
            color: Colors.blue,
          )
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = await _sender.sendSms(
        new SmsMessage(
            thread.address,
            _textFieldController.text,
            threadId: thread.id
        )
    );
    _textFieldController.clear();
    onMessageSent(message);
  }
}