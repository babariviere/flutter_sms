import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sms/contact.dart';
import 'package:sms_example/utils/colors.dart';

class Avatar extends StatefulWidget {
  Avatar(Contact contact)
      : contact = contact,
        super(key: new ObjectKey(contact));

  final Contact contact;

  @override
  State<Avatar> createState() => new _AvatarState();
}

class _AvatarState extends State<Avatar> {
  Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    if (widget.contact.photo != null) {
      widget.contact.photo.readBytes().then((bytes) {
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
      backgroundColor: ContactColor.getColor(widget.contact.address),
      child: new Text(
          widget.contact.fullName != null ? widget.contact.fullName[0] : 'C'),
    );
  }
}
