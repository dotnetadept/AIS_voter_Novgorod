import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:global_configuration/global_configuration.dart';

import 'AppState.dart';
import 'CardState.dart';

class WebSocketConnection with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;
  static WebSocket _webSocket;
  static int _websocketState;
  WebSocketChannel _channel;
  String _clientType = '';
  SystemState _previousSystemState;

  bool _isOnline = false;
  bool _isManualLogin = false;
  static bool _isConnectStarted = false;
  bool _isDataLoadStarted = false;

  static Timer _votingResultNavigationTimer;

  static void Function() onConnect;
  static void Function(String) onFail;

  static WebSocketConnection _singleton;

  static WebSocketConnection getInstance() {
    return _singleton;
  }

  void setIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  bool get getIsOnline => _isOnline;
  bool get getIsManualLogin => _isManualLogin;

  void setPrevSystemState(SystemState previousSystemState) {
    _previousSystemState = previousSystemState;
    notifyListeners();
  }

  SystemState get getPrevSystemState => _previousSystemState;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = WebSocketConnection(navigatorKey: navigatorKey);
  }

  static Future<void> connect() async {
    if (!_isConnectStarted) {
      await _singleton.initNewChannel('unknown_client');
    }
  }

  void onUserExit() {
    _previousSystemState = null;

    AppState().setCurrentUser(null);
    AppState().setCurrentQuestion(null);
    AppState().setCurrentDocument(null);

    AppState().setDecision('');
    AppState().setIsRegistred(false);
    AppState().setAskWordStatus(false);

    AppState().setAgendaDocument(null);
    AppState().setCurrentPage('');
    AppState().setAgendaScrollPosition(0.0);

    updateClientType('unknown_client', null);
  }

  String getClientType() {
    return _clientType;
  }

  void setClientType(String value) {
    _clientType = value;
  }

  void setState(String responce) async {
    var registredMessage = json
        .encode(<String, String>{'registration': 'ЗАРЕГИСТРИРОВАН'}).toString();
    var unregistredMessage = json.encode(
        <String, String>{'registration': 'НЕЗАРЕГИСТРИРОВАН'}).toString();
    var votingPositiveMessage =
        json.encode(<String, String>{'voting': 'ЗА'}).toString();
    var votingNegativeMessage =
        json.encode(<String, String>{'voting': 'ПРОТИВ'}).toString();
    var votingIndifferentMessage =
        json.encode(<String, String>{'voting': 'ВОЗДЕРЖАЛСЯ'}).toString();
    var votingUndoMessage =
        json.encode(<String, String>{'voting': 'СБРОС'}).toString();
    var downloadMessage =
        json.encode(<String, String>{'documents': 'ЗАГРУЗИТЬ'}).toString();
    var documentsNotLoadedMessage =
        json.encode(<String, String>{'documents': 'НЕЗАГРУЖЕНЫ'}).toString();
    var askWordYesMessage = json
        .encode(<String, String>{'askWordStatus': 'ПРОШУ СЛОВА'}).toString();
    var askWordNoMessage = json.encode(
        <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'}).toString();
    var flushNavigationMessage =
        json.encode(<String, String>{'flush_navigation': 'true'}).toString();

    if (responce == registredMessage) {
      AppState().setIsRegistred(true);
    } else if (responce == unregistredMessage) {
      AppState().setIsRegistred(false);
    } else if (responce == votingPositiveMessage) {
      AppState().setDecision('ЗА');
    } else if (responce == votingNegativeMessage) {
      AppState().setDecision('ПРОТИВ');
    } else if (responce == votingIndifferentMessage) {
      AppState().setDecision('ВОЗДЕРЖАЛСЯ');
    } else if (responce == votingUndoMessage) {
      AppState().setDecision('СБРОС');
    } else if (responce == askWordYesMessage) {
      AppState().setAskWordStatus(true);
    } else if (responce == askWordNoMessage) {
      AppState().setAskWordStatus(false);
    } else if (responce == documentsNotLoadedMessage) {
      AppState().setIsDocumentsDownloaded(false);
    } else if (responce == flushNavigationMessage) {
      if (AppState().canUserNavigate()) {
        AppState().setAgendaDocument(null);
        AppState().setCurrentDocument(null);
        AppState().setCurrentQuestion(
            AppState().getCurrentMeeting().agenda.questions.first);

        WebSocketConnection.getInstance().navigateToPage('/viewAgenda');
      }
    } else if (responce == downloadMessage) {
      try {
        AppState().setIsLoadingInProgress(true);
        sendTerminalMessage('ИДЕТ_ЗАГРУЗКА');

        // remove current documents directory if it not contains current agenda directory
        // so previous files should be cleared
        if (await Directory('documents/').exists() &&
            !(await Directory(
                    'documents/' + AppState().getCurrentMeeting().agenda.folder)
                .exists())) {
          await Directory('documents/').delete(recursive: true);
        }

        // load file versions data
        var versionFilePath = 'documents/' +
            AppState().getCurrentMeeting().agenda.folder +
            '/version.txt';
        var versionsFile = File(versionFilePath);
        Map<String, dynamic> filesVersions = Map<String, dynamic>();
        if (await versionsFile.exists()) {
          filesVersions = jsonDecode(await versionsFile.readAsString());
        }

        for (Question question
            in AppState().getCurrentMeeting().agenda.questions) {
          for (QuestionFile file in question.files) {
            var fileUrl =
                ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                    '/files/' +
                    file.relativePath +
                    '/' +
                    file.fileName;
            var filePath =
                'documents/' + file.relativePath + '/' + file.fileName;
            // check inner file version to decide download or not
            if (filesVersions[filePath] != file.version) {
              await downloadFile(
                  fileUrl, file.fileName, 'documents/' + file.relativePath);

              filesVersions.removeWhere((key, value) => key == filePath);
              filesVersions.putIfAbsent(filePath, () => file.version);
            }
          }
        }

        await updateFilesVersions(json.encode(filesVersions));

        AppState().setIsLoadingInProgress(false);
        AppState().setIsDocumentsChecked(false);
        //AppState().setIsDocumentsDownloaded(true);
        sendTerminalMessage('ЗАГРУЖЕНЫ');
      } catch (exc) {
        AppState().setIsLoadingInProgress(false);
        AppState().setIsDocumentsDownloaded(false);
        sendTerminalMessage('НЕЗАГРУЖЕНЫ');
        sendTerminalMessage('ОШИБКА_ЗАГРУЗКИ:${exc.toString()}');
      }
    } else if (json.decode(responce)['update_agenda'] != null) {
      var decodedAgenda =
          Agenda.fromJson(json.decode(json.decode(responce)['update_agenda']));
      AppState().getCurrentMeeting().agenda.questions = decodedAgenda.questions;

      AppState().setIsDocumentsChecked(false);
      AppState().setAgendaDocument(new QuestionFile());
      AppState().setCurrentDocument(null);
      AppState().setCurrentQuestion(null);
      AppState().setAgendaScrollPosition(0.0);

      if (_clientType != 'manager') {
        navigateToPage('/viewAgenda');
      }
    } else if (json.decode(responce)['setUser'] != null) {
      int deputyId = int.parse(json.decode(responce)['setUser']);
      AppState().setCurrentUser(AppState()
          .getUsers()
          .firstWhere((element) => element.id == deputyId));
      updateClientType(
          AppState().isCurrentUserManager() ? 'manager' : 'deputy', deputyId);
      if (AppState().getServerState().isRegistrationCompleted) {
        sendMessage('ЗАРЕГИСТРИРОВАТЬСЯ');
      }
    } else if (json.decode(responce)['setUserExit'] != null) {
      onUserExit();
    } else {
      AppState().setServerState(ServerState.fromJson(json.decode(responce)));

      // update Meeting
      var meetingId =
          json.decode(AppState().getServerState()?.params)['selectedMeeting'];

      if (AppState().getCurrentMeeting()?.id != meetingId) {
        if (meetingId != null && !_isDataLoadStarted) {
          _isDataLoadStarted = true;

          // load settings from server
          await AppState().loadData(meetingId).then((value) async {
            _isDataLoadStarted = false;

            // Default user authentication
            if (GlobalConfiguration().getValue('use_auth_card') == 'true') {
              CardState.setRefresh(true);
            } else {
              User defaultUser = AppState()
                  .getCurrentMeeting()
                  .group
                  .groupUsers
                  .firstWhere(
                      (element) =>
                          AppState()
                              .getCurrentMeeting()
                              .group
                              .workplaces
                              .getTerminalIdByUserId(element.user.id) ==
                          GlobalConfiguration().getValue('terminal_id'),
                      orElse: () => null)
                  ?.user;
              if (defaultUser != null) {
                AppState().setCurrentUser(defaultUser);
                updateClientType(
                    AppState().isCurrentUserManager() ? 'manager' : 'deputy',
                    defaultUser.id);
              }
            }
          });
        }
        if (meetingId == null) {
          AppState().setCurrentMeeting(null);
        }
      }
    }

    // update users State
    if (AppState().getCurrentUser() != null &&
        AppState().getServerState() != null) {
      if (responce != votingPositiveMessage &&
          responce != votingNegativeMessage &&
          responce != votingIndifferentMessage &&
          responce != votingUndoMessage) {
        AppState().setDecision(AppState()
            .getServerState()
            .usersDecisions[AppState().getCurrentUser().id.toString()]);
      }
      if (responce != registredMessage && responce != unregistredMessage) {
        AppState().setIsRegistred(AppState()
            .getServerState()
            .usersRegistered
            .contains(AppState().getCurrentUser().id));
      }
      if (responce != askWordYesMessage && responce != askWordNoMessage) {
        AppState().setAskWordStatus(AppState()
            .getServerState()
            .usersAskSpeech
            .contains(AppState().getCurrentUser().id));
      }
    }

    processNavigation();
    checkMeetingDocumentsStatus();
    notifyListeners();
  }

  Future<void> updateFilesVersions(String data) async {
    var versionFilePath = 'documents/' +
        AppState().getCurrentMeeting().agenda.folder +
        '/version.txt';

    var versionsFile = File(versionFilePath);
    if (await versionsFile.exists()) {
      await versionsFile.delete();
    }

    versionsFile.createSync(recursive: true);
    await versionsFile.writeAsString(data);
  }

  WebSocketConnection({this.navigatorKey});

  void sendMessage(String message) {
    if (_isOnline && AppState().getCurrentUser() != null && _channel != null) {
      var connectionMessage = <String, dynamic>{
        'deputyId': AppState().getCurrentUser().id,
        'value': message,
      };
      _channel.sink.add(json.encode(connectionMessage));
    }
  }

  void sendTerminalMessage(String message) {
    if (_isOnline && _channel != null) {
      var connectionMessage = <String, dynamic>{
        'terminalId': GlobalConfiguration().getValue('terminal_id'),
        'value': message,
      };
      _channel.sink.add(json.encode(connectionMessage));
    }
  }

  void updateClientType(String clientType, int deputyId,
      {bool isManualLogin = false, bool isUseAuthCard = false}) {
    _isManualLogin = isManualLogin;

    if (WebSocketConnection.getInstance().getClientType() != clientType) {
      _previousSystemState = null;

      if (_isOnline && _channel != null) {
        var connectionMessage = <String, dynamic>{
          'clientType': clientType,
          'deputyId': deputyId,
          'isUseAuthCard': isUseAuthCard
        };
        _channel.sink.add(json.encode(connectionMessage));
        _clientType = clientType;
      }
    }
  }

  //manager functions
  void setSpeaker(String terminalID, bool isMicrophoneOn) {
    _channel.sink.add(
        json.encode({'speaker': terminalID, 'isMicrophoneOn': isMicrophoneOn}));
  }

  void setCurrentSpeaker(
      String terminalID, String type, String name, Duration timelimit) {
    _channel.sink.add(json.encode({
      'speaker': terminalID,
      'type': type,
      'name': name,
      'timelimit': timelimit.toString()
    }));
  }

  void flushStoreboard() {
    _channel.sink.add(json.encode({
      'flush_storeboard': 'true',
    }));
  }

  Future<void> initNewChannel(String clientType) async {
    _isConnectStarted = true;
    _clientType = clientType;

    if (_webSocket != null && _websocketState != WebSocket.closed) {
      await _webSocket.close();
    }

    _websocketState = WebSocket.connecting;
    await WebSocket.connect(
        ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
        headers: {
          'type': _clientType,
          'terminalId': GlobalConfiguration().getValue('terminal_id')
        }).then((value) {
      _isConnectStarted = false;
      if (value == null) {
        processConnectionLoss();
        return;
      } else {
        try {
          _webSocket = value;
          _webSocket?.pingInterval = Duration(
            seconds: int.parse(GlobalConfiguration().getValue('ping_interval')),
          );

          _channel = IOWebSocketChannel(_webSocket);

          _channel.stream.listen(
              (data) {
                processMessage(data);
              },
              onDone: processConnectionLoss,
              onError: (err) async {
                processConnectionLoss(error: err.toString());
              },
              cancelOnError: true);

          AppState().setWsChannel(_channel);
        } catch (exc) {
          _isConnectStarted = false;
          processConnectionLoss(error: exc.toString());
        }
      }
    }).onError((error, stackTrace) {
      _isConnectStarted = false;
      processConnectionLoss(error: error.toString());
    });
  }

  processConnectionLoss({String error = 'Соединение разорвано.'}) {
    print(error.toString());
    if (GlobalConfiguration().getValue('auto_reconnect') == "true") {
      reconnect();
    } else {
      if (onFail != null) {
        onFail(error);
      } else {
        setOffline();
      }
    }
  }

  setOffline() {
    var currentPage = AppState().getCurrentPage();
    setIsOnline(false);
    _clientType = '';
    _previousSystemState = null;
    AppState().setCurrentMeeting(null);

    AppState().setCurrentUser(null);
    AppState().setCurrentQuestion(null);
    AppState().setCurrentDocument(null);

    AppState().setDecision('');
    AppState().setIsRegistred(false);
    AppState().setAskWordStatus(false);
    AppState().setIsDocumentsDownloaded(false);

    AppState().setAgendaDocument(null);
    AppState().setCurrentPage('');
    AppState().setAgendaScrollPosition(0.0);

    if (!_isConnectStarted) {
      _webSocket?.close();
      _websocketState = WebSocket.closed;
    }

    if (currentPage != '/reconnect') {
      navigateToPage('/reconnect');
    } else {
      AppState().setCurrentPage('/reconnect');
    }
  }

  // reconnecting websocket
  reconnect() async {
    print('Reconnect to server ...');
    setOffline();

    if (!_isConnectStarted) {
      Timer(
          Duration(
              seconds:
                  int.parse(GlobalConfiguration().getValue('reconnect_delay'))),
          () {
        connect();
      });
    }
  }

  processMessage(data) {
    if (data.toString().endsWith('уже используется')) {
      setOffline();
      ScaffoldMessenger.of(navigatorKey.currentContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(
        SnackBar(
          content: Text(
              "В ходе подключения возникла ошибка: ид терминала ${GlobalConfiguration().getValue('terminal_id')} уже используется"),
        ),
      );
      return;
    }

    setIsOnline(true);

    if (data.toString().startsWith('Пользователь уже используется.')) {
      onUserExit();
      ScaffoldMessenger.of(navigatorKey.currentContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(
        SnackBar(
          content: Text(
              "В ходе подключения возникла ошибка: ${data.toString().replaceAll('Пользователь уже используется.', '')}"),
          duration: Duration(days: 1),
        ),
      );

      return;
    }

    if (onConnect != null) {
      onConnect();
    }

    setState(data.toString());
  }

  void navigateToPage(String page) async {
    // cancel result view timer if it exists
    _votingResultNavigationTimer?.cancel();

    if (page != '/reconnect' && page != '/login') {
      ScaffoldMessenger.of(navigatorKey.currentContext).clearSnackBars();
    }

    // executes navigation after build
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (AppState().getCurrentPage() != page) {
        // change window.canBeFocused property depending on current page
        if (page == '/viewDocument') {
          WindowToFrontPlugin.unfocus();
        } else {
          WindowToFrontPlugin.focus();
        }

        AppState().setCurrentPage(page);

        //close evince instances on navigation event
        try {
          Process.runSync('killall', <String>['evince']);
        } catch (exc) {
          print('${DateTime.now()} Navingation Evince Exception: $exc\n');
        }

        await navigatorKey.currentState
            .pushNamedAndRemoveUntil(page, (Route<dynamic> route) => false);
      }
    });
  }

  void processNavigation() {
    //Set loading screen if no state
    if (AppState().getServerState() == null) {
      navigateToPage('/loading');
      return;
    }

    // Set stub view if no current meeting
    if (AppState().getCurrentMeeting() == null) {
      if (AppState().getCurrentUser() != null) {
        onUserExit();
      }

      navigateToPage('/waiting');
      return;
    }

    // process  further navigation on systemStateChange
    if (_previousSystemState == AppState().getServerState().systemState) {
      return;
    } else {
      _previousSystemState = AppState().getServerState().systemState;
    }

    // process document check on meeting/preparation start
    if (AppState().getServerState().systemState ==
            SystemState.MeetingPreparation ||
        AppState().getServerState().systemState == SystemState.MeetingStarted) {
      AppState().setIsDocumentsChecked(false);
    }

    // meeting completed
    if (AppState().getServerState().systemState ==
        SystemState.MeetingCompleted) {
      onUserExit();
      navigateToPage('/waiting');

      return;
    }

    // unknown_client
    if (_clientType == '' || _clientType == 'unknown_client') {
      if (SystemStateHelper.isStarted(
          AppState().getServerState().systemState)) {
        if (GlobalConfiguration().getValue('use_auth_card') == 'true') {
          navigateToPage('/insertCard');
        } else {
          navigateToPage('/login');
        }
      } else {
        navigateToPage('/viewAgenda');
      }

      return;
    }

    // stream
    if (AppState().getServerState().systemState == SystemState.Stream) {
      navigateToPage('/viewStream');
      return;
    }

    // guest
    if (_clientType == 'guest') {
      navigateToPage('/viewAgenda');
      return;
    }

    // manager
    if (_clientType == 'manager') {
      // manager's autoregistration
      if (AppState().getServerState().systemState == SystemState.Registration) {
        if (AppState().getCurrentMeeting().group.isManagerAutoRegistration) {
          sendMessage('ЗАРЕГИСТРИРОВАТЬСЯ');
        }
      }

      navigateToPage('/viewGroup');
      return;
    }

    //deputy
    if (AppState().getServerState().systemState ==
        SystemState.MeetingPreparation) {
      navigateToPage('/viewAgenda');
    } else if (AppState().getServerState().systemState ==
        SystemState.Registration) {
      navigateToPage('/registration');
    } else if (AppState().getServerState().systemState ==
        SystemState.QuestionVotingComplete) {
      // show voting results on voting page
      // then swith to agenda or document page by timer
      if (AppState().getCurrentPage() == '/voting') {
        _votingResultNavigationTimer = Timer(
            Duration(
                seconds: AppState()
                    .getSettings()
                    .votingSettings
                    .defaultShowResultInterval), () {
          if (AppState().getCurrentDocument() != null) {
            navigateToPage('/viewDocument');
          } else {
            navigateToPage('/viewAgenda');
          }
        });
      } else {
        if (AppState().getCurrentDocument() != null) {
          navigateToPage('/viewDocument');
        } else {
          navigateToPage('/viewAgenda');
        }
      }
    } else if (AppState().getServerState().systemState ==
            SystemState.QuestionLocked ||
        AppState().getServerState().systemState ==
            SystemState.RegistrationComplete ||
        AppState().getServerState().systemState == SystemState.MeetingIdle ||
        AppState().getServerState().systemState == SystemState.MeetingStarted ||
        !AppState().getIsRegistred()) {
      if (AppState().getCurrentDocument() != null) {
        navigateToPage('/viewDocument');
      } else {
        navigateToPage('/viewAgenda');
      }
    } else if (AppState().getServerState().systemState ==
        SystemState.QuestionVoting) {
      navigateToPage('/voting');
    }
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    var filePath = '$dir/$fileName';
    var file = new File(filePath);

    //remove previous file if is exists
    if (await file.exists()) {
      await file.delete();
    }

    //download new file
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;

    //save on disk
    file.createSync(recursive: true);
    await file.writeAsBytes(bytes);

    return file.path;
  }

  Future<void> checkMeetingDocumentsStatus() async {
    var currentMeeting = AppState().getCurrentMeeting();

    if (currentMeeting != null && AppState().getIsDocumentsChecked() == false) {
      AppState().setIsDocumentsChecked(true);

      var versionsFile =
          new File('documents/${currentMeeting.agenda.folder}/version.txt');

      if (await versionsFile.exists()) {
        Map<String, dynamic> filesVersions = Map<String, dynamic>();
        filesVersions = jsonDecode(await versionsFile.readAsString());

        var isAllDocumentsLoaded = true;

        for (int q = 0; q < currentMeeting.agenda.questions.length; q++) {
          for (int f = 0;
              f < currentMeeting.agenda.questions[q].files.length;
              f++) {
            var filePath = 'documents/' +
                currentMeeting.agenda.questions[q].files[f].relativePath +
                '/' +
                currentMeeting.agenda.questions[q].files[f].fileName;
            if (filesVersions[filePath] ==
                currentMeeting.agenda.questions[q].files[f].version) {
              continue;
            } else {
              isAllDocumentsLoaded = false;
              break;
            }
          }

          if (!isAllDocumentsLoaded) {
            break;
          }
        }
        if (isAllDocumentsLoaded) {
          AppState().setIsDocumentsDownloaded(true);
          sendTerminalMessage('ЗАГРУЖЕНЫ');
          return;
        }
      }

      AppState().setIsDocumentsDownloaded(false);
      sendTerminalMessage('НЕЗАГРУЖЕНЫ');
    }
  }

  @override
  void dispose() {
    _webSocket.close();
    _websocketState = WebSocket.closed;
    // TODO: implement dispose
    super.dispose();
  }
}
