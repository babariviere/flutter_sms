import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter SMS',
      home: new Threads(),
    );
  }
}
