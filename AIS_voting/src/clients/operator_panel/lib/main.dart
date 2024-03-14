import 'dart:async';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:ntp/ntp.dart';
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;

import 'package:ais_utils/ais_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:operator_panel/Dialogs/history_dialog.dart';
import 'package:operator_panel/Pages/proxies.dart';
import 'package:operator_panel/Providers/SoundPlayer.dart';
import 'package:provider/provider.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Dialogs/documents_dialog.dart';
import 'Dialogs/stream_dialog.dart';
import 'Pages/users.dart';
import 'Pages/groups.dart';
import 'Pages/settings.dart';
import 'Pages/meetings.dart';
import 'Pages/agendas.dart';
import 'Pages/reconnect.dart';

import 'Providers/WebSocketConnection.dart';
import 'Providers/AppState.dart';
import 'Utility/db_helper.dart';
import 'Widgets/rightPanelTop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    SoundPlayer.init();
    AppState.init(widget.navigatorKey);
    WebSocketConnection.init(widget.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: WebSocketConnection.connect(),
        builder: (context, snapshot) {
          return MultiProvider(
            providers: [
              ListenableProvider<AppState>(
                  create: (_) => AppState(), lazy: false),
              ListenableProvider<WebSocketConnection>(
                  create: (_) => WebSocketConnection.getInstance(),
                  lazy: false),
            ],
            child: MaterialApp(
              title: 'Рабочее место оператора', //v 1.33
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                scrollbarTheme: ScrollbarThemeData(
                  thickness: MaterialStateProperty.all(12),
                ),
                textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.blueAccent),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                )),
                textTheme: GoogleFonts.ubuntuTextTheme(
                  Theme.of(context).textTheme,
                ),
                tooltipTheme: TooltipThemeData(
                  textStyle: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              home: OperatorPage(),
              navigatorKey: widget.navigatorKey,
              onGenerateRoute: _getRoute,
            ),
          );
        });
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/reconnect') {
      return _buildRoute(settings, ReconnectPage());
    }

    if (settings.name == '/main') {
      return _buildRoute(settings, OperatorPage());
    }

    return null;
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}

class OperatorPage extends StatefulWidget {
  OperatorPage({Key key}) : super(key: key);

  @override
  _OperatorPageState createState() => _OperatorPageState();
}

class _OperatorPageState extends State<OperatorPage> {
  Settings _settings;
  int _timeOffset;

  List<Meeting> _meetings = <Meeting>[];
  List<MeetingSession> _meetingSessions = <MeetingSession>[];
  List<VotingMode> _votingModes;
  List<User> _users = <User>[];

  Meeting _selectedMeeting;
  Question _selectedQuestion;
  Question _lockedQuestion;

  WebSocketConnection _connection;
  var _setStoreboardDialog;

  SystemState _prevSystemState;

  ScrollController _schemeScrollControllerVertical = ScrollController();
  ScrollController _schemeScrollControllerHorisontal = ScrollController();

  @override
  void initState() {
    super.initState();

    AppState().navigateUsersPage = navigateUsersPage;
    AppState().navigateGroupsPage = navigateGroupsPage;
    AppState().navigateProxiesPage = navigateProxiesPage;
    AppState().navigateAgendasPage = navigateAgendasPage;
    AppState().navigateSettingsPage = navigateSettingsPage;
    AppState().navigateMeetingsPage = navigateMeetingsPage;
    AppState().navigateHistoryPage = navigateHistoryPage;

    AppState().onStartStream = onStartStream;
    AppState().onLoadDocuments = onLoadDocuments;

    loadData();

    WebSocketConnection.updateServerState = setServerState;
    WebSocketConnection.updateAgendaCallback = setAgenda;
    WebSocketConnection.stopSound = SoundPlayer.cancelSound;

    StoreboardWidget.onIntervalEndingSignal = SoundPlayer.playEndingSignal;
  }

