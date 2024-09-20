import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:storeboard/Utils/stream_utils.dart';
import 'package:window_manager/window_manager.dart';

class ViewStreamPage extends StatefulWidget {
  ViewStreamPage({Key? key}) : super(key: key);

  @override
  _ViewStreamPageState createState() => _ViewStreamPageState();
}

class _ViewStreamPageState extends State<ViewStreamPage> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await windowManager.setFullScreen(false);
      await StreamUtils().closeBrowser().then((value) async {
        Timer(Duration(milliseconds: 100), StreamUtils().startStream);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.grey,
      child: Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
