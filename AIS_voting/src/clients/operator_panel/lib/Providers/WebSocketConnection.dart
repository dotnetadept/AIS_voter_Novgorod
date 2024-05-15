import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:operator_panel/Providers/AppState.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:enum_to_string/enum_to_string.dart';

class WebSocketConnection with ChangeNotifier {
  static WebSocketConnection _singleton;

  static WebSocketConnection getInstance() {
    return _singleton;
  }

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = WebSocketConnection(navigatorKey: navigatorKey);
  }

  static Future<void> connect() async {
    await _singleton.initNewChannel();
  }

  var _isOnline = false;
  WebSocket _webSocket;
  WebSocketChannel _channel;
  ServerState _serverState;
  static void Function() onConnect;
  static void Function(String) onFail;
  static void Function(Agenda) updateAgendaCallback;
  static void Function(List<int>) swapQuestionsCallBack;
  static void Function(List<int>) removeQuestionsCallBack;
  static void Function(ServerState) updateServerState;
  static void Function() stopSound;
  GlobalKey<NavigatorState> navigatorKey;

  void setIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  bool get getIsOnline => _isOnline;

  WebSocketChannel get getWsChannel => _channel;

  void setWsChannel(WebSocketChannel channel) => _channel = channel;

  void setServerState(ServerState state) {
    _serverState = state;
    notifyListeners();
  }

  ServerState get getServerState => _serverState;

  WebSocketConnection({this.navigatorKey});

  Future<void> initNewChannel() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      _webSocket = await WebSocket.connect(
              ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
              headers: {'type': 'operator', 'version': packageInfo.version})
          .timeout(
        Duration(seconds: 10),
      );
      _webSocket.pingInterval = Duration(
        seconds: int.parse(GlobalConfiguration().getValue('ping_interval')),
      );

      _channel = IOWebSocketChannel(_webSocket);

      _channel.stream.listen((data) => processMessage(data),
          onDone: setOffline,
          onError: (err) => {setOffline},
          cancelOnError: true);
    } catch (exc) {
      if (onFail != null) {
        onFail(exc.toString());
        await _webSocket?.close();
      } else {
        setOffline();
      }
    }
  }

  processMessage(data) {
    setIsOnline(true);

    if (onConnect != null) {
      onConnect();
    }

    if (json.decode(data)['update_agenda'] != null) {
      if (updateAgendaCallback != null) {
        updateAgendaCallback(
            Agenda.fromJson(json.decode(json.decode(data)['update_agenda'])));
      }
    } else {
      if (updateServerState != null) {
        updateServerState(ServerState.fromJson(json.decode(data)));
      }
    }

    if (AppState().refreshDialog != null) {
      AppState().refreshDialog(() {});
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

  void setRefreshStream() {
    _channel.sink.add(json.encode({
      'refresh_stream': 'true',
    }));
  }

  void setResetAll() {
    _channel.sink.add(json.encode({
      'reset_all': 'true',
    }));
  }

  void setShutdownAll() {
    _channel.sink.add(json.encode({
      'shutdown_all': 'true',
    }));
  }

  void setFlushNavigation() {
    _channel.sink.add(json.encode({
      'flush_navigation': 'true',
    }));
  }

  void setFlushMeetingState() {
    _channel.sink.add(json.encode({
      'flush_meeting': 'true',
    }));
  }

  void setMicsMode(bool isEnabled) {
    _channel.sink.add(json.encode({'isMicsEnabled': isEnabled}));
  }

  void setMicsOff() {
    _channel.sink.add(json.encode({'setMicsOff': true}));
  }

  void closeVissonic() {
    _channel.sink.add(json.encode({'close_vissonic': true}));
  }

  void reconnectToVissonic() {
    _channel.sink.add(json.encode({'restore_vissonic': true}));
  }

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

  void setUserRegistration(int userId) {
    _channel.sink.add(json.encode({
      'userId': userId,
      'setRegistration': true,
    }));
  }

  void undoUserRegistration(int userId) {
    _channel.sink.add(json.encode({
      'userId': userId,
      'undoRegistration': true,
    }));
  }

  void setUser(String terminalId, int userId) {
    _channel.sink.add(json.encode({
      'terminalId': terminalId,
      'userId': json.encode(userId),
    }));
  }

  void setUserExit(String terminalId) {
    _channel.sink.add(json.encode({
      'terminalId': terminalId,
    }));
  }

  void setTerminalReset(String terminalId) {
    _channel.sink.add(json.encode({
      'pcId': terminalId,
      'reset': 'true',
    }));
  }

  void setTerminalShutdown(String terminalId) {
    _channel.sink.add(json.encode({
      'pcId': terminalId,
      'shutdown': 'true',
    }));
  }

  void setTerminalScreenOn(String terminalId) {
    _channel.sink.add(json.encode({
      'pcId': terminalId,
      'screen_on': 'true',
    }));
  }

  void setTerminalScreenOff(String terminalId) {
    _channel.sink.add(json.encode({
      'pcId': terminalId,
      'screen_off': 'true',
    }));
  }

  void setDetailsResult(bool isDetailsStoreboard) {
    _channel.sink.add(json.encode({
      'isDetailsStoreboard': isDetailsStoreboard,
    }));
  }

  void setMeetingPreviev(int meetingId) {
    _channel.sink.add(json.encode({
      'isMeetingPreviev': true,
      'meetingId': meetingId,
    }));
  }

  void updateAgenda(Agenda agenda) {
    _channel.sink.add(json.encode({
      'update_agenda': agenda.toJson(),
    }));
  }

  void setHistory(VotingHistory votingHistory) {
    _channel.sink.add(json.encode({
      'voting_history': votingHistory.toJson(),
    }));
  }

  void initDocumentDownload(List<String> terminals) {
    _channel.sink.add(json.encode({
      'download': json.encode(terminals),
    }));
  }

  void stopDownloadDocuments() {
    _channel.sink.add(json.encode({
      'download_stop': 'true',
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

  void setVolume(double volume) {
    _channel.sink.add(json.encode({
      'volume': volume,
    }));
  }

  void setSound(String sound, double volume) {
    _channel.sink.add(json.encode({
      'play_sound': sound,
      'volume': volume,
    }));
  }

  void setUserAskWord(int userId) {
    _channel.sink.add(json.encode({'value': 'ПРОШУ СЛОВА ДЕПУТАТ $userId'}));
  }

  void removeUserAskWord(int userId) {
    _channel.sink.add(json.encode({'value': 'ПРОШУ СЛОВА СБРОС $userId'}));
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

  setOffline() async {
    await _webSocket?.close();
    setIsOnline(false);
    stopSound();

    navigatorKey.currentState.pushNamed('/reconnect');
  }
}
