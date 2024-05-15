import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:deputy/State/AppState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../State/WebSocketConnection.dart';
import '../Utils/stream_utils.dart';
import '../Utils/utils.dart';
import '../Widgets/voting_utils.dart';

class ViewStreamPage extends StatefulWidget {
  ViewStreamPage({Key key}) : super(key: key);

  @override
  _ViewStreamPageState createState() => _ViewStreamPageState();
}

class _ViewStreamPageState extends State<ViewStreamPage> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await windowManager.setFullScreen(false);
      await StreamUtils().closeBrowser().then((value) {
        Timer(Duration(milliseconds: 100), StreamUtils().startStream);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Color.fromARGB(255, 169, 172, 175),
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Expanded(
          child: bottomPanel(),
        ),
      ],
    );
  }

  Widget bottomPanel() {
    final connection = Provider.of<WebSocketConnection>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
            child: getButtonsSection(),
          ),
        ],
      ),
    );
  }

  Widget getButtonsSection() {
    return StatefulBuilder(builder: (_context, _setState) {
      final connection =
          Provider.of<WebSocketConnection>(_context, listen: true);

      return Container(
        color: Colors.black12,
        child: Stack(children: <Widget>[
          Row(
            children: [
              Container(
                width: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: GestureDetector(
                  onTapDown: (TapDownDetails d) async {
                    await StreamUtils().closeBrowser().then((value) {
                      Timer(Duration(milliseconds: 100),
                          StreamUtils().startStream);
                    });
                  },
                  child: TextButton(
                    onPressed: () async {
                      await StreamUtils().closeBrowser().then((value) {
                        Timer(Duration(milliseconds: 100),
                            StreamUtils().startStream);
                      });
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(150, 50)),
                        padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                        ),
                        Icon(Icons.refresh),
                        Container(
                          width: 10,
                        ),
                        Text(
                          'Обновить',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              AppState().getServerState().streamControl == 'user' &&
                      AppState().getCurrentMeeting() != null &&
                      !AppState().isCurrentUserManager()
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: GestureDetector(
                        onTapDown: (TapDownDetails d) {
                          backToAgenda(connection);
                        },
                        child: TextButton(
                          onPressed: () {
                            backToAgenda(connection);
                          },
                          style: ButtonStyle(
                              fixedSize:
                                  MaterialStateProperty.all(Size(190, 50)),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(0))),
                          child: Text(
                            'Назад к повестке',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              Utils().getIsAskWordButtonDisabled()
                  ? Container()
                  : VotingUtils().getAskWordButton(
                      _context,
                      setState,
                      AutoSizeGroup(),
                      50,
                      300,
                      true,
                    ),
              Container(
                width: 20,
              ),
            ],
          ),
        ]),
      );
    });
  }

  void backToAgenda(WebSocketConnection connection) {
    AppState().setExitStream(true);
    connection.processNavigation();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
