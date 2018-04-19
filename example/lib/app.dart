import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import './conversations/threads.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter SMS',
      home: new Threads(),
    );
  }
}
