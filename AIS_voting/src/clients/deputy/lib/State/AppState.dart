import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:ntp/ntp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:synchronized/synchronized.dart';
import '../Utils/stream_utils.dart';
import 'CardState.dart';
import 'WebSocketConnection.dart';

class AppState with ChangeNotifier {
  static WebSocketChannel _channel;
  static ServerState _serverState;

  static List<User> _users;
  static List<VotingMode> _votingModes;
  static User _currentUser;
  static Meeting _currentMeeting;
  static Settings _settings;
  static int _timeOffset;
  static bool _isLoadingComplete = false;

  static bool _isRegistred = false;
  static bool _isDocumentsChecked = false;
  static bool _isDocumentsDownloaded = false;
  static bool _isLoadingInProgress = false;
  static String _decision;
  static bool _askWordStatus = false;
  static String _currentPage = '';

  static AppState _singleton = AppState._internal();

  // selected agenda items
  static Question _currentQuestion;
  static QuestionFile _currentDocument;
  static QuestionFile _agendaDocument;
  static int _agendaTabNavigation;
  static double _agendaScrollPosition;

  // intervals
  List<ais.Interval> _intervals;
  ais.Interval _selectedInterval;
  bool _autoEnd = false;

  // prev card values
  static bool _prevIsCardOn = false;

  // stream
  static bool _exitStream = false;
  static Future<void> Function() refreshStream;

  // guest name
  String _guestName;

  Lock _lock = Lock();

  factory AppState() {
    return _singleton;
  }

  AppState._internal() {
    CardState.init();

    // check card timer
    Timer.periodic(Duration(seconds: 1), (v) async {
      _lock.synchronized(() async {
        // do not read card until loading not completed or meeting is not loaded
        if (!getIsLoadingComplete() || _currentMeeting == null) {
          return;
        }

        var isCardOn = await CardState.isCardOn();
        if (isCardOn != _prevIsCardOn || CardState.getRefresh) {
          _prevIsCardOn = isCardOn;
          CardState.setRefresh(false);
          if (!isCardOn) {
            WebSocketConnection.getInstance().onUserExit();
          } else {
            User currentUser = await CardState.updateCardUser();

            bool isCurrentUserNotInGroup =
                AppState().getCurrentMeeting() == null ||
                    !AppState()
                        .getCurrentMeeting()
                        .group
                        .groupUsers
                        .any((element) => element.user.id == currentUser.id);

            // set guest if user not in group
            if (currentUser != null && isCurrentUserNotInGroup) {
              _guestName = currentUser.getShortName();

              WebSocketConnection.getInstance().setGuest(
                  _guestName, GlobalConfiguration().getValue('terminal_id'));
              currentUser = null;
            } else {
              if (_guestName != null) {
                WebSocketConnection.getInstance().removeGuest(_guestName);
              }

              _guestName = null;
            }

            if (currentUser == null) {
              WebSocketConnection.getInstance().onUserExit();
            } else {
              setCurrentUser(currentUser);
              setIsRegistred(AppState()
                  .getServerState()
                  .usersRegistered
                  .contains(AppState().getCurrentUser().id));

              // update serverState internally
              AppState().getServerState().usersTerminals.putIfAbsent(
                  GlobalConfiguration().getValue('terminal_id'),
                  () => AppState().getCurrentUser().id);

              var clientType =
                  AppState().isCurrentUserManager() ? 'manager' : 'deputy';
              WebSocketConnection.getInstance().updateClientType(
                  clientType, getCurrentUser().id,
                  isUseAuthCard: true);

              WebSocketConnection.getInstance().processNavigation();
            }
          }
        }
      });
    });

    Timer.periodic(
        Duration(
            milliseconds: int.parse(
                GlobalConfiguration().getValue('terminal_timer_delay'))),
        (timer) async {
      //close evince if current page is not viewDocument
      if (AppState().getCurrentPage() != '/viewDocument') {
        try {
          Process.runSync('killall', <String>['evince']);
        } catch (exc) {
          print('${DateTime.now()} Timer Evince Exception: $exc\n');
        }
      }
    });
  }

