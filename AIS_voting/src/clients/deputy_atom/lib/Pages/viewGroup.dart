import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class ViewGroupPage extends StatefulWidget {
  ViewGroupPage({Key key}) : super(key: key);

  @override
  _ViewGroupPageState createState() => _ViewGroupPageState();
}

class _ViewGroupPageState extends State<ViewGroupPage> {
  var _askWordTableScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: true);
    return Scaffold(
      body: AppState().getCurrentMeeting() == null ? Container() : body(),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Container(width: 2, color: Colors.lightBlue),
        Expanded(
          child: leftPanel(),
        ),
        Container(width: 2, color: Colors.lightBlue),
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    var isSmallView = MediaQuery.of(context).size.width <= 1508;
    return Container(
      color: Colors.black26,
      child: Column(
        children: [
          SchemeLegendWidget(
              settings: AppState().getSettings(),
              serverState: AppState().getServerState(),
              group: AppState().getCurrentMeeting().group,
              isOperatorView: false,
              isSmallView: isSmallView),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                color: Color(AppState()
                    .getSettings()
                    .palletteSettings
                    .schemeBackgroundColor),
                child: Scrollbar(
                  isAlwaysShown: false,
                  controller: ScrollController(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: WorkplacesSchemeWidget(
                        serverState: AppState().getServerState(),
                        group: AppState().getCurrentMeeting().group,
                        settings: AppState().getSettings(),
                        sendDocuments: {},
                        setSpeaker: setManagerMic,
                        setCurrentSpeaker: onSetCurrentSpeaker,
                        isOperatorView: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rightPanel() {
    var isSmallView = MediaQuery.of(context).size.height <= 950;
    var isRegistration =
        AppState().getServerState().systemState == SystemState.Registration;

    var isVoting =
        AppState().getServerState().systemState == SystemState.QuestionVoting;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.blue[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                isSmallView
                    ? Container()
                    : Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        height: 300,
                        child: Image(
                            image: AssetImage('assets/images/emblem.png')),
                      ),
                isSmallView
                    ? Container()
                    : Expanded(
                        child: Container(),
                      ),
                isVoting || isRegistration
                    ? Container()
                    : Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.lightBlue,
                              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Row(
                                children: [
                                  Container(width: 10),
                                  Text(
                                    'ЗАПИСАВШИЕСЯ НА ВЫСТУПЛЕНИЕ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Tooltip(
                                    message:
                                        'Очистить список записавшихся на выступление',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.indigoAccent),
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.fromLTRB(
                                                10, 15, 10, 15)),
                                      ),
                                      onPressed: () {
                                        removeAskWordAll();
                                      },
                                      child: Text(
                                        'Очистить список',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: getAskWordList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                !isRegistration
                    ? Container()
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .buttonTextColor),
                                  width: 5,
                                ),
                              ),
                              child: GestureDetector(
                                onPanDown: (DragDownDetails d) => AppState()
                                        .getIsRegistred()
                                    ? null
                                    : {onRegistration('ЗАРЕГИСТРИРОВАТЬСЯ')},
                                child: TextButton(
                                  autofocus: true,
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        Size(350, 100)),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () => null,
                                  child: Container(
                                    color: AppState().getIsRegistred()
                                        ? Colors.green
                                        : Colors.blue,
                                    height: 100,
                                    width: 350,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppState().getIsRegistred()
                                            ? 'ВЫ ЗАРЕГИСТРИРОВАНЫ'
                                            : 'ЗАРЕГИСТРИРОВАТЬСЯ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                !(isVoting && AppState().getIsRegistred())
                    ? Container()
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppState().getDecision() == 'ЗА'
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              child: GestureDetector(
                                onPanDown: (DragDownDetails d) =>
                                    {onVoting('ЗА')},
                                child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Color(AppState()
                                            .getSettings()
                                            .palletteSettings
                                            .voteYesColor),
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.white.withAlpha(30))),
                                  onPressed: () => null,
                                  child: Container(
                                    width: 370,
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Text(
                                          'ЗА',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
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
                                                      size: 46,
                                                    ),
                                                    Container(
                                                      width: 10,
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
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppState().getDecision() == 'ПРОТИВ'
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              child: GestureDetector(
                                onPanDown: (DragDownDetails d) =>
                                    {onVoting('ПРОТИВ')},
                                child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Color(AppState()
                                            .getSettings()
                                            .palletteSettings
                                            .voteNoColor),
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.white.withAlpha(30))),
                                  onPressed: () => null,
                                  child: Container(
                                    width: 370,
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Text(
                                          'ПРОТИВ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
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
                                                      size: 46,
                                                    ),
                                                    Container(
                                                      width: 10,
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
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      AppState().getDecision() == 'ВОЗДЕРЖАЛСЯ'
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              child: GestureDetector(
                                onPanDown: (DragDownDetails d) =>
                                    {onVoting('ВОЗДЕРЖАЛСЯ')},
                                child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Color(AppState()
                                            .getSettings()
                                            .palletteSettings
                                            .voteIndifferentColor),
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.white.withAlpha(30))),
                                  onPressed: () => null,
                                  child: Container(
                                    width: 370,
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Text(
                                          'ВОЗДЕРЖАЛСЯ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                        AppState().getDecision() ==
                                                'ВОЗДЕРЖАЛСЯ'
                                            ? Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                    Icon(
                                                      Icons.done,
                                                      size: 46,
                                                    ),
                                                    Container(
                                                      width: 10,
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
                        ],
                      ),
                !(isVoting || isRegistration)
                    ? Container()
                    : Expanded(
                        child: Container(),
                      ),
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
        ),
      ],
    );
  }

  Widget getAskWordList() {
    var usersAskingWord = <User>[];
    for (int i = 0;
        i < AppState().getServerState().usersAskSpeech.length;
        i++) {
      var foundUser = AppState().getUsers().firstWhere(
          (element) =>
              element.id == AppState().getServerState().usersAskSpeech[i],
          orElse: () => null);
      if (foundUser != null) {
        usersAskingWord.add(foundUser);
      }
    }

    if (usersAskingWord.length == 0) {
      return Container();
    }

    return Scrollbar(
      isAlwaysShown: true,
      controller: _askWordTableScrollController,
      child: ListView.builder(
        controller: _askWordTableScrollController,
        itemCount: usersAskingWord.length,
        itemBuilder: (BuildContext context, int index) {
          var element = usersAskingWord[index];
          var terminalId = AppState()
              .getServerState()
              .usersTerminals
              .entries
              .firstWhere((ut) => ut.value == element.id, orElse: () => null)
              ?.key;
          return InkWell(
            onTap: () {
              if (terminalId != null) {
                enableTerminal(terminalId, element.id);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppState().getServerState().currentSpeaker == terminalId
                    ? Colors.blueAccent.withAlpha(64)
                    : Colors.white,
                border: Border.all(
                  color:
                      AppState().getServerState().currentSpeaker == terminalId
                          ? Colors.blueAccent
                          : Colors.grey,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                      ),
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 260, maxWidth: 260),
                        child: Wrap(
                          children: [
                            Text(element.toString(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(fontSize: 18),
                                softWrap: true),
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                      Tooltip(
                        message: 'Убрать',
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            fixedSize: MaterialStateProperty.all(Size(30, 30)),
                            shape: MaterialStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            removeAskWord(element);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                    ],
                  ),
                  Container(
                    height: 7,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void removeAskWord(User user) {
    Provider.of<WebSocketConnection>(context, listen: false)
        .sendMessage('ПРОШУ СЛОВА СБРОС ${user.id}');
  }

  void removeAskWordAll() {
    Provider.of<WebSocketConnection>(context, listen: false)
        .sendMessage('ПРОШУ СЛОВА СБРОС ВСЕХ');
  }

  void onVoting(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  void onRegistration(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  void onSetCurrentSpeaker(String terminalId) {
    var isMicEnabled = terminalId != null &&
        terminalId.split(',').any((element) => AppState()
            .getServerState()
            .activeMics
            .contains(int.parse(element)));
    int speakerId = AppState().getServerState().usersTerminals[terminalId];

    if (!(AppState().getServerState().currentSpeaker != null &&
            AppState().getServerState().currentSpeaker == terminalId) &&
        speakerId != null &&
        !isMicEnabled) {
      enableTerminal(terminalId, speakerId);
    } else {
      disableTerminal(terminalId);
    }
  }

  void enableTerminal(String terminalId, int speakerId) {
    // Set storeboard with current speaker
    User speaker = AppState()
        .getCurrentMeeting()
        .group
        .groupUsers
        .firstWhere((element) => element.user.id == speakerId)
        .user;
    Provider.of<WebSocketConnection>(context, listen: false).setCurrentSpeaker(
        terminalId,
        'Выступление:',
        speaker.getFullName(),
        Duration(minutes: 0));

    //enable mic
    Provider.of<WebSocketConnection>(context, listen: false)
        .setSpeaker(terminalId, true);
  }

  void disableTerminal(String terminalId) {
    // flush storeboard
    Provider.of<WebSocketConnection>(context, listen: false).flushStoreboard();

    //disable mic
    Provider.of<WebSocketConnection>(context, listen: false)
        .setSpeaker(terminalId, false);
  }

  void setManagerMic(String terminalId, bool isOn) {
    //set managerMic state
    Provider.of<WebSocketConnection>(context, listen: false)
        .setSpeaker(terminalId, isOn);
  }
}
