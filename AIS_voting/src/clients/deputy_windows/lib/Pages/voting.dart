import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class VotingPage extends StatefulWidget {
  VotingPage({Key key}) : super(key: key);

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  Question _question;
  @override
  void initState() {
    super.initState();

    var selectedQuestionId =
        json.decode(AppState().getServerState().params)['selectedQuestion'];
    _question = AppState().getCurrentMeeting().agenda.questions.firstWhere(
        (element) => element.id == selectedQuestionId,
        orElse: () => null);
  }

  void onVoting(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Text(
            AppState().getCurrentUser().toString(),
            style: TextStyle(fontSize: AppState().getScaledSize(22)),
          ),
          Expanded(
            child: Container(),
          ),
        ]),
        centerTitle: true,
      ),
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
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    return Container(
      padding: EdgeInsets.all(AppState().getHalfScaledSize(20)),
      child: Image(image: AssetImage('assets/images/emblem.png')),
    );
  }

  Widget rightPanel() {
    Provider.of<AppState>(context, listen: true);
    return Container(
      color: Colors.blue[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, AppState().getScaledSize(10), 0, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppState().getDecision() == 'ЗА'
                      ? Colors.white
                      : Colors.transparent,
                  width: AppState().getScaledSize(5),
                ),
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails d) => {onVoting('ЗА')},
                child: TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0))),
                      backgroundColor: MaterialStateProperty.all(
                        Color(AppState()
                            .getSettings()
                            .palletteSettings
                            .voteYesColor),
                      ),
                      overlayColor: MaterialStateProperty.all(
                          Colors.white.withAlpha(30))),
                  onPressed: () => null,
                  child: Container(
                    width: AppState().getScaledSize(370),
                    height: AppState().getScaledSize(100),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          'ЗА',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppState().getScaledSize(30),
                            color: Colors.white,
                          ),
                        ),
                        AppState().getDecision() == 'ЗА'
                            ? Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Icon(
                                      Icons.done,
                                      size: AppState().getScaledSize(46),
                                    ),
                                    Container(
                                      width: AppState().getScaledSize(10),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, AppState().getScaledSize(10), 0, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppState().getDecision() == 'ПРОТИВ'
                      ? Colors.white
                      : Colors.transparent,
                  width: AppState().getScaledSize(5),
                ),
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails d) => {onVoting('ПРОТИВ')},
                child: TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0))),
                      backgroundColor: MaterialStateProperty.all(
                        Color(AppState()
                            .getSettings()
                            .palletteSettings
                            .voteNoColor),
                      ),
                      overlayColor: MaterialStateProperty.all(
                          Colors.white.withAlpha(30))),
                  onPressed: () => null,
                  child: Container(
                    width: AppState().getScaledSize(370),
                    height: AppState().getScaledSize(100),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          'ПРОТИВ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppState().getScaledSize(30),
                            color: Colors.white,
                          ),
                        ),
                        AppState().getDecision() == 'ПРОТИВ'
                            ? Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Icon(
                                      Icons.done,
                                      size: AppState().getScaledSize(46),
                                    ),
                                    Container(
                                      width: AppState().getScaledSize(10),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, AppState().getScaledSize(10), 0,
                AppState().getScaledSize(10)),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppState().getDecision() == 'ВОЗДЕРЖАЛСЯ'
                      ? Colors.white
                      : Colors.transparent,
                  width: AppState().getScaledSize(5),
                ),
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails d) => {onVoting('ВОЗДЕРЖАЛСЯ')},
                child: TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0))),
                      backgroundColor: MaterialStateProperty.all(
                        Color(AppState()
                            .getSettings()
                            .palletteSettings
                            .voteIndifferentColor),
                      ),
                      overlayColor: MaterialStateProperty.all(
                          Colors.white.withAlpha(30))),
                  onPressed: () => null,
                  child: Container(
                    width: AppState().getScaledSize(370),
                    height: AppState().getScaledSize(100),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          'ВОЗДЕРЖАЛСЯ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppState().getScaledSize(30),
                            color: Colors.white,
                          ),
                        ),
                        AppState().getDecision() == 'ВОЗДЕРЖАЛСЯ'
                            ? Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Icon(
                                      Icons.done,
                                      size: AppState().getScaledSize(46),
                                    ),
                                    Container(
                                      width: AppState().getScaledSize(10),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          StoreboardWidget(
            serverState: AppState().getServerState(),
            meeting: AppState().getCurrentMeeting(),
            question: _question,
            settings: AppState().getSettings(),
            screenScale: AppState().getDisplayScale(),
            timeOffset: AppState().getTimeOffset(),
          ),
        ],
      ),
    );
  }
}
