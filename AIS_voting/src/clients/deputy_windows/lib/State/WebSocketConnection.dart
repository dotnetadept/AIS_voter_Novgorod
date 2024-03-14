import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:uuid/uuid.dart';

import 'AppState.dart';

class WebSocketConnection with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;
  static WebSocket _webSocket;
  static int _websocketState;
  WebSocketChannel _channel;
  String _clientType = '';
  SystemState _previousSystemState;

  bool _isOnline = false;
  static bool _isConnectStarted = false;
  static bool _isCancelConnect = false;
  bool _isDataLoadStarted = false;

  static Timer _votingResultNavigationTimer;

  static void Function() onConnect;
  static void Function(String) onFail;

  static void Function() onShow;
  static void Function() onHide;

  static WebSocketConnection _singleton;

  static WebSocketConnection getInstance() {
    return _singleton;
  }

  void setIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  bool get getIsOnline => _isOnline;

  void setPrevSystemState(SystemState previousSystemState) {
    _previousSystemState = previousSystemState;
    notifyListeners();
  }

  SystemState get getPrevSystemState => _previousSystemState;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = WebSocketConnection(navigatorKey: navigatorKey);
  }

  static void resumeConnect() {
    _isCancelConnect = false;
  }

  static void cancelConnect() async {
    _isCancelConnect = true;
  }

  static Future<void> connect() async {
    if (!_isConnectStarted && !_isCancelConnect) {
      await _singleton.initNewChannel('unknown_client');
    }
  }

  void onUserExit() {
    _previousSystemState = null;

    AppState().setCurrentUser(null);
    AppState().setDecision('');
    AppState().setIsRegistred(false);
    AppState().setAskWordStatus(false);

    AppState().setCurrentPage('');
    AppState().setTerminalId(Uuid().v4());

    updateClientType('unknown_client', null, AppState().getTerminalId());
  }

  Future<void> onLogin(String password) async {
    ScaffoldMessenger.of(navigatorKey.currentContext).clearSnackBars();

    var user = AppState().getUsers().firstWhere(
        (element) =>
            AppState()
                .getCurrentMeeting()
                .group
                .groupUsers
                .any((gu) => gu.user.id == element.id) &&
            element.password == password,
        orElse: () => null);

    if (user != null) {
      AppState().setSavedPassword(password);
      AppState().setCurrentUser(user);
      var terminalId = AppState()
          .getCurrentMeeting()
          .group
          .workplaces
          .getTerminalIdByUserId(user.id);

      if (terminalId == null || terminalId.isEmpty) {
        ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(
          SnackBar(
            content:
                Text("Депутат не учавствует в заседании соединение невожможно"),
            duration: Duration(days: 1),
          ),
        );
      } else {
        updateClientType('deputy', user.id, terminalId);
      }
    } else {
      ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(
        SnackBar(
          content: Text("Неверно введен пароль"),
          duration: Duration(days: 1),
        ),
      );
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
    var askWordYesMessage = json
        .encode(<String, String>{'askWordStatus': 'ПРОШУ СЛОВА'}).toString();
    var askWordNoMessage = json.encode(
        <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'}).toString();

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
    } else if (responce == downloadMessage) {
      sendTerminalMessage('ИДЕТ_ЗАГРУЗКА');
      sendTerminalMessage('ЗАГРУЖЕНЫ');
    } else if (json.decode(responce)['update_agenda'] != null) {
      var decodedAgenda =
          Agenda.fromJson(json.decode(json.decode(responce)['update_agenda']));
      AppState().getCurrentMeeting().agenda.questions = decodedAgenda.questions;

      navigateToPage('/viewAgenda');
    } else if (json.decode(responce)['setUser'] != null) {
      int deputyId = int.parse(json.decode(responce)['setUser']);
      var user = AppState()
          .getUsers()
          .firstWhere((element) => element.id == deputyId, orElse: () => null);
      if (user != null) {
        onLogin(user.password);

        if (AppState().getServerState().isRegistrationCompleted) {
          sendMessage('ЗАРЕГИСТРИРОВАТЬСЯ');
        }
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

            // Users autologin
            if (AppState().getSavedPassword().isNotEmpty) {
              await onLogin(AppState().getSavedPassword());
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
    notifyListeners();
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
        'terminalId': AppState().getTerminalId(),
        'value': message,
      };
      _channel.sink.add(json.encode(connectionMessage));
    }
  }

  void updateClientType(String clientType, int deputyId, String terminalId) {
    if (WebSocketConnection.getInstance().getClientType() != clientType) {
      _previousSystemState = null;

      if (_isOnline && _channel != null) {
        var connectionMessage = <String, dynamic>{
          'clientType': clientType,
          'deputyId': deputyId,
          'terminalId': terminalId,
          'isWindowsClient': true,
        };
        _channel.sink.add(json.encode(connectionMessage));
        _clientType = clientType;
         AppState().setTerminalId(terminalId);
      }
    }
  }

  void cancelCurrentConnection() {}

  Future<void> initNewChannel(String clientType) async {
    _isConnectStarted = true;
    _clientType = clientType;

    if (_webSocket != null && _websocketState != WebSocket.closed) {
      await _webSocket.close();
    }

    _websocketState = WebSocket.connecting;

    await AppState().loadPrefs();

    // init connection with random unique terminalId
    AppState().setTerminalId(Uuid().v4());

    // try {
    await WebSocket.connect(
        ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
        headers: {
          'type': _clientType,
          'terminalId': AppState().getTerminalId(),
        }).timeout(Duration(seconds: 5)).then((value) async {
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

          if (onShow != null) {
            onShow();
          }
        } catch (exc) {
          _isConnectStarted = false;
          processConnectionLoss(error: exc.toString());
        }
      }
    }).onError((error, stackTrace) {
      _isConnectStarted = false;
      processConnectionLoss(error: error.toString());
    });
    // } catch (exc) {
    //   _isConnectStarted = false;
    //   processConnectionLoss(error: exc.toString());
    // }
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
    AppState().setDecision('');
    AppState().setIsRegistred(false);
    AppState().setAskWordStatus(false);
    AppState().setCurrentPage('');

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
          () async {
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
              "В ходе подключения возникла ошибка: ид терминала ${AppState().getTerminalId()} уже используется"),
          duration: Duration(days: 1),
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
        AppState().setCurrentPage(page);
        print('${DateTime.now()} NAVIGATE_TO $page');

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

    // process further navigation on systemStateChange
    if (_previousSystemState == AppState().getServerState().systemState) {
      return;
    } else {
      _previousSystemState = AppState().getServerState().systemState;
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
      if (onShow != null) {
        onShow();
      }
      navigateToPage('/login');

      return;
    }

    // deputy
    if (AppState().getServerState().systemState ==
        SystemState.MeetingPreparation) {
      navigateToPage('/viewAgenda');
    } else if (AppState().getServerState().systemState ==
        SystemState.Registration) {
      if (onShow != null) {
        onShow();
      }
      navigateToPage('/registration');
    } else if (AppState().getServerState().systemState ==
        SystemState.QuestionVotingComplete) {
      // show voting results on voting page
      // then swith to agenda page by timer
      if (AppState().getCurrentPage() == '/voting') {
        _votingResultNavigationTimer = Timer(
            Duration(
                seconds: int.parse(
                    GlobalConfiguration().getValue('hide_after_voting'))), () {
          if (onHide != null) {
            onHide();
          }
          navigateToPage('/viewAgenda');
        });
      } else {
        navigateToPage('/viewAgenda');
      }
    } else if (AppState().getServerState().systemState ==
            SystemState.QuestionLocked ||
        AppState().getServerState().systemState ==
            SystemState.RegistrationComplete ||
        AppState().getServerState().systemState == SystemState.MeetingIdle ||
        AppState().getServerState().systemState == SystemState.MeetingStarted ||
        !AppState().getIsRegistred()) {
      navigateToPage('/viewAgenda');
    } else if (AppState().getServerState().systemState ==
        SystemState.QuestionVoting) {
      if (onShow != null) {
        onShow();
      }
      navigateToPage('/voting');
    }
  }

  @override
  void dispose() {
    _webSocket.close();
    _websocketState = WebSocket.closed;

    super.dispose();
  }
}
