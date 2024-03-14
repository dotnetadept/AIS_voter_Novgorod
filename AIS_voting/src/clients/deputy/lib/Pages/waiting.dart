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
      body: Row(children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Идут регламентные работы',
              style: TextStyle(
                fontSize: 32,
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