  void loadData() {
    setState(() {
      AppState().setIsLoadingComplete(false);
      _selectedMeeting = null;
    });
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/meetings"))
        .then((response) => {
              setState(() {
                _meetings = (json.decode(response.body) as List)
                    .map((data) => Meeting.fromJson(data))
                    .toList();

                if (_connection.getServerState != null) {
                  setServerState(_connection.getServerState);
                }
              })
            })
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/meeting_sessions"))
            .then((response) => {
                  setState(() {
                    _meetingSessions = (json.decode(response.body) as List)
                        .map((data) => MeetingSession.fromJson(data))
                        .toList();
                  })
                }))
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/voting_modes"))
            .then((response) => {
                  setState(() {
                    _votingModes = (json.decode(response.body) as List)
                        .map((data) => VotingMode.fromJson(data))
                        .toList();
                    if (_votingModes.length > 0) {
                      _votingModes
                          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
                    }
                  })
                }))
        .then((value) => http
            .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/settings"))
            .then((response) => {
                  setState(() {
                    _settings = (json.decode(response.body) as List)
                        .map((data) => Settings.fromJson(data))
                        .toList()
                        .firstWhere((element) => element.isSelected,
                            orElse: () => null);

                    SoundPlayer.setOperatorIsActive(
                        _settings.signalsSettings.isOperatorPlaySound);
                    SoundPlayer.setStoreboardIsActive(
                        _settings.signalsSettings.isStoreboardPlaySound);

                    AppState()
                        .setVolume(_settings.signalsSettings.systemVolume);
                  })
                }))
        .then((value) => http.get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/signals")).then((response) => {
              setState(() {
                var signals = (json.decode(response.body) as List)
                    .map((data) => Signal.fromJson(data))
                    .toList();

                for (int i = 0; i < signals.length; i++) {
                  if (signals[i].soundPath != null &&
                      signals[i].soundPath.isNotEmpty) {
                    SoundPlayer.loadSound(
                        signals[i].soundPath, signals[i].id.toString());
                  }
                }

                AppState().setSignals(signals);
              })
            }))
        .then((value) => http.get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/intervals")).then((response) => {
              setState(() {
                var intervals = (json.decode(response.body) as List)
                    .map((data) => ais.Interval.fromJson(data))
                    .toList();

                if (intervals.length > 0) {
                  intervals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
                }

                AppState().setIntervals(intervals);

                var selectedInterval = AppState().getIntervals().firstWhere(
                      (element) =>
                          element.id ==
                          _settings.intervalsSettings.defaultSpeakerIntervalId,
                      orElse: () => null,
                    );

                AppState().setInterval(selectedInterval);
              })
            }))
        .then((value) => http.get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users")).then((response) => {
              setState(() {
                _users = (json.decode(response.body) as List)
                    .map((data) => User.fromJson(data))
                    .toList();
              })
            }))
        .then((value) {
      NTP
          .getNtpOffset(
        localTime: DateTime.now(),
        lookUpAddress: GlobalConfiguration().getValue('ntp_server'),
        timeout: Duration(seconds: 10),
      )
          .onError((error, stackTrace) {
        print(
            'Отсутствует синхронизация с сервером времени. ${error.toString()} ${stackTrace.toString()}');
        return null;
      }).then((value) async {
        if (value == null) {
          var noButtonPressed = false;
          var title = 'Отсутствует синхронизация с сервером времени.';

          await Utility().showYesNoDialog(
            context,
            title: title,
            message: TextSpan(
              text:
                  'Вы уверены, что хотите продолжить без синхронизации с сервером времени?',
            ),
            yesButtonText: 'Да',
            yesCallBack: () {
              Navigator.of(context).pop();
            },
            noButtonText: 'Нет',
            noCallBack: () {
              noButtonPressed = true;
              Navigator.of(context).pop();
            },
          );

          if (noButtonPressed) {
            exit(0);
          }

          value = 0;
        }

        setState(() {
          _timeOffset = value;
        });
      }).then((value) {
        SoundPlayer.loadSound(
            _settings.signalsSettings.hymnStart, 'hymn_start');
        SoundPlayer.loadSound(_settings.signalsSettings.hymnEnd, 'hymn_end');
      }).then((value) => {AppState().setIsLoadingComplete(true)});
    });
  }

  void setServerState(ServerState serverState) {
    // update mic status on setStoreboardDialog dialog window
    _setStoreboardDialog?.update(serverState.activeMics);

    int selectedMeetingId = json.decode(serverState.params)['selectedMeeting'];
    int selectedQuestionId =
        json.decode(serverState.params)['selectedQuestion'];
    String status = json.decode(serverState.params)['status'];
    DateTime lastUpdated =
        json.decode(serverState.params)['lastUpdated'] == null
            ? null
            : DateTime.parse(json.decode(serverState.params)['lastUpdated']);

    if (_connection.getServerState != null &&
        selectedMeetingId == null &&
        _prevSystemState != serverState.systemState) {
      _selectedMeeting = null;
      _selectedQuestion = null;
      _lockedQuestion = null;
    }

    if (_connection.getServerState != null &&
        _meetings != null &&
        selectedMeetingId != null) {
      // refresh selected meeting if changed
      if (_selectedMeeting?.id != selectedMeetingId && _meetings.isNotEmpty) {
        _selectedMeeting = _meetings.firstWhere(
            (element) => element.id == selectedMeetingId,
            orElse: () => null);
        _selectedMeeting.agenda.questions
            .sort((a, b) => a.orderNum.compareTo(b.orderNum));
      }

      // refresh status, lastUpdated, selected and locked question if changed
      if (_selectedMeeting != null) {
        _selectedMeeting.status = status;
        _selectedMeeting.lastUpdated = lastUpdated;

        if (selectedQuestionId != null) {
          if (_lockedQuestion?.id != selectedQuestionId) {
            _lockedQuestion = _selectedMeeting.agenda.questions.firstWhere(
                (element) => element.id == selectedQuestionId,
                orElse: () => null);
          }
        } else {
          _lockedQuestion = null;

          //fix locked question on fixed voting mode
          if (_settings?.votingSettings?.isVotingFixed == true &&
              SystemStateHelper.isStarted(serverState.systemState)) {
            lockQuestion(_selectedMeeting.agenda.questions.first);
          }
        }

        // set selected question if it is absent
        if (_selectedQuestion == null) {
          _selectedQuestion = _lockedQuestion;
        }
      } else {
        _lockedQuestion = null;
      }
    }

    if (serverState != null &&
        (serverState.systemState == SystemState.Registration ||
            serverState.systemState == SystemState.QuestionVoting ||
            serverState.systemState == SystemState.AskWordQueue) &&
        _prevSystemState != serverState.systemState) {
      SoundPlayer.playSignal(serverState.startSignal);
    } else if (serverState != null &&
        (serverState.systemState == SystemState.QuestionVotingComplete ||
            serverState.systemState == SystemState.RegistrationComplete ||
            serverState.systemState == SystemState.AskWordQueueCompleted) &&
        _prevSystemState != serverState.systemState) {
      SoundPlayer.playSignal(serverState.endSignal);
    }

    _connection.setServerState(serverState);
    _prevSystemState = serverState.systemState;

    setState(() {});
  }

  void setAgenda(Agenda agenda) {
    setState(() {
      _selectedMeeting.agenda.questions = agenda.questions;

      _lockedQuestion = _selectedMeeting.agenda.questions.firstWhere(
          (element) => element.id == _lockedQuestion?.id,
          orElse: () => null);
      _selectedQuestion = _selectedMeeting.agenda.questions.firstWhere(
          (element) => element.id == _selectedQuestion?.id,
          orElse: () => null);

      _selectedMeeting.agenda.questions
          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
    });
  }

  void _onSetSpeaker(String terminalId, bool isMicrophoneOn) {
    _connection.setSpeaker(terminalId, isMicrophoneOn);
  }

  void _onSetCurrentSpeaker(String terminalId, String name) async {
    _setStoreboardDialog = SetStoreboardDialog(
      context,
      _connection.getServerState,
      _timeOffset,
      _settings,
      _selectedMeeting,
      _selectedMeeting.group,
      AppState().getIntervals().where((element) => element.isActive).toList(),
      AppState().getSelectedInterval(),
      AppState().getAutoEnd(),
      terminalId,
      name,
      true,
      _onSetCurrentSpeakerSound,
      _connection.setSpeaker,
      _connection.setFlushNavigation,
      onFlushStoreboard,
      _connection.setStoreboardStatus,
      (ais.Interval interval) {
        setState(() {
          AppState().setInterval(interval);
        });
      },
      (bool autoEnd) {
        setState(() {
          AppState().setAutoEnd(autoEnd);
        });
      },
      addGuestAskWord,
      removeGuestAskWord,
      addUserAskWord,
      removeUserAskWord,
    );
    await _setStoreboardDialog.openDialog();
    _setStoreboardDialog = null;
  }

  void _onSetGuestSpeaker(String terminalId) async {
    var selectedInterval = AppState().getSelectedInterval();
    var speakerSession = SpeakerSession();

    var guestName = _connection.getServerState.guestsPlaces
            .firstWhere((element) => element.terminalId == terminalId,
                orElse: () => null)
            ?.name ??
        'Гость[$terminalId]';
    speakerSession.type = 'Выступление:';

    speakerSession.name = guestName;
    speakerSession.terminalId = terminalId;
    speakerSession.interval = selectedInterval.duration;
    speakerSession.autoEnd = selectedInterval.isAutoEnd;
    _connection.setCurrentSpeaker(speakerSession, selectedInterval?.startSignal,
        selectedInterval?.endSignal);
  }

  void _onSetCurrentSpeakerSound(
      SpeakerSession speakerSession, Signal startSignal, Signal endSignal) {
    SoundPlayer.playSignal(startSignal, isInternal: false);

    _connection.setCurrentSpeaker(speakerSession, startSignal, endSignal);
  }

  void onFlushStoreboard() {
    if (_lockedQuestion != null) {
      _connection.setSystemStatus(
          SystemState.QuestionLocked,
          json.encode({
            'question_id': _lockedQuestion.id,
          }));
    } else if (_selectedMeeting != null &&
        SystemStateHelper.isStarted(_connection.getServerState.systemState)) {
      _connection.setFlushMeetingState();
    } else {
      _connection.setStoreboardStatus(StoreboardState.None, null);
    }
  }

  void _onSetRegistration(int deputyId) {
    _connection.setUserRegistration(deputyId);
  }

  void _onUndoRegistration(int deputyId) {
    _connection.undoUserRegistration(deputyId);
  }

  void _onRemoveAskWord(int userId) {
    _connection.removeUserAskWord(userId);
  }

  void _onSetUser(String terminalId, int userId) async {
    if (terminalId == null || terminalId.isEmpty) {
      return;
    }

    // do not select user if it already selected
    if (userId != null) {
      _connection.setUser(terminalId, userId);
      return;
    }

    // show select user dialog
    TextEditingController _tecTerminalId = new TextEditingController();
    _tecTerminalId.text = terminalId;
    final formKey = GlobalKey<FormState>();
    int _userId = userId;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Назначить пользователя'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: _tecTerminalId,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ИД терминала',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'ИД терминала не должен быть пустым';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  DropdownSearch<User>(
                    mode: Mode.DIALOG,
                    showSearchBox: true,
                    items: UsersFilterUtil.getAbsentUserList(_users,
                        _selectedMeeting.group, _connection.getServerState),
                    enabled: true,
                    popupTitle: Container(
                        alignment: Alignment.center,
                        color: Colors.blueAccent,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Неактивные пользователи группы',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20),
                        )),
                    validator: (value) {
                      if (value == null) {
                        return 'Выберите пользователя';
                      }
                      return null;
                    },
                    hint: 'Выберите пользователя',
                    selectedItem: _selectedMeeting.group.groupUsers
                        .map((e) => e.user)
                        .where((element) => !_connection
                            .getServerState.usersTerminals.keys
                            .contains(element.id))
                        .firstWhere(
                            (element) =>
                                element.id != null && element.id == _userId,
                            orElse: () => null),
                    onChanged: (value) {
                      setState(() {
                        _userId = value?.id;
                      });
                    },
                    popupItemBuilder: userPopupItemBuilder,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                _connection.setUser(terminalId, _userId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget userPopupItemBuilder(
      BuildContext context, User item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Text(item.toString()),
      ),
    );
  }

  void saveGroup(Group group) {
    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/groups/${_selectedMeeting.group.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(_selectedMeeting.group.toJson()))
        .then((value) => Navigator.pop(context));

    setState(() {});
  }

  void addGuest(String guest, String terminalId) {
    _connection.setGuest(guest, terminalId);
  }

  void removeGuest(
    String guest,
  ) {
    _connection.removeGuest(guest);
  }

  void addGuestAskWord(String guest) {
    if (guest != null && guest.isNotEmpty) {
      _connection.setGuestAskWord(guest);
    }
  }

  void addUserAskWord(int userId) {
    _connection.setUserAskWord(userId);
  }

  void removeUserAskWord(int userId) {
    _connection.removeUserAskWord(userId);
  }

  void removeGuestAskWord(String guest) {
    _connection.removeGuestAskWord(guest);
  }

  void _onSetUserExit(String terminalId) {
    _connection.setUserExit(terminalId);
  }

  void _onSetTerminalReset(String terminalId) {
    _connection.setTerminalReset(terminalId);
  }

  void _onSetTerminalShutdown(String terminalId) {
    _connection.setTerminalShutdown(terminalId);
  }

  void _onSetTerminalScreenOn(String terminalId) {
    _connection.setTerminalScreenOn(terminalId);
  }

  void _onSetTerminalScreenOff(String terminalId) {
    _connection.setTerminalScreenOff(terminalId);
  }

  void _onSetRefreshStreamAll() {
    _connection.setRefreshStream();
  }

  void _onSetShutdownAll() {
    _connection.setShutdownAll();
  }

  void _onSetResetAll() {
    _connection.setResetAll();
  }

  void onStartStream() {
    StreamDialog(context, _settings, () {
      SoundPlayer.playSoundByType('hymn_start');
    }, () {
      SoundPlayer.playSoundByType('hymn_end');
    }, () {
      SoundPlayer.cancelSound();
    }).openDialog();
  }

  void onLoadDocuments() {
    DocumentsDialog(context, _settings, _selectedMeeting, _users).openDialog();
  }

  void navigateLicenseTab() {
    navigateSettingsPage(startedTabIndex: 11);
  }

  void cangeView() {
    setState(() {
      _settings.operatorSchemeSettings.useTableView =
          !_settings.operatorSchemeSettings.useTableView;
    });

    DbHelper.saveSettings(_settings);
  }

  void navigateUsersPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => UsersPage()))
        .then((value) => loadData());
  }

  void navigateGroupsPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => GroupsPage()))
        .then((value) => loadData());
  }

  void navigateProxiesPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProxiesPage()))
        .then((value) => loadData());
  }

  void navigateMeetingsPage() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MeetingsPage(_settings, _timeOffset, _selectedMeeting)))
        .then((value) => loadData());
  }

  void navigateHistoryPage() {
    HistoryDialog(context, _settings, _timeOffset).openDialog();
  }

  void navigateAgendasPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AgendasPage(
                  settings: _settings,
                  timeOffset: _timeOffset,
                ))).then((value) => loadData());
  }

  void navigateSettingsPage({int startedTabIndex = 0}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingsPage(
                  users: _users,
                  startedTabIndex: startedTabIndex,
                ))).then((value) {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    _connection = Provider.of<WebSocketConnection>(context, listen: true);

    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    if (!AppState().getIsLoadingComplete() ||
        _connection.getServerState == null ||
        _settings == null) {
      return Row(
        children: [
          Expanded(
            child: CommonWidgets().getLoadingStub(),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
        Container(
          width: _settings.storeboardSettings.width.toDouble(),
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel() {
    var isSmallView = MediaQuery.of(context).size.width <= 1508;
    return Container(
      color: Color(_settings.palletteSettings.backgroundColor),
      child: Column(
        children: [
          !_settings.operatorSchemeSettings.showLegend
              ? Container()
              : SchemeLegendWidget(
                  settings: _settings,
                  serverState: _connection.getServerState,
                  group: _selectedMeeting?.group,
                  isOperatorView: true,
                  isSmallView: isSmallView),
          _settings.operatorSchemeSettings.useTableView
              ? TableSchemeWidget(
                  settings: _settings,
                  serverState: _connection.getServerState,
                  group: _selectedMeeting?.group,
                  interval: AppState().getSelectedInterval(),
                  timeOffset: _timeOffset,
                  users: _users,
                  setRegistration: _onSetRegistration,
                  undoRegistration: _onUndoRegistration,
                  setSpeaker: _onSetSpeaker,
                  setGuestSpeaker: _onSetGuestSpeaker,
                  removeAskWord: _onRemoveAskWord,
                  removeGuestAskWord: removeGuestAskWord,
                  setCurrentSpeaker: _onSetCurrentSpeaker,
                  setTribuneSpeaker: _onSetCurrentSpeaker,
                  setUser: _onSetUser,
                  setUserExit: _onSetUserExit,
                  setTerminalReset: _onSetTerminalReset,
                  setTerminalShutdown: _onSetTerminalShutdown,
                  setTerminalScreenOn: _onSetTerminalScreenOn,
                  setTerminalScreenOff: _onSetTerminalScreenOff,
                  setRefreshStreamAll: _onSetRefreshStreamAll,
                  setResetAll: _onSetResetAll,
                  setShutdownAll: _onSetShutdownAll,
                  addUserAskWord: addUserAskWord,
                  isOperatorView: true,
                )
              : Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Color(
                          _settings.palletteSettings.schemeBackgroundColor),
                      child: Scrollbar(
                        thumbVisibility: false,
                        controller: _schemeScrollControllerVertical,
                        child: SingleChildScrollView(
                          controller: _schemeScrollControllerVertical,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: _schemeScrollControllerHorisontal,
                            child: SingleChildScrollView(
                              controller: _schemeScrollControllerHorisontal,
                              scrollDirection: Axis.horizontal,
                              child: WorkplacesSchemeWidget(
                                settings: _settings,
                                serverState: _connection.getServerState,
                                group: _selectedMeeting?.group,
                                interval: AppState().getSelectedInterval(),
                                setRegistration: _onSetRegistration,
                                undoRegistration: _onUndoRegistration,
                                setSpeaker: _onSetSpeaker,
                                setCurrentSpeaker: _onSetCurrentSpeaker,
                                setTribuneSpeaker: _onSetCurrentSpeaker,
                                setUser: _onSetUser,
                                setUserExit: _onSetUserExit,
                                setTerminalReset: _onSetTerminalReset,
                                setTerminalShutdown: _onSetTerminalShutdown,
                                setTerminalScreenOn: _onSetTerminalScreenOn,
                                setTerminalScreenOff: _onSetTerminalScreenOff,
                                setRefreshStreamAll: _onSetRefreshStreamAll,
                                setResetAll: _onSetResetAll,
                                setShutdownAll: _onSetShutdownAll,
                                isOperatorView: true,
                                saveGroup: saveGroup,
                                addGuest: addGuest,
                                removeGuest: removeGuest,
                                addGuestAskWord: addGuestAskWord,
                                removeGuestAskWord: removeGuestAskWord,
                                addUserAskWord: addUserAskWord,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          !_settings.operatorSchemeSettings.showStatePanel
              ? Container()
              : StatePanelWidget(
                  settings: _settings,
                  serverState: _connection.getServerState,
                  meeting: _selectedMeeting,
                  intervals: AppState()
                      .getIntervals()
                      .where((element) => element.isActive)
                      .toList(),
                  selectedInterval: AppState().getSelectedInterval(),
                  autoEnd: AppState().getAutoEnd(),
                  volume: AppState().getVolume(),
                  setStoreboardStatus: _connection.setStoreboardStatus,
                  setInterval: (ais.Interval interval) {
                    setState(() {
                      AppState().setInterval(interval);
                    });
                  },
                  setAutoEnd: (bool autoEnd) {
                    setState(() {
                      AppState().setAutoEnd(autoEnd);
                    });
                  },
                  setVolume: (double volume) {
                    setState(() {
                      AppState().setVolume(volume);
                      _settings.signalsSettings.systemVolume = volume;
                      DbHelper.saveSettings(_settings);
                    });
                  },
                  navigateLicenseTab: navigateLicenseTab,
                  changeView: cangeView,
                  isOperatorView: true,
                ),
        ],
      ),
    );
  }

  void changeSelectedMeeting(Meeting selectedMeeting) {
    setState(() {
      _selectedMeeting = selectedMeeting;
    });
  }

  Widget rightPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RightPanelTop(
          meetings: _meetings,
          settings: _settings,
          users: _users,
          selectedMeeting: _selectedMeeting,
          lockedQuestion: _lockedQuestion,
          selectedQuestion: _selectedQuestion,
          votingModes: _votingModes,
          changeSelectedMeeting: changeSelectedMeeting,
          timeOffset: _timeOffset,
          setInterval: (ais.Interval interval) {
            setState(() {
              AppState().setInterval(interval);
            });
          },
          setAutoEnd: (bool autoEnd) {
            setState(() {
              AppState().setAutoEnd(autoEnd);
            });
          },
          addGuestAskWord: addGuestAskWord,
          removeGuestAskWord: removeGuestAskWord,
          addUserAskWord: addUserAskWord,
          removeUserAskWord: removeUserAskWord,
        ),
        StoreboardWidget(
          serverState: _connection.getServerState,
          meeting: _selectedMeeting,
          question: _lockedQuestion,
          settings: _settings,
          timeOffset: _timeOffset,
          votingModes: _votingModes,
          users: _users,
        ),
      ],
    );
  }

  void lockQuestion(Question question) {
    _connection.setSystemStatus(
        SystemState.QuestionLocked,
        json.encode({
          'question_id': question.id,
        }));
  }
}
