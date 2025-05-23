import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:window_manager/window_manager.dart';
import '../Utils/stream_utils.dart';
import 'AppState.dart';

class WebSocketConnection with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;
  static WebSocket? _webSocket;
  late WebSocketChannel _channel;

  bool _isOnline = false;
  static bool _isConnectStarted = false;

  static void Function(ServerState)? updateServerState;
  static void Function()? stopSound;

  static late WebSocketConnection _singleton;

  static WebSocketConnection getInstance() {
    return _singleton;
  }

  void setIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  bool get getIsOnline => _isOnline;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = WebSocketConnection(navigatorKey: navigatorKey);
  }

  static Future<void> connect() async {
    if (!_isConnectStarted) {
      _singleton.initNewChannel('storeboard');
    }
  }

  void setState(String responce) async {
    AppState().setIsOnline(true);

    var refreshStreamMessage =
        json.encode(<String, String>{'refresh_stream': 'true'}).toString();
    if (responce == refreshStreamMessage) {
      if (AppState().getCurrentPage() == '/viewStream') {
        await StreamUtils().closeBrowser().then((value) async {
          Timer(Duration(milliseconds: 100), StreamUtils().startStream);
        });
      }
      if (AppState().getCurrentPage() == '/viewVideo') {
        if (AppState.refreshStream != null) {
          await AppState.refreshStream!();
        }
      }
    } else if (json.decode(responce)['update_agenda'] != null) {
      var decodedAgenda =
          Agenda.fromJson(json.decode(json.decode(responce)['update_agenda']));

      if (AppState().getCurrentMeeting() != null) {
        AppState().getCurrentMeeting()!.agenda!.questions =
            decodedAgenda.questions;
      }
    } else {
      var serverState = ServerState.fromJson(json.decode(responce));
      AppState().setServerState(serverState);
      var meetingId = json.decode(serverState.params)['selectedMeeting'];
      var questionId = json.decode(serverState.params)['selectedQuestion'];

      if (AppState().getCurrentMeeting()?.id != meetingId ||
          AppState().getSettings() == null) {
        await AppState().loadData(meetingId, questionId);
      } else {
        if (AppState().getCurrentMeeting() != null) {
          AppState().setCurrentQuestion(AppState()
              .getCurrentMeeting()!
              .agenda!
              .questions
              .firstWhereOrNull((element) => element.id == questionId));
        }
      }

      if (updateServerState != null) {
        updateServerState!(serverState);
      }
    }

    await processNavigation();
    notifyListeners();
  }

  WebSocketConnection({required this.navigatorKey});

  /// Creates new instance of IOWebSocketChannel and initializes socket listening
  Future<void> initNewChannel(String clientType) async {
    try {
      _webSocket?.close();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _webSocket = await WebSocket.connect(
          ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
          headers: {
            'type': clientType,
            'version': packageInfo.version,
          }).timeout(
        Duration(seconds: 10),
      );
      _webSocket!.pingInterval = Duration(
        seconds: int.parse(GlobalConfiguration().getValue('ping_interval')),
      );

      _channel = IOWebSocketChannel(_webSocket!);

      _channel.stream.listen((data) => setState(data),
          onDone: reconnect, onError: wserror, cancelOnError: true);
    } catch (exc) {
      reconnect();
    }
  }

  wserror(err) async {
    print('WebSocket error:${err.toString()}');
    await reconnect();
  }

  setOffline() {
    setIsOnline(false);
    stopSound!();

    AppState().setCurrentMeeting(null);
    AppState().setCurrentQuestion(null);
    AppState().setCurrentPage('');

    if (!_isConnectStarted) {
      _webSocket?.close();
    }
  }

  // reconnecting websocket
  reconnect() async {
    print('Reconnect to server ...');
    setOffline();

    // add in a reconnect delay
    await Future.delayed(Duration(seconds: 1));

    initNewChannel('storeboard');
  }

  Future<void> navigateToPage(String page) async {
    if (AppState().getCurrentPage() == '/viewStream' && page != '/viewStream') {
      await StreamUtils().closeBrowser();
      await windowManager.setFullScreen(true);
    }

    // executes navigation after build
    //SchedulerBinding.instance.addPostFrameCallback((_) async {
    if (AppState().getCurrentPage() != page) {
      AppState().setCurrentPage(page);
      await navigatorKey.currentState
          ?.pushNamedAndRemoveUntil(page, (Route<dynamic> route) => false);
    }
    //});
  }

  Future<void> processNavigation() async {
    if (AppState().getServerState().isStreamStarted == true &&
        GlobalConfiguration().getValue('show_stream') == 'true') {
      if (GlobalConfiguration().getValue('show_stream_in_browser') == 'true') {
        await navigateToPage('/viewStream');
      } else {
        await navigateToPage('/viewVideo');
      }
    } else {
      await navigateToPage('/storeboard');
    }
  }

  @override
  void dispose() {
    _webSocket?.close();

    super.dispose();
  }
}
