import 'package:flutter/material.dart';

class InsertCardPage extends StatefulWidget {
  InsertCardPage({Key key}) : super(key: key);

  @override
  _InsertCardPageState createState() => _InsertCardPageState();
}

class _InsertCardPageState extends State<InsertCardPage> {
  final _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            header(),
            body(),
            footer(),
          ],
        ),
      ),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget header() {
    return Container();
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 500,
          child: Transform.scale(
            scale: 1,
            child: Image(image: AssetImage('assets/images/emblem.png')),
          ),
        ),
        Container(
          height: 20,
        ),
        Text(
          "Вставьте карту",
          style: TextStyle(
              fontSize: 42.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget footer() {
    return Container();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
