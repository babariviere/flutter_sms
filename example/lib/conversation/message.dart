import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/sms.dart';
import './conversationStore.dart';
import '../conversations/avatar.dart';

class Message extends StatelessWidget {
  Message(SmsMessage message)
      : message = message,
        super(key: new ObjectKey(message));

  final SmsMessage message;

  bool get sent =>
      message.kind == SmsMessageKind.Sent ||
      message.state == SmsMessageState.Sent ||
      message.state == SmsMessageState.Sending ||
      message.state == SmsMessageState.Delivered;

  @override
  Widget build(BuildContext context) {
    return this.sent
        ? _buildSentWidget(context)
        : _buildReceivedWidget(context);
  }

  Widget _buildSentWidget(BuildContext context) {
    final userProfile = ConversationStore.of(context).userProfile;
    return new Container(
      child: new Stack(
        children: [
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Text(message.body.trim()),
                      new Align(
                        child: new Padding(
                          padding: new EdgeInsets.only(top: 5.0),
                          child: new Text(
                            _time.format(context),
                            style: new TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      )
                    ],
                  ),
                  margin: new EdgeInsets.only(left: 50.0),
                  padding: new EdgeInsets.all(10.0),
                  decoration: new BoxDecoration(color: Colors.lightBlue[100]),
                ),
              ),
              new Container(
                child: new Avatar(userProfile.thumbnail, userProfile.fullName),
                margin: new EdgeInsets.only(left: 10.0),
              ),
            ],
          ),
          new Container(
            width: double.infinity,
            child: new CustomPaint(
              painter: new ArrowPainter(
                  color: Colors.lightBlue[100], direction: ArrowDirection.Right),
            ),
          ),
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
    );
  }

  Widget _buildReceivedWidget(BuildContext context) {
    final thread = ConversationStore.of(context).thread;
    return new Container(
      child: new Stack(
        children: [
          new Row(
            children: <Widget>[
              new Container(
                child: new Avatar(
                    thread.contact.thumbnail, thread.contact.fullName),
                margin: new EdgeInsets.only(right: 10.0),
              ),
              new Expanded(
                child: new Container(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Text(message.body.trim()),
                      new Align(
                        child: new Padding(
                          padding: new EdgeInsets.only(top: 5.0),
                          child: new Text(
                            _time.format(context),
                            style: new TextStyle(color: Colors.grey),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  margin: new EdgeInsets.only(right: 50.0),
                  padding: new EdgeInsets.all(10.0),
                  decoration: new BoxDecoration(color: Colors.grey[300]),
                ),
              ),
            ],
          ),
          new CustomPaint(
            painter: new ArrowPainter(
                color: Colors.grey[300], direction: ArrowDirection.Left),
          )
        ],
      ),
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
    );
  }

  get _time {
    return new TimeOfDay(hour: message.date.hour, minute: message.date.minute);
  }
}

enum ArrowDirection { Left, Right }

class ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;
  final _paint = new Paint();

  ArrowPainter({this.color, this.direction}) {
    _paint.color = this.color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    Path path = new Path();

    if (this.direction == ArrowDirection.Left) {
      canvas.translate(50.0, 0.0);
      path.lineTo(-20.0, 0.0);
    } else {
      canvas.translate(size.width - 50.0, 0.0);
      path.lineTo(20.0, 0.0);
    }

    path.lineTo(0.0, 20.0);
    path.lineTo(0.0, 0.0);
    canvas.drawPath(path, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
