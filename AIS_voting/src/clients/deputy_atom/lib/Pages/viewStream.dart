import 'dart:async';
import 'dart:io';

import 'package:ais_model/ais_model.dart';
import 'package:deputy/State/AppState.dart';
import 'package:deputy/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

class ViewStreamPage extends StatefulWidget {
  ViewStreamPage({Key key}) : super(key: key);

  @override
  _ViewStreamPageState createState() => _ViewStreamPageState();
}

class _ViewStreamPageState extends State<ViewStreamPage> {
  @override
  void initState() {
    super.initState();

    setWindowBottomMode();

    Process.run('pkill', <String>['-f', 'chrome']).then((value) {
      Process.run('google-chrome', <String>[
        GlobalConfiguration().getValue('stream_file'),
        '--kiosk',
        '--autoplay-policy=no-user-gesture-required'
      ]);
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
    setWindowBottomMode();
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
      child: getStreamView(),
    );
  }

  Widget getStreamView() {
    return Column(
      children: [
        getButtonsSection(),
      ],
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
              Expanded(child: Container()),
              AppState().getServerState().streamControl == 'user'
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: GestureDetector(
                        onTapDown: (TapDownDetails d) async {
                          await backToAgenda(connection);
                        },
                        child: TextButton(
                          onPressed: () async {
                            await backToAgenda(connection);
                          },
                          style: ButtonStyle(
                              fixedSize:
                                  MaterialStateProperty.all(Size(160, 50))),
                          child: Text('Назад к повестке'),
                        ),
                      ),
                    )
                  : Container(),
              Container(width: 20),
              AppState().getServerState().streamControl == 'user'
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: GestureDetector(
                        onTapDown: (TapDownDetails d) {
                          backToQuestion(connection);
                        },
                        child: TextButton(
                          onPressed: () {
                            backToQuestion(connection);
                          },
                          style: ButtonStyle(
                              fixedSize:
                                  MaterialStateProperty.all(Size(160, 50))),
                          child: Text('Назад к вопросу'),
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
              (connection.getClientType() != 'deputy' ||
                      !AppState().getIsRegistred())
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppState().getAskWordStatus()
                                ? Colors.white
                                : Colors.transparent,
                            width: 5,
                          ),
                        ),
                        child: TextButton(
                          autofocus: true,
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(280, 50)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          onPressed: () {
                            onAskWord(connection);
                          },
                          child: Container(
                            color: AppState().getAskWordStatus()
                                ? Color(AppState()
                                    .getSettings()
                                    .palletteSettings
                                    .askWordColor)
                                : Colors.blue,
                            height: 50,
                            width: 280,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                AppState().getAskWordStatus()
                                    ? 'ОТКАЗАТЬСЯ ОТ ВЫСТУПЛЕНИЯ'
                                    : 'ПРОШУ СЛОВА',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        AppState().getAskWordStatus() ? 15 : 20,
                                    color: Color(AppState().getAskWordStatus()
                                        ? Colors.black87.value
                                        : AppState()
                                            .getSettings()
                                            .palletteSettings
                                            .buttonTextColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Future<void> backToAgenda(WebSocketConnection connection) async {
    await Process.run('pkill', <String>['-f', 'chrome']);

    Timer(Duration(milliseconds: 10), () {
      setWindowFullscreenMode();

      Timer(Duration(milliseconds: 10), () {
        if (AppState().canUserNavigate()) {
          AppState().setAgendaDocument(new QuestionFile());
          AppState().setCurrentDocument(null);
          AppState().setCurrentQuestion(null);

          connection.navigateToPage('/viewAgenda');
        }
      });
    });
  }

  void backToQuestion(WebSocketConnection connection) {
    Timer(Duration(milliseconds: 1), () {
      setWindowFullscreenMode();
    });
    Timer(Duration(milliseconds: 10), () {
      setWindowFullscreenMode();

      if (AppState().canUserNavigate()) {
        AppState().setAgendaDocument(null);
        AppState().setCurrentDocument(null);

        connection.navigateToPage('/viewAgenda');
      }
    });

    Process.run('pkill', <String>['-f', 'chrome']);
  }

  void onAskWord(WebSocketConnection connection) {
    if (AppState().getAskWordStatus()) {
      connection.sendMessage('ПРОШУ СЛОВА СБРОС');
    } else {
      connection.sendMessage('ПРОШУ СЛОВА');
    }
  }
}
