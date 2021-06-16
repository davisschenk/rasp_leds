import 'package:flutter/material.dart';

class Solid extends StatefulWidget {
  Solid({Key? key}) : super(key: key);

  @override
  _SolidState createState() => _SolidState();
}

class _SolidState extends State<Solid> {
  final _state = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _state,
      child: Column(
        children: [],
      
      ),
    );
  }
}