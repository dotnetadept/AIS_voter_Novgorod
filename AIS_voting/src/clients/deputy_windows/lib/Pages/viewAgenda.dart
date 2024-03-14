import 'dart:convert' show json;
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class ViewAgendaPage extends StatefulWidget {
  ViewAgendaPage({Key key}) : super(key: key);

  @override
  _ViewAgendaPageState createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        toolbarHeight: AppState().getScaledSize(56),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: Row(children: [
            Expanded(
              child: Text(
                AppState().getCurrentUser().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppState().getScaledSize(22)),
              ),
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
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    if (AppState().getCurrentMeeting() == null) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget rightPanel() {
    final connection = Provider.of<WebSocketConnection>(context, listen: false);
    double emblemHeight = MediaQuery.of(context).size.height -
        AppState().getSettings().storeboardSettings.height -
        AppState().getScaledSize(200);
    Provider.of<AppState>(context, listen: true);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.blue[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(AppState().getHalfScaledSize(10)),
                  height: emblemHeight > 0 ? emblemHeight : 0,
                  child: Container(
                    child: Image(image: AssetImage('assets/images/emblem.png')),
                  ),
                ),
                Expanded(child: Container()),
                connection.getClientType() != 'deputy' ||
                        !AppState().getIsRegistred()
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppState().getAskWordStatus()
                                  ? Colors.white
                                  : Colors.transparent,
                              width: AppState().getScaledSize(5),
                            ),
                          ),
                          child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(
                                  AppState().getScaledSize(350),
                                  AppState().getScaledSize(100))),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                            ),
                            onPressed: () => {onAskWord()},
                            child: Container(
                              color: AppState().getAskWordStatus()
                                  ? Color(AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .askWordColor)
                                  : Colors.blue,
                              height: AppState().getScaledSize(100),
                              width: AppState().getScaledSize(350),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  AppState().getAskWordStatus()
                                      ? 'ОТКАЗАТЬСЯ ОТ ВЫСТУПЛЕНИЯ'
                                      : 'ПРОШУ СЛОВА',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppState().getAskWordStatus()
                                          ? AppState().getScaledSize(20)
                                          : AppState().getScaledSize(30),
                                      color: Color(AppState()
                                          .getSettings()
                                          .palletteSettings
                                          .buttonTextColor)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
        StoreboardWidget(
          serverState: AppState().getServerState(),
          meeting: AppState().getCurrentMeeting(),
          question: AppState().getCurrentMeeting().agenda.questions.firstWhere(
              (element) =>
                  element.id ==
                  json.decode(
                      AppState().getServerState().params)['selectedQuestion'],
              orElse: () => null),
          settings: AppState().getSettings(),
          timeOffset: AppState().getTimeOffset(),
          screenScale: AppState().getDisplayScale(),
        ),
      ],
    );
  }

  void onAskWord() {
    if (AppState().getAskWordStatus()) {
      Provider.of<WebSocketConnection>(context, listen: false)
          .sendMessage('ПРОШУ СЛОВА СБРОС');
    } else {
      Provider.of<WebSocketConnection>(context, listen: false)
          .sendMessage('ПРОШУ СЛОВА');
    }
  }
}
