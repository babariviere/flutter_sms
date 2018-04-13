import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms_example/utils/colors.dart';

class Avatar extends StatefulWidget {
  Avatar(Photo photo, String alternativeText)
      : photo = photo,
        alternativeText = alternativeText,
        super(key: new Key(alternativeText));

  final Photo photo;
  final String alternativeText;

  @override
  State<Avatar> createState() => new _AvatarState();
}

class _AvatarState extends State<Avatar> {
  Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    if (widget.photo != null) {
      widget.photo.readBytes().then((bytes) {
        setState(() {
          _bytes = bytes;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return new CircleAvatar(
        backgroundImage: new MemoryImage(_bytes),
      );
    }

    return new CircleAvatar(
      backgroundColor: ContactColor.getColor(widget.alternativeText),
      child: new Text(
          widget.alternativeText != null ? widget.alternativeText[0] : 'C'),
    );
  }
}
