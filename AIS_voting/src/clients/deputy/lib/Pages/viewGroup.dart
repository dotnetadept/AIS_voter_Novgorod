import 'dart:async';
import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deputy/Widgets/voting_utils.dart';
import 'package:global_configuration/global_configuration.dart';
import '../Utils/table_utils.dart';
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
  var _autoSizeGroup = AutoSizeGroup();
  var _schemeScrollControllerVertical = ScrollController();
  var _schemeScrollControllerHorisontal = ScrollController();
  var _askWordTableScrollController = new ScrollController();
  var _askWordGuestsScrollController = new ScrollController();
  var _micsEnabledTableScrollController = new ScrollController();
  var _unregistredTableScrollController = new ScrollController();
  var _setStoreboardDialog;

  int _defaultButtonsHeight;
  int _defaultButtonsWidth;
  WebSocketConnection _connection;
  Timer _clockTimer;

  @override
  void initState() {
    super.initState();

    _defaultButtonsHeight =
        int.parse(GlobalConfiguration().getValue('default_buttons_height'));
    _defaultButtonsWidth =
        int.parse(GlobalConfiguration().getValue('default_buttons_width'));

    _clockTimer = Timer.periodic(Duration(seconds: 1), (v) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _connection = Provider.of<WebSocketConnection>(context, listen: false);
    Provider.of<AppState>(context, listen: true);

    return Scaffold(
      body: AppState().getCurrentMeeting() == null ? Container() : body(),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Container(width: 2, color: Colors.black26),
        Expanded(
          child: leftPanel(),
        ),
        Container(width: 2, color: Colors.black26),
        Container(
          width: AppState().getSettings().storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    return Container(
      color: Color(AppState().getSettings().palletteSettings.backgroundColor),
      child: Column(
        children: [
          !AppState().getSettings().managerSchemeSettings.showLegend
              ? Container()
              : SchemeLegendWidget(
                  settings: AppState().getSettings(),
                  serverState: AppState().getServerState(),
                  group: AppState().getCurrentMeeting().group,
                  isOperatorView: false,
                  isSmallView: false),
          AppState().getSettings().managerSchemeSettings.useTableView
              ? TableSchemeWidget(
                  settings: AppState().getSettings(),
                  serverState: AppState().getServerState(),
                  group: AppState().getCurrentMeeting().group,
                  interval: AppState().getSelectedInterval(),
                  users: AppState().getUsers(),
                  timeOffset: AppState().getTimeOffset(),
                  setRegistration: (var v) {},
                  undoRegistration: (var v) {},
                  setSpeaker: _connection.setSpeaker,
                  setCurrentSpeaker: setCurrentSpeaker,
                  removeAskWord: removeAskWord,
                  setGuestSpeaker: setGuestSpeaker,
                  setTribuneSpeaker: onSetTribuneSpeaker,
                  setUser: (var v, var v2) {},
                  setUserExit: (var v) {},
                  setTerminalReset: (var v) {},
                  setTerminalShutdown: (var v) {},
                  setTerminalScreenOn: (var v) {},
                  setTerminalScreenOff: (var v) {},
                  setRefreshStreamAll: () {},
                  setResetAll: () {},
                  setShutdownAll: () {},
                  isOperatorView: false,
                )
              : Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Color(AppState()
                          .getSettings()
                          .palletteSettings
                          .schemeBackgroundColor),
                      child: Scrollbar(
                        thumbVisibility: false,
                        controller: _schemeScrollControllerVertical,
                        child: SingleChildScrollView(
                          controller: _schemeScrollControllerVertical,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            controller: _schemeScrollControllerHorisontal,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _schemeScrollControllerHorisontal,
                              scrollDirection: Axis.horizontal,
                              child: WorkplacesSchemeWidget(
                                settings: AppState().getSettings(),
                                serverState: AppState().getServerState(),
                                group: AppState().getCurrentMeeting().group,
                                interval: AppState().getSelectedInterval(),
                                setRegistration: (var v) {},
                                undoRegistration: (var v) {},
                                setSpeaker: _connection.setSpeaker,
                                setCurrentSpeaker: setCurrentSpeaker,
                                setTribuneSpeaker: onSetTribuneSpeaker,
                                setUser: (var v, var v2) {},
                                setUserExit: (var v) {},
                                setTerminalReset: (var v) {},
                                setTerminalShutdown: (var v) {},
                                setTerminalScreenOn: (var v) {},
                                setTerminalScreenOff: (var v) {},
                                setRefreshStreamAll: () {},
                                setResetAll: () {},
                                setShutdownAll: () {},
                                isOperatorView: false,
                                addGuest: _connection.setGuest,
                                addGuestAskWord: _connection.setGuestAskWord,
                                removeGuestAskWord: removeGuestAskWord,
                                reconnectToVissonic:
                                    _connection.reconnectToVissonic,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          !AppState().getSettings().managerSchemeSettings.showStatePanel
              ? Container()
              : StatePanelWidget(
                  settings: AppState().getSettings(),
                  serverState: AppState().getServerState(),
                  meeting: AppState().getCurrentMeeting(),
                  intervals: AppState().getIntervals(),
                  autoEnd: AppState().getAutoEnd(),
                  selectedInterval: AppState().getSelectedInterval(),
                  setStoreboardStatus: _connection.setStoreboardStatus,
                  setAutoEnd: AppState().setAutoEnd,
                  setInterval: AppState().setSelectedInterval,
                  changeView: () {
                    setState(() {
                      AppState()
                              .getSettings()
                              .managerSchemeSettings
                              .useTableView =
                          !AppState()
                              .getSettings()
                              .managerSchemeSettings
                              .useTableView;
                    });
                  },
                  navigateLicenseTab: () {},
                  isOperatorView: false,
                ),
          Container(
            height: 5,
          ),
        ],
      ),
    );
  }

  void setCurrentSpeaker(String terminalId, String name) {
    var selectedInterval = AppState().getSelectedInterval();

    int speakerId = AppState().getServerState().usersTerminals[terminalId];

    var foundSpeakerGU =
        AppState().getCurrentMeeting().group.groupUsers.firstWhere(
              (element) => element.user.id == speakerId,
              orElse: () => null,
            );

    var speakerSession = SpeakerSession();

    speakerSession.terminalId = terminalId;
    speakerSession.type = 'Выступление:';

    speakerSession.name = foundSpeakerGU?.user?.getFullName() ?? name;
    speakerSession.interval = selectedInterval.duration;
    speakerSession.autoEnd = selectedInterval.isAutoEnd;
    _connection.setCurrentSpeaker(speakerSession, selectedInterval?.startSignal,
        selectedInterval?.endSignal);
  }

  void setGuestSpeaker(String terminalId) {
    var guestName = AppState()
            .getServerState()
            .guestsPlaces
            .firstWhere((element) => element.terminalId == terminalId,
                orElse: () => null)
            ?.name ??
        'Гость[$terminalId]';

    var selectedInterval = AppState().getSelectedInterval();

    var speakerSession = SpeakerSession();

    speakerSession.type = 'Выступление:';

    speakerSession.name = guestName;
    speakerSession.terminalId = terminalId;
    speakerSession.interval = selectedInterval.duration;
    speakerSession.autoEnd = selectedInterval.isAutoEnd;
    _connection.setCurrentSpeaker(speakerSession, selectedInterval?.startSignal,
        selectedInterval?.endSignal);
  }

  void onSetTribuneSpeaker(String terminalId, String name) async {
    _setStoreboardDialog = SetStoreboardDialog(
      context,
      AppState().getServerState(),
      AppState().getTimeOffset(),
      AppState().getSettings(),
      AppState().getCurrentMeeting(),
      AppState().getCurrentMeeting().group,
      AppState().getIntervals().where((element) => element.isActive).toList(),
      null,
      false,
      terminalId,
      name,
      false,
      _connection.setCurrentSpeaker,
      _connection.setSpeaker,
      () {},
      () {},
      (StoreboardState s, String a) {},
      (ais.Interval i) {},
      (bool) {},
      _connection.setGuestAskWord,
      removeGuestAskWord,
      (int userId) {
        _connection.sendMessage('ПРОШУ СЛОВА $userId');
      },
      (int userId) {
        _connection.sendMessage('ПРОШУ СЛОВА СБРОС $userId');
      },
    );
    await _setStoreboardDialog.openDialog();
    _setStoreboardDialog = null;
  }

  Widget rightPanel() {
    return Column(
      children: <Widget>[
        getRightPanelTop(),
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
          votingModes: AppState().getVotingModes(),
          users: AppState().getUsers(),
        ),
      ],
    );
  }

  Widget getRightPanelTop() {
    var isRegistration =
        AppState().getServerState().systemState == SystemState.Registration;
    var isVoting =
        AppState().getServerState().systemState == SystemState.QuestionVoting;

    Widget view;

    if (isRegistration) {
      view = Column(
        children: [
          Expanded(
            child: getTables(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
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
                onPanDown: (DragDownDetails d) => AppState().getIsRegistred()
                    ? null
                    : {onRegistration('ЗАРЕГИСТРИРОВАТЬСЯ')},
                child: TextButton(
                  autofocus: true,
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(350, 60)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () => null,
                  child: Container(
                    color: AppState().getIsRegistred()
                        ? Colors.green
                        : Colors.blue,
                    height: 60,
                    width: 350,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppState().getIsRegistred()
                            ? 'ЗАРЕГИСТРИРОВАН'
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
      );
    } else if (isVoting) {
      if (AppState().getIsRegistred()) {
        view = Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Column(
              children: [
                VotingUtils().getVotingButton(
                    'ЗА',
                    AppState().getSettings().palletteSettings.voteYesColor,
                    false,
                    _defaultButtonsHeight,
                    _defaultButtonsWidth,
                    context,
                    setState,
                    _autoSizeGroup),
                VotingUtils().getVotingButton(
                    'ПРОТИВ',
                    AppState().getSettings().palletteSettings.voteNoColor,
                    false,
                    _defaultButtonsHeight,
                    _defaultButtonsWidth,
                    context,
                    setState,
                    _autoSizeGroup),
                VotingUtils().getVotingButton(
                    'ВОЗДЕРЖАЛСЯ',
                    AppState()
                        .getSettings()
                        .palletteSettings
                        .voteIndifferentColor,
                    false,
                    _defaultButtonsHeight,
                    _defaultButtonsWidth,
                    context,
                    setState,
                    _autoSizeGroup),
                // VotingUtils().getVotingButton(
                //     'СБРОС',
                //     AppState().getSettings().palletteSettings.voteResetColor,
                //     false,
                //     _defaultButtonsHeight,
                //     _defaultButtonsWidth,
                //     context,
                //     setState,
                //     _autoSizeGroup),
              ],
            ),
            Expanded(
              child: Container(),
            ),
          ],
        );
      } else {
        view = Column(
          children: [
            Expanded(
              child: VotingUtils().getEmblemButton(),
            ),
          ],
        );
      }
    } else {
      view = getTables();
    }

    return Expanded(
      child: Container(
        color: Colors.blue[100],
        child: Row(
          children: [
            Expanded(
              child: view,
            ),
          ],
        ),
      ),
    );
  }

  Widget getTables() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Container(width: 5),
                          Expanded(
                            child: Text(
                              'ЗАПИСАВШИЕСЯ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tooltip(
                            message: 'Очистить список записавшихся на вопрос',
                            child: GestureDetector(
                              onPanDown: (DragDownDetails d) =>
                                  {removeAskWordAll()},
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.indigoAccent),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.fromLTRB(0, 15, 0, 15)),
                                  shape: MaterialStateProperty.all(CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent))),
                                ),
                                onPressed: () {
                                  removeAskWordAll();
                                },
                                child: Icon(Icons.clear),
                              ),
                            ),
                          ),
                          Container(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: getAskWordList(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: Colors.black,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Container(width: 5),
                          Expanded(
                            child: Text(
                              'ЗАПИСАВШИЕСЯ ГОСТИ',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tooltip(
                            message:
                                'Очистить список записавшихся на выступление',
                            child: GestureDetector(
                              onPanDown: (DragDownDetails d) =>
                                  {removeAskWordAll()},
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.indigoAccent),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.fromLTRB(0, 15, 0, 15)),
                                  shape: MaterialStateProperty.all(
                                    CircleBorder(
                                      side:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  removeAskWordAll();
                                },
                                child: Icon(Icons.clear),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: getAskWordGuestList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              TableUtils()
                  .getUnregistredTable(_unregistredTableScrollController),
              Container(
                width: 1,
                color: Colors.black,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      height: 45,
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: [
                          Container(width: 5),
                          Expanded(
                            child: Text(
                              'ВКЛЮЧЕНЫ МИКРОФОНЫ ${AppState().getServerState().activeMics.length}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(width: 5),
                        ],
                      ),
                    ),
                    TableUtils().getMicsEnabledTable(
                        _micsEnabledTableScrollController, (terminalId) {
                      _connection.setSpeaker(terminalId, false);
                    }),
                  ],
                ),
              ),
            ],
          ),
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
      thumbVisibility: true,
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
          return Card(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                color: index % 2 == 0
                    ? Colors.white
                    : Colors.grey.withOpacity(0.2),
              ),
              padding: EdgeInsets.all(0),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      AppState().getServerState().speakerSession?.terminalId ==
                              terminalId
                          ? Colors.blueAccent.withAlpha(64)
                          : Colors.white,
                  border: Border.all(
                    color: AppState()
                                .getServerState()
                                .speakerSession
                                ?.terminalId ==
                            terminalId
                        ? Colors.blueAccent
                        : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Wrap(
                                children: [
                                  Text(element.getFullName(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 16),
                                      softWrap: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getAskWordGuestList() {
    if (AppState().getServerState().guestsAskSpeech.length == 0) {
      return Container();
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: _askWordGuestsScrollController,
      child: ListView.builder(
        controller: _askWordGuestsScrollController,
        itemCount: AppState().getServerState().guestsAskSpeech.length,
        itemBuilder: (BuildContext context, int index) {
          var guestName = AppState()
                  .getServerState()
                  .guestsPlaces
                  .firstWhere(
                      (element) =>
                          element.terminalId ==
                          AppState().getServerState().guestsAskSpeech[index],
                      orElse: () => null)
                  ?.name ??
              'Гость[${AppState().getServerState().guestsAskSpeech[index]}]';

          return Card(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                color: index % 2 == 0
                    ? Colors.white
                    : Colors.grey.withOpacity(0.2),
              ),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Wrap(
                              children: [
                                Text(guestName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 16),
                                    softWrap: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void removeAskWord(int userId) {
    Provider.of<WebSocketConnection>(context, listen: false)
        .sendMessage('ПРОШУ СЛОВА СБРОС $userId');
  }

  void removeAskWordAll() {
    Provider.of<WebSocketConnection>(context, listen: false)
        .sendMessage('ПРОШУ СЛОВА СБРОС ВСЕХ');
  }

  void removeGuestAskWord(String guest) {
    Provider.of<WebSocketConnection>(context, listen: false)
        .removeGuestAskWord(guest);
  }

  void onVoting(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  void onRegistration(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  void onSetCurrentSpeaker(String terminalId) {
    var isMicEnabled = AppState()
        .getServerState()
        .activeMics
        .entries
        .contains((element) => element.key == terminalId);
    int speakerId = AppState().getServerState().usersTerminals[terminalId];

    if (!(AppState().getServerState().speakerSession?.terminalId != null &&
            AppState().getServerState().speakerSession?.terminalId ==
                terminalId) &&
        speakerId != null &&
        !isMicEnabled) {
      //enableTerminal(terminalId, speakerId);
      removeAskWord(speakerId);
    } else {
      disableTerminal(terminalId);
    }
  }

  void enableTerminal(String terminalId, int speakerId) {
    // Set storeboard with current speaker
    User speaker = AppState()
        .getCurrentMeeting()
        .group
        .getVoters()
        .firstWhere((element) => element.user.id == speakerId)
        .user;

    var speakerSession = SpeakerSession();
    speakerSession.interval = 0;
    speakerSession.type = 'Выступление:';
    speakerSession.userId = speakerId;
    speakerSession.name = speaker.getFullName();
    Provider.of<WebSocketConnection>(context, listen: false)
        .setCurrentSpeaker(speakerSession, null, null);

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

  @override
  void dispose() {
    _clockTimer.cancel();

    super.dispose();
  }
}
