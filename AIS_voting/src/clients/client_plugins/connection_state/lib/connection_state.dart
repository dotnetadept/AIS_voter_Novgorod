library connection_state;

import 'dart:ui';
import 'package:flutter/material.dart';

class ConnectionStateWidget extends StatefulWidget {
  ConnectionStateWidget({Key key, this.isOnline, this.forecolor = Colors.black})
      : super(key: key);

  final bool isOnline;
  final Color forecolor;

  @override
  _ConnectionStateWidgetState createState() => _ConnectionStateWidgetState();
}

class _ConnectionStateWidgetState extends State<ConnectionStateWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.isOnline ? online() : offline();
  }

  Widget online() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            Icons.circle,
            color: Colors.green,
            size: 24.0,
          ),
        ),
        Text(
          'Онлайн',
          style: TextStyle(color: widget.forecolor),
        ),
      ],
    );
  }

  Widget offline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            Icons.circle,
            color: Colors.red,
            size: 24.0,
          ),
        ),
        Text(
          'Оффлайн',
          style: TextStyle(color: widget.forecolor),
        ),
      ],
    );
  }
}
