import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:deputy/Utils/utils.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:global_configuration/global_configuration.dart';

import '../Utils/stream_utils.dart';
import '../main.dart';
import 'AppState.dart';
import 'CardState.dart';

class WebSocketConnection with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;
  static WebSocket _webSocket;
  static int _websocketState;
  WebSocketChannel _channel;
  String _clientType = '';
  SystemState _previousSystemState;
  bool _previousRegistredState;

  bool _isOnline = false;
  bool _isManualLogin = false;
  static bool _isConnectStarted = false;
  bool _isDataLoadStarted = false;

  static Timer _votingResultNavigationTimer;

  static void Function() onConnect;
  static void Function(String) onFail;
  static void Function() updateAgenda;

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
    print('OnUserExit');
    _previousSystemState = null;

    AppState().setCurrentUser(null);
    AppState().setCurrentQuestion(null);
    AppState().setCurrentDocument(null);

    AppState().setDecision('');
    AppState().setIsRegistred(false);
    AppState().setAskWordStatus(false);

    AppState().setAgendaDocument(null);
    AppState().setAgendaScrollPosition(0.0);

    if (AppState().getCurrentPage() != '/viewVideo') {
      AppState().setCurrentPage('');
    }

    // check if terminal is guest
    var guest = AppState().getCurrentGuest();

    if (guest != null && guest.isNotEmpty) {
      updateClientType('guest', null, isManualLogin: true);
    } else {
      updateClientType('unknown_client', null);
    }
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
    var refreshStreamMessage =
        json.encode(<String, String>{'refresh_stream': 'true'}).toString();

    var resetMessage =
        json.encode(<String, String>{'reset': 'true'}).toString();
    var shutdownMessage =
        json.encode(<String, String>{'shutdown': 'true'}).toString();
    var screenOnMessage =
        json.encode(<String, String>{'screen_on': 'true'}).toString();
    var screenOffMessage =
        json.encode(<String, String>{'screen_off': 'true'}).toString();

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
    } else if (responce == resetMessage) {
      String bashFilePath =
          '${GlobalConfiguration().getValue('folder_path')}/data/flutter_assets/assets/shellScripts/reset.bash';
      Process.runSync(bashFilePath, []);
    } else if (responce == shutdownMessage) {
      String bashFilePath =
          '${GlobalConfiguration().getValue('folder_path')}/data/flutter_assets/assets/shellScripts/shutdown.bash';
      Process.runSync(bashFilePath, []);
    } else if (responce == screenOnMessage) {
      String bashFilePath =
          '${GlobalConfiguration().getValue('folder_path')}/data/flutter_assets/assets/shellScripts/screen_on.bash';
      Process.runSync(bashFilePath, []);
    } else if (responce == screenOffMessage) {
      String bashFilePath =
          '${GlobalConfiguration().getValue('folder_path')}/data/flutter_assets/assets/shellScripts/screen_off.bash';
      Process.runSync(bashFilePath, []);
    } else if (responce == flushNavigationMessage &&
        AppState().isCurrentUserManager() != true) {
      if (AppState().canUserNavigate()) {
        AppState().setAgendaDocument(null);
        AppState().setCurrentDocument(null);
        AppState().setCurrentQuestion(
            AppState().getCurrentMeeting().agenda.questions.first);
        AppState().setAgendaScrollPosition(0.0);

        if (AppState().getCurrentPage() == '/viewAgenda') {
          AppState().setCurrentPage('');
        }

        WebSocketConnection.getInstance().navigateToPage('/viewAgenda');
      }
    } else if (responce == refreshStreamMessage) {
      AppState().setExitStream(false);

      if (GlobalConfiguration().getValue('show_stream_in_browser') == 'true') {
        // refresh webstream
        if (AppState().getCurrentPage() == '/viewStream') {
          await StreamUtils().closeBrowser().then((value) {
            Timer(Duration(milliseconds: 100), StreamUtils().startStream);
          });
        }
      } else {
        // refresh videostream
        AppState.refreshStream();
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
            var fileUrl = ServerConnection.getFileServerDownloadUrl(
                    AppState().getSettings()) +
                '/' +
                file.relativePath +
                '/' +
                file.fileName;
            var filePath =
                'documents/' + file.relativePath + '/' + file.fileName;
            // check inner file version to decide download or not
            if (filesVersions[filePath] != file.version) {
              if (!await downloadFile(
                  fileUrl, file.fileName, 'documents/' + file.relativePath)) {
                throw Exception('Ошибка загрузки документа $filePath.');
              }

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
        if (updateAgenda != null) {
          updateAgenda();
        }
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

      // update connectionType
      if (AppState().getCurrentUser() != null &&
          _clientType == 'manager' &&
          AppState().isCurrentUserManager() == false) {
        updateClientType(
            AppState().isCurrentUserManager() ? 'manager' : 'deputy',
            AppState().getCurrentUser().id);
      } else {
        if (AppState().getCurrentUser() != null &&
            _clientType == 'deputy' &&
            AppState().isCurrentUserManager() == true) {
          updateClientType(
              AppState().isCurrentUserManager() ? 'manager' : 'deputy',
              AppState().getCurrentUser().id);
        }
      }

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
              // auto set user
              User defaultUser = AppState()
                  .getCurrentMeeting()
                  .group
                  .getVoters()
                  .firstWhere(
                      (element) =>
                          // AppState()
                          //     .getCurrentMeeting()
                          //     .group
                          //     .workplaces
                          //     .getTerminalIdByUserId(element.user.id) ==
                          // GlobalConfiguration().getValue('terminal_id'),
                          element.user.id ==
                          AppState().getServerState().usersTerminals[
                              GlobalConfiguration().getValue('terminal_id')],
                      orElse: () => null)
                  ?.user;
              if (defaultUser != null) {
                AppState().setCurrentUser(defaultUser);
                updateClientType(
                    AppState().isCurrentUserManager() ? 'manager' : 'deputy',
                    defaultUser.id);
              } else {
                // auto set guest
                var guest = AppState().getCurrentGuest();

                if (guest != null && guest.isNotEmpty) {
                  updateClientType('guest', null, isManualLogin: true);
                }
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

    if (AppState().getCurrentUser() == null &&
        AppState().getServerState() != null) {
      AppState().setAskWordStatus(AppState()
          .getServerState()
          .guestsAskSpeech
          .contains(GlobalConfiguration().getValue('terminal_id')));
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
    if (_isOnline && _channel != null) {
      if (AppState().getCurrentUser() != null) {
        var connectionMessage = <String, dynamic>{
          'deputyId': AppState().getCurrentUser().id,
          'value': message,
        };
        _channel.sink.add(json.encode(connectionMessage));
      } else {
        var connectionMessage = <String, dynamic>{
          'value': message,
        };
        _channel.sink.add(json.encode(connectionMessage));
      }
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
      SpeakerSession speakerSession, Signal startSignal, Signal endSignal) {
    _channel.sink.add(json.encode({
      'speakerSession': json.encode(speakerSession.toJson()),
      'startSignal': json.encode(startSignal?.toJson()),
      'endSignal': json.encode(endSignal?.toJson()),
      'autoEnd': AppState().getAutoEnd(),
    }));
  }

  void setStoreboardText(String caption, String text) {
    _channel.sink.add(json.encode({
      'setStoreboardCaption': caption,
      'setStoreboardText': text,
    }));
  }

  void setStoreboardTemplate(StoreboardTemplate template) {
    _channel.sink.add(json.encode({
      'storeboard_template': template.toJson(),
    }));
  }

  void setMeetingCompleted(bool isMeetingCompleted) {
    _channel.sink.add(json.encode({
      'isMeetingCompleted': json.encode(isMeetingCompleted),
    }));
  }

  void setFlushNavigation() {
    _channel.sink.add(json.encode({
      'flush_navigation': 'true',
    }));
  }

  void flushStoreboard() {
    _channel.sink.add(json.encode({
      'flush_storeboard': 'true',
    }));
  }

  void setGuest(String guest, String terminalId) {
    _channel.sink.add(json.encode({
      'guest': guest,
      'guestTerminalId': terminalId,
    }));
  }

  void removeGuest(String guest) {
    _channel.sink.add(json.encode({
      'remove_guest': guest,
    }));
  }

  void setGuestAskWord(String guest) {
    _channel.sink.add(json.encode({
      'guest_set_askword': guest,
    }));
  }

  void removeGuestAskWord(String guest) {
    _channel.sink.add(json.encode({
      'guest_remove_askword': guest,
    }));
  }

  void onFlushStoreboard() {
    var _lockedQuestion =
        json.decode(AppState().getServerState().params)['selectedQuestion'];
    if (_lockedQuestion != null) {
      _singleton.setSystemStatus(
          SystemState.QuestionLocked,
          json.encode({
            'question_id': _lockedQuestion.id,
          }));
    } else if (AppState().getCurrentMeeting() != null) {
      _singleton.setStoreboardStatus(StoreboardState.None, null);
    }
  }

  void setSystemStatus(SystemState systemState, String params) {
    _channel.sink.add(json.encode({
      'systemState': EnumToString.convertToString(systemState),
      'params': params,
    }));
  }

  void setStoreboardStatus(
      StoreboardState storeboardState, String storeboardParams) {
    _channel.sink.add(json.encode({
      'storeboardState': EnumToString.convertToString(storeboardState),
      'storeboardParams': storeboardParams,
    }));
  }

  void setBreak(DateTime breakTime) {
    _channel.sink.add(json.encode({
      'breakTime': json.encode(breakTime.toString()),
    }));
  }

  void reconnectToVissonic() {
    _channel.sink.add(json.encode({'restore_vissonic': true}));
  }

  void setMicsMode(bool isEnabled) {
    _channel.sink.add(json.encode({'isMicsEnabled': isEnabled}));
  }

  Future<void> initNewChannel(String clientType) async {
    _isConnectStarted = true;
    print('on init new channel');
    _clientType = clientType;

    if (_webSocket != null && _websocketState != WebSocket.closed) {
      await _webSocket.close();
    }

    _websocketState = WebSocket.connecting;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    await WebSocket.connect(
        ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
        headers: {
          'type': _clientType,
          'version': packageInfo.version,
          'terminalId': GlobalConfiguration().getValue('terminal_id')
        }).then((value) {
      print('on init complete');
      _isConnectStarted = false;
      if (value == null) {
        processConnectionLoss();
        return;
      } else {
        try {
          _webSocket = value;
          _webSocket?.pingInterval = Duration(
            milliseconds:
                int.parse(GlobalConfiguration().getValue('ping_interval')),
          );

          _channel = IOWebSocketChannel(_webSocket);

          _channel.stream.listen((data) {
            processMessage(data);
          }, onDone: () {
            processConnectionLoss();
          }, onError: (err) async {
            processConnectionLoss(error: err.toString());
          }, cancelOnError: true);

          AppState().setWsChannel(_channel);
        } catch (exc) {
          print('on catch');
          _isConnectStarted = false;
          processConnectionLoss(error: exc.toString());
        }
      }
    }).onError((error, stackTrace) {
      print('on error');
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
  reconnect() {
    print('Reconnect to server ...');

    if (!(AppState().getCurrentPage() == '/viewStream' ||
        AppState().getCurrentPage() == '/viewVideo')) {
      setOffline();
    } else {
      AppState().setCurrentUser(null);
    }

    if (!_isConnectStarted) {
      Timer(
          Duration(
              milliseconds:
                  int.parse(GlobalConfiguration().getValue('reconnect_delay'))),
          () {
        print('on recconect');
        connect();
      });
    }
  }

  processMessage(data) {
    if (data.toString().endsWith('уже используется')) {
      setOffline();
      rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
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
      rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
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
      rootScaffoldMessengerKey.currentState?.clearSnackBars();
    }

    // executes navigation after buildif

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (AppState().getCurrentPage() != page) {
        // exits browser and restores app window after viewStream page
        if (AppState().getCurrentPage() == '/viewStream' &&
            page != '/viewStream') {
          await StreamUtils().closeBrowser();
          await windowManager.setFullScreen(true);
        }

        // change window.canBeFocused property depending on current page
        if (page == '/viewDocument') {
          WindowToFrontPlugin.unfocus();
        } else {
          WindowToFrontPlugin.focus();
        }

        // updateCurrentPage
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
    if (!AppState().getIsLoadingComplete() ||
        AppState().getServerState() == null) {
      navigateToPage('/loading');
      return;
    }

    // stream
    if (AppState().getServerState().isStreamStarted == true &&
        !AppState().getExitStream()) {
      if (!AppState().isCurrentUserManager() || Utils().showToManager()) {
        if (GlobalConfiguration().getValue('show_stream_in_browser') ==
            'true') {
          if (AppState().getCurrentPage() != '/viewStream') {
            navigateToPage('/viewStream');
          }
        } else {
          if (AppState().getCurrentPage() != '/viewVideo') {
            navigateToPage('/viewVideo');
          }
        }
      }

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

    // process further navigation on systemStateChange
    if (_previousSystemState == AppState().getServerState().systemState &&
        _previousRegistredState == AppState().getIsRegistred() &&
        AppState().getCurrentPage() != '/viewVideo' &&
        AppState().getCurrentPage() != '/viewStream') {
      return;
    } else {
      _previousSystemState = AppState().getServerState().systemState;
      _previousRegistredState = AppState().getIsRegistred();
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

      return;
    }

    // unknown_client
    if (_clientType == '' || _clientType == 'unknown_client') {
      if (AppState().getServerState().systemState == SystemState.Registration) {
        navigateToPage('/login');
      } else if (SystemStateHelper.isStarted(
              AppState().getServerState().systemState)
          //     ||
          // SystemStateHelper.isPreparation(
          //     AppState().getServerState().systemState)
          ) {
        if (GlobalConfiguration().getValue('use_auth_card') == 'true') {
          if (GlobalConfiguration().getValue('use_manual_login') == 'true') {
            navigateToPage('/insertCard');
          } else {
            // login as quest
            updateClientType('guest', null, isManualLogin: true);
          }
        } else {
          if (GlobalConfiguration().getValue('use_manual_login') == 'true') {
            navigateToPage('/login');
          } else {
            // login as quest
            updateClientType('guest', null, isManualLogin: true);
          }
        }
      } else {
        navigateToPage('/viewAgenda');
      }

      return;
    }

    // guest
    if (_clientType == 'guest') {
      if (AppState().getServerState().systemState == SystemState.Registration) {
        navigateToPage('/login');
      } else if (AppState().getCurrentPage() != '/viewAgenda' &&
          AppState().getCurrentPage() != '/viewDocument')
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
            SystemState.MeetingPreparation &&
        !AppState().getSettings().deputySettings.showQuestionsOnPreparation) {
      navigateToPage('/waitingMeeting');
    } else if (AppState().getServerState().isRegistrationCompleted &&
        !AppState().getIsRegistred() &&
        AppState().getServerState().systemState != SystemState.Registration &&
        AppState().getSettings().deputySettings.showQuestionsForRegistred) {
      // show waitingMeeting page if deputy not registred in current meeting

      print(
          "AppState().getSettings().deputySettings.showQuestionsForRegistred");
      navigateToPage('/waitingMeeting');
    } else if (AppState().getServerState().systemState ==
        SystemState.Registration) {
      if (AppState().getCurrentMeeting().group.isDeputyAutoRegistration) {
        sendMessage('ЗАРЕГИСТРИРОВАТЬСЯ');

        if (AppState().getCurrentDocument() != null) {
          navigateToPage('/viewDocument');
        } else {
          navigateToPage('/viewAgenda');
        }
      } else {
        navigateToPage('/registration');
      }
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
        AppState().getServerState().systemState == SystemState.None ||
        AppState().getServerState().systemState == SystemState.MeetingStarted ||
        !AppState().getIsRegistred() ||
        AppState().getServerState().systemState == SystemState.AskWordQueue ||
        AppState().getServerState().systemState ==
            SystemState.AskWordQueueCompleted) {
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

  Future<bool> downloadFile(String url, String fileName, String dir) async {
    var filePath = '$dir/$fileName';
    var file = new File(filePath);

    //remove previous file if is exists
    if (await file.exists()) {
      await file.delete();
    }

    //download new file
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));

    if (req.statusCode != 200) {
      return false;
    }

    var bytes = req.bodyBytes;

    //save on disk
    file.createSync(recursive: true);
    await file.writeAsBytes(bytes);
    client.close();

    return true;
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

    super.dispose();
  }
}
