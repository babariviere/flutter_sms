import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import 'package:sms_example/conversation/arrow_painter.dart';
import 'package:sms_example/conversations/avatar.dart';

abstract class Message extends StatelessWidget {
  Message(this.message,
      {this.compactMode = false, this.backgroundColor, this.arrowDirection})
      : super();

  final SmsMessage message;
  final bool compactMode;
  final Color backgroundColor;
  final ArrowDirection arrowDirection;

  bool get sent =>
      message.kind == SmsMessageKind.Sent ||
      message.state == SmsMessageState.Sent ||
      message.state == SmsMessageState.Sending ||
      message.state == SmsMessageState.Delivered;

  get time {
    return new TimeOfDay(hour: message.date.hour, minute: message.date.minute);
  }

  createAvatar(Photo thumbnail, String alternativeText) {
    if (compactMode) {
      return new Container(width: 40.0);
    }

    return new Avatar(thumbnail, alternativeText);
  }

  createArrow() {
    if (compactMode) {
      return new Container();
    }

    return new CustomPaint(
      painter: new ArrowPainter(
          color: this.backgroundColor, direction: this.arrowDirection),
    );
  }
}
