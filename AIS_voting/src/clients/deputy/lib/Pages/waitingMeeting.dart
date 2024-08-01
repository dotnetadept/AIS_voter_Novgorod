import 'package:deputy/State/AppState.dart';
import 'package:flutter/material.dart';

class WaitingMeetingPage extends StatefulWidget {
  WaitingMeetingPage({Key? key}) : super(key: key);

  @override
  _WaitingMeetingPageState createState() => _WaitingMeetingPageState();
}

class _WaitingMeetingPageState extends State<WaitingMeetingPage> {
  final _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.black54,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: FittedBox(
                      child: Text(
                        AppState().getCurrentUser() == null
                            ? 'Гость'
                            : AppState().getCurrentUser().toString(),
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/images/emblem.png'),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue[100],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
