import 'dart:convert';
import 'dart:io';

import 'package:vissonic_client/app_settings.dart';
import 'package:vissonic_client/server_state.dart';
import 'package:vissonic_client/vissonic_client/vissonic_client.dart';

void main(List<String> arguments) async {
  print('Запуск Vissonic клиента системы АИС Голосование');

  await File(
          '/home/user/ais_voter/ais_server/ais_vissonic_client/app_settings.json')
      .readAsString()
      .then((value) {
    AppSettings.settings = jsonDecode(value);
  }).then((value) {
    print('Чтение файла настроек успешно завершено');

    ConsoleApp();
  });
}

class ConsoleApp {
  bool _isOnline = false;
  WebSocket? _webSocket;
  VissonicClient? _vissonicClient;

  ConsoleApp() {
    initNewChannel();
  }

  /// Creates new instance of IOWebSocketChannel and initializes socket listening
  void initNewChannel() async {
    try {
      await _webSocket?.close();

      _webSocket = await WebSocket.connect(
          'ws://${AppSettings.settings?['server']}:${AppSettings.settings?['ws_port']}',
          headers: {'type': 'vissonic_client'}).timeout(
        Duration(seconds: AppSettings.settings?['ais_server_timeout_sec']),
      );

      _webSocket?.listen((data) async {
        await processMessage(data.toString());
      }, onDone: reconnect, onError: wserror, cancelOnError: true);

      print('Подключение к серверу АИС Голосование успешно завершено');

      _vissonicClient = VissonicClient(
          AppSettings.settings?['vissonic_server'],
          AppSettings.settings?['vissonic_port'],
          AppSettings.settings?['vissonic_server_timeout_sec'],
          sendStateToAIS);
    } catch (exc) {
      await reconnect();
    }
  }

  // reconnecting websocket
  reconnect() async {
    print('Идет подключение к серверу АИС Голосование ...');
    _isOnline = false;

    // add in a reconnect delay
    await Future.delayed(Duration(seconds: 1));

    initNewChannel();
  }

  wserror(err) async {
    print('WebSocket error: ${err.toString()}');
    await reconnect();
  }

  Future<void> processMessage(String responce) async {
    _isOnline = true;

    var decodedResponce = json.decode(responce);

    if (responce.contains('command')) {
      if (decodedResponce['command'] == 'connect') {
        await _vissonicClient?.connect(decodedResponce['isEnabled']);
      }
      if (decodedResponce['command'] == 'setMicSound') {
        _vissonicClient?.processSetMicSound(
            decodedResponce['terminalId'], decodedResponce['isEnabled']);
      } else if (decodedResponce['command'] == 'setAllState') {
        _vissonicClient?.processSetAllMicsEnabled(decodedResponce['isEnabled']);
      } else if (decodedResponce['command'] == 'unblockMic') {
        _vissonicClient?.processSetMicUnblocked(decodedResponce['terminalId']);
      } else if (decodedResponce['command'] == 'blockMic') {
        _vissonicClient?.processSetMicBlocked(decodedResponce['terminalId']);
      }
    } else {
      ServerState.micsFromJson(json.decode(responce));
    }
  }

  void sendStateToAIS() {
    if (_isOnline && _webSocket != null) {
      _webSocket?.add(json.encode(ServerState().toJson()));
    }
  }
}