  Future<void> loadData(int meetingId) async {
    var intervalsData = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()),
        "/intervals"));

    var intervals = (json.decode(intervalsData.body) as List)
        .map((data) => ais.Interval.fromJson(data))
        .toList();

    if (intervals.length > 0) {
      intervals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
    }

    AppState().setIntervals(intervals);

    var settingsData = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/settings"));
    var settings = (json.decode(settingsData.body) as List)
        .map((data) => Settings.fromJson(data))
        .toList()
        .firstWhere((element) => element.isSelected, orElse: () => null);
    AppState().setSettings(settings);

    var selectedInterval = AppState().getIntervals().firstWhere(
          (element) =>
              element.id ==
              _settings.intervalsSettings.defaultSpeakerIntervalId,
          orElse: () => null,
        );
    AppState().setSelectedInterval(selectedInterval);

    var ntpOffset = await NTP
        .getNtpOffset(
      localTime: DateTime.now(),
      lookUpAddress: GlobalConfiguration().getValue('ntp_server'),
      timeout: Duration(
          milliseconds:
              int.parse(GlobalConfiguration().getValue('ntp_timeout'))),
    )
        .onError((error, stackTrace) {
      print(
          'Отсутствует синхронизация с сервером времени. ${error.toString()} ${stackTrace.toString()}');
      return null;
    });
    // Set ntpOffset = 0 to use local time if no ntp sync avaliable
    if (ntpOffset == null) {
      ntpOffset = 0;
    }
    AppState().setTimeOffset(ntpOffset);

    var usersData = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"));
    var users = (json.decode(usersData.body) as List)
        .map((data) => User.fromJson(data))
        .toList();
    AppState().setUsers(users);

    var votingModesData = await http.get(Uri.http(
        ServerConnection.getHttpServerUrl(GlobalConfiguration()),
        "/voting_modes"));
    var votingModes = (json.decode(votingModesData.body) as List)
        .map((data) => VotingMode.fromJson(data))
        .toList();
    AppState().setVotingModes(votingModes);

    if (meetingId != null) {
      var meetingsData = await http.get(Uri.http(
          ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          '/meetings/$meetingId'));
      AppState()
          .setCurrentMeeting(Meeting.fromJson(json.decode(meetingsData.body)));
    }

    setIsLoadingComplete(true);
    WebSocketConnection.getInstance().processNavigation();
  }

  bool getExitStream() {
    return _exitStream;
  }

  void setExitStream(bool value) {
    _exitStream = value;
  }

  String getCurrentPage() {
    return _currentPage;
  }

  void setCurrentPage(String value) {
    _currentPage = value;
  }

  bool canUserNavigate() {
    // disable deputy navigation events if system in registration/voting state
    if (WebSocketConnection.getInstance().getClientType() == 'deputy' &&
        getServerState() != null &&
        (getServerState().systemState == SystemState.Registration ||
            getServerState().systemState == SystemState.QuestionVoting)) {
      return false;
    }
    return true;
  }

  bool getIsLoadingComplete() {
    return _isLoadingComplete;
  }

  void setIsLoadingComplete(bool isLoadingComplete) {
    _isLoadingComplete = isLoadingComplete;
    notifyListeners();
  }

  ServerState getServerState() {
    return _serverState;
  }

  void setServerState(ServerState state) {
    _serverState = state;

    notifyListeners();
  }

  User getCurrentUser() {
    return _currentUser;
  }

  String getCurrentGuest() {
    return getServerState()
            .guestsPlaces
            .firstWhere(
                (element) =>
                    element.terminalId ==
                    GlobalConfiguration().getValue('terminal_id').toString(),
                orElse: () => null)
            ?.name ??
        '';
  }

  void setCurrentUser(User user) {
    _currentUser = user;

    notifyListeners();
  }

  List<User> getUsers() {
    return _users;
  }

  void setUsers(List<User> users) {
    _users = users;
  }

  List<VotingMode> getVotingModes() {
    return _votingModes;
  }

  void setVotingModes(List<VotingMode> votingModes) {
    _votingModes = votingModes;
  }

  bool isCurrentUserManager() {
    var result = false;

    if (AppState().getCurrentMeeting() == null ||
        AppState().getCurrentUser() == null) {
      return result;
    }

    if (AppState().getCurrentUser().id ==
        GroupUtil().getManagerId(AppState().getCurrentMeeting().group,
            _serverState.usersTerminals)) {
      result = true;
    }

    return result;
  }

  Meeting getCurrentMeeting() {
    return _currentMeeting;
  }

  void setCurrentMeeting(Meeting meeting) {
    _currentMeeting = meeting;
    if (_currentMeeting != null &&
        _currentMeeting.agenda.questions.length > 0) {
      _currentMeeting.agenda.questions
          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
    }

    notifyListeners();
  }

  void setAgendaTab(int tabIndex) {
    _agendaTabNavigation = tabIndex;
  }

  int getAgendaTab() {
    return _agendaTabNavigation;
  }

  void setAgendaScrollPosition(double agendaScrollPosition) {
    _agendaScrollPosition = agendaScrollPosition;
  }

  double getAgendaScrollPosition() {
    return _agendaScrollPosition;
  }

  void setCurrentDocument(QuestionFile document) {
    _currentDocument = document;
  }

  QuestionFile getCurrentDocument() {
    return _currentDocument;
  }

  QuestionFile getAgendaDocument() {
    return _agendaDocument;
  }

  void setAgendaDocument(QuestionFile document) {
    _agendaDocument = document;
  }

  void setCurrentQuestion(Question question) {
    _currentQuestion = question;
  }

  Question getCurrentQuestion() {
    return _currentQuestion;
  }

  Settings getSettings() {
    return _settings;
  }

  void setSettings(Settings settings) {
    _settings = settings;
  }

  int getTimeOffset() {
    return _timeOffset;
  }

  void setTimeOffset(int timeOffset) {
    _timeOffset = timeOffset;
  }

  WebSocketChannel getWsChannel() {
    return _channel;
  }

  void setWsChannel(WebSocketChannel channel) {
    _channel = channel;
  }

  bool getIsRegistred() {
    return _isRegistred;
  }

  void setIsRegistred(bool value) {
    _isRegistred = value;

    notifyListeners();
  }

  String getDecision() {
    return _decision;
  }

  void setDecision(String value) {
    _decision = value;

    notifyListeners();
  }

  bool getAskWordStatus() {
    return _askWordStatus;
  }

  void setAskWordStatus(bool value) {
    _askWordStatus = value;

    notifyListeners();
  }

  bool getIsDocumentsChecked() {
    return _isDocumentsChecked;
  }

  void setIsDocumentsChecked(bool isChecked) {
    _isDocumentsChecked = isChecked;
  }

  bool getIsDocumentsDownloaded() {
    return _isDocumentsDownloaded;
  }

  void setIsDocumentsDownloaded(bool isDownloaded) {
    _isDocumentsDownloaded = isDownloaded;
  }

  bool getIsLoadingInProgress() {
    return _isLoadingInProgress;
  }

  void setIsLoadingInProgress(bool isInProgress) {
    _isLoadingInProgress = isInProgress;
  }

  void setIntervals(List<ais.Interval> intervals) {
    _intervals = intervals;
  }

  List<ais.Interval> getIntervals() {
    return _intervals;
  }

  void setSelectedInterval(ais.Interval selectedInterval) {
    _selectedInterval = selectedInterval;

    if (selectedInterval != null) {
      setAutoEnd(selectedInterval.isAutoEnd);
    }

    notifyListeners();
  }

  ais.Interval getSelectedInterval() {
    return _selectedInterval;
  }

  void setAutoEnd(bool autoEnd) {
    _autoEnd = autoEnd;
    notifyListeners();
  }

  bool getAutoEnd() {
    return _autoEnd;
  }
}