import 'package:deputy/State/AppState.dart';

import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';

class WaitingPage extends StatefulWidget {
  WaitingPage({Key key}) : super(key: key);

  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  final _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        toolbarHeight: AppState().getScaledSize(56),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Row(children: [
          Expanded(
            child: Container(),
          ),
          Text(''),
          Expanded(
            child: Container(),
          ),
          TextButton(
            onPressed: () {
              if (WebSocketConnection.onHide != null) {
                WebSocketConnection.onHide();
              }
            },
            child: Tooltip(
              message: 'Свернуть',
              child: Icon(
                Icons.minimize,
                size: AppState().getScaledSize(24),
              ),
            ),
          ),
          Container(
            width: AppState().getScaledSize(15),
          ),
        ]),
        centerTitle: true,
      ),
      body: Row(children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Идут регламентные работы',
              style: TextStyle(
                fontSize: AppState().getScaledSize(32),
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(-1.0, -1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(125, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
      backgroundColor: Colors.blue[100],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
