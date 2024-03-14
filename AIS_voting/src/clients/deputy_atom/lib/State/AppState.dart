import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:ntp/ntp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:synchronized/synchronized.dart';
import 'package:window_size/window_size.dart';
import 'CardState.dart';
import 'WebSocketConnection.dart';

class AppState with ChangeNotifier {
  static WebSocketChannel _channel;
  static ServerState _serverState;

  static List<User> _users;
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

  // prev card values
  static bool _prevIsCardOn = false;

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

            if (currentUser == null) {
              WebSocketConnection.getInstance().onUserExit();
            } else {
              setCurrentUser(currentUser);
              setIsRegistred(AppState()
                  .getServerState()
                  .usersRegistered
                  .contains(AppState().getCurrentUser().id));

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

    //close evince if current page is not viewDocument
    Timer.periodic(Duration(milliseconds: 250), (timer) async {
      if (AppState().getCurrentPage() != '/viewDocument') {
        try {
          // trying kill evince
          Process.runSync('killall', <String>['evince']);
        } catch (exc) {
          print('${DateTime.now()} Timer Evince Exception: $exc\n');
        }
      }
    });

    //close browser and check screenSize if current page is not streamView
    Timer.periodic(Duration(milliseconds: 250), (timer) async {
      if (AppState().getCurrentPage() != '/viewStream') {
        try {
          // trying kill chrome
          await Process.run('pkill', <String>['-f', 'chrome']);
        } catch (exc) {
          print('${DateTime.now()} Timer Chrome Exception: $exc\n');
        }

        var windowSize = await getWindowMaxSize();

        if (windowSize.height == 60) {
          setWindowFullscreenMode();
        }
      }
    });
  }

  Future<void> loadData(int meetingId) async {
    await http
        .get(Uri.parse(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                "/settings"))
        .then((response) {
          var settings = (json.decode(response.body) as List)
              .map((data) => Settings.fromJson(data))
              .toList()
              .first;
          AppState().setSettings(settings);
        })
        .then((value) => {
              NTP
                  .getNtpOffset(
                      localTime: DateTime.now(),
                      lookUpAddress:
                          GlobalConfiguration().getValue('ntp_server'))
                  .then((value) => {AppState().setTimeOffset(value)})
            })
        .then((value) => http
                .get(Uri.parse(
                    ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                        "/users"))
                .then((response) {
              var users = (json.decode(response.body) as List)
                  .map((data) => User.fromJson(data))
                  .toList();
              AppState().setUsers(users);
            }))
        .then((value) async {
          await http
              .get(Uri.parse(
                  ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                      '/meetings/$meetingId'))
              .then((response) {
            AppState().setCurrentMeeting(
                Meeting.fromJson(json.decode(response.body)));

            setIsLoadingComplete(true);
          });
        });
  }

  String getCurrentPage() {
    return _currentPage;
  }

  void setCurrentPage(String value) {
    _currentPage = value;
  }

  bool canUserNavigate() {
    // disable user navigation events if system in registration/voting state
    if (getServerState() != null &&
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

  bool isCurrentUserManager() {
    var result = false;

    if (AppState().getCurrentMeeting() != null &&
        AppState().getCurrentUser() != null) {
      result = AppState().getCurrentMeeting().group.groupUsers.any((element) =>
          element.user.id == AppState().getCurrentUser().id &&
          element.isManager);
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
}
