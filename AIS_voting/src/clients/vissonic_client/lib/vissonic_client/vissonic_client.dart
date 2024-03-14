import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:vissonic_client/app_settings.dart';
import '../server_state.dart';
import 'terminal_mic.dart';
import 'vissonic_command.dart';
import 'vissonic_basic_command.dart';
import 'vissonic_command_helper.dart';
import 'package:synchronized/synchronized.dart';

// AIS server vissonic client
class VissonicClient {
  final String _address;
  final int _port;
  final int _timeout;
  final void Function() _setIsSendState;

  String _lastMessage = '';
  String _lastResponce = '';
  DateTime _lastResponceTimeStamp = DateTime.now();

  Lock _lock = Lock();
  Socket? _socket;
  final List<VissonicCommand> _sendQueue = <VissonicCommand>[];
  Timer? _sendQueueTimer;
  bool? _isMicsEnabledOnStart;

  VissonicClient(
      this._address, this._port, this._timeout, this._setIsSendState);

  Future<void> connect(bool isMicsEnabledOnStart) async {
    _isMicsEnabledOnStart = isMicsEnabledOnStart;

    if (_socket != null) {
      await _socket?.close();
      _socket?.destroy();
    }

    await Future.delayed(Duration(seconds: 1)).then((value) async {
      try {
        print('Устанавливается соединение с сервером Vissonic');
        await Socket.connect(_address, _port,
                timeout: Duration(seconds: _timeout))
            .then((socket) async {
          _socket = socket;
          // configure socket settings
          socket.setOption(SocketOption.tcpNoDelay, true);

          // configure socket events
          socket.listen((data) {
            _processServerMessage(data);
          }, onDone: () {
            print(
                '${DateTime.now().toString()} Соединение с сервером Vissonic завершено');

            closeConnection();
          }, onError: (err) {
            _processError(err.toString());
          }, cancelOnError: true); // break connection on first error

          ServerState.isVissonicServerOnline = true;
          ServerState.isVissonicModuleInit = false;
          _setIsSendState();

          print(
              '${DateTime.now().toString()} Сервер Vissonic подключен: ${_address}:${_port}');

          // Init vissonic session
          await _sendToServer(VissonicBasicCommand.init()).then((value) async {
            await Future.delayed(Duration(
                    milliseconds:
                        AppSettings.settings?['vissonic_keep_alive_interval']))
                .then((value) async {
              await _sendToServer(VissonicBasicCommand.keepAlive());
            });
          });

          // start vissonic message timer
          _sendQueueTimer = Timer.periodic(
              Duration(
                  milliseconds: AppSettings
                      .settings?['vissonic_message_interval']), (timer) async {
            await _lock.synchronized(_sendMessageQueueToServer);
          });
        });
      } on SocketException catch (e) {
        _processError(e.toString());

        //close on timeout
        if (e.toString().contains('Connection timed out')) {
          exit(0);
        }
      } catch (e) {
        _processError(e.toString());
      }
    });
  }

  void processInitMessage(List<int> data) {
    if (data.length < 36) {
      return;
    }

    print(
        '${DateTime.now().toString()} Начата инициализация состояния микрофонов Vissonic');

    // disable mics status
    ServerState.micsEnabled = null;
    // reverse data for better processign
    data = data.reversed.toList();

    // load waiting mics state
    for (var i = 0; i < 6; i++) {
      var micId = data[i * 2] + data[i * 2 + 1];
      if (ServerState.currentMics.any((element) => element.micId == micId)) {
        TerminalMic foundTerminalMic = ServerState.currentMics
            .firstWhere((element) => element.micId == micId);
        foundTerminalMic.setIsWaiting(true);
      }
    }
    // remove processed data
    data = data.getRange(12, data.length).toList();

    // load active mics state
    for (var i = 0; i < 8; i++) {
      var micId = data[i * 2] + data[i * 2 + 1];
      if (ServerState.currentMics.any((element) => element.micId == micId)) {
        var foundTerminalMic = ServerState.currentMics
            .firstWhere((element) => element.micId == micId);
        foundTerminalMic.setIsSound(true);
      }
    }

    // enable unblocked mics on init
    for (var i = 0; i < ServerState.currentMics.length; i++) {
      if (ServerState.currentMics[i].isUnblockedMic) {
        print('Unblocked mic enabled on init');
        processSetMicUnblocked(ServerState.currentMics[i].terminalId);
      }
    }

    // enable/disable others mics on start
    processSetAllMicsEnabledOnStart(_isMicsEnabledOnStart == true);

    ServerState.isVissonicModuleInit = true;
    _setIsSendState();

    print(
        '${DateTime.now().toString()} Завершена инициализация состояния микрофонов Vissonic');
  }

  void _processError(String errorText) {
    print(
        '${DateTime.now().toString()} В ходе подключения сервера Vissonic ${_address}:${_port} возникла шибка: ${errorText}');
    print(
        '${DateTime.now().toString()} Последнее отправленное сообщение: ${_lastMessage}');
    print(
        '${DateTime.now().toString()} Последнее принятое сообщение: ${_lastResponce} ${_lastResponceTimeStamp.toString()}');
    print(
        '${DateTime.now().toString()} Текущая очередь сообщений: ${_sendQueue}');

    closeConnection();
  }

  void closeConnection() {
    // cancel send queue timer
    _sendQueueTimer?.cancel();
    _socket?.close();
    // destroy socket
    _socket?.destroy();

    ServerState.isVissonicServerOnline = false;
    ServerState.isVissonicModuleInit = true;

    // clear mics state
    for (int i = 0; i < ServerState.currentMics.length; i++) {
      ServerState.currentMics[i].setIsEnabled(null);
      ServerState.currentMics[i].setIsSound(false);
    }

    _setIsSendState();
  }

  Future<void> _sendMessageQueueToServer() async {
    if (_sendQueue.isNotEmpty &&
        DateTime.now().difference(_lastResponceTimeStamp) >
            Duration(
                milliseconds:
                    AppSettings.settings?['vissonic_await_interval'])) {
      var firstItem = _sendQueue[0];
      _sendQueue.removeAt(0);
      await _sendToServer(firstItem);
    }
  }

  Future<void> _sendToServer(VissonicCommand command) async {
    if (ServerState.isVissonicServerOnline) {
      _socket?.add(command.getComand());
      await _socket?.flush();
    }

    _lastMessage =
        VissonicCommandHelper.formatData(command.getComand()).toString();
    print(
        '${DateTime.now().toString()} Отправлено на Vissonic сервер: ${_lastMessage}');
  }

  // inserts command at the start of queue
  void _insertToQueue(List<VissonicCommand> commands) {
    if (commands.isEmpty) {
      return;
    }

    if (ServerState.isVissonicServerOnline) {
      _sendQueue.insertAll(0, commands);
    }
  }

  // adds command to the end of queue
  void _addToQueue(List<VissonicCommand> commands) {
    if (commands.isEmpty) {
      return;
    }

    if (ServerState.isVissonicServerOnline) {
      _sendQueue.addAll(commands);
    }
  }

  // ******************************************************************
  // Process message from Vissonic Server
  // ******************************************************************
  // process all server messages from vissonic server
  void _processServerMessage(List<int> data) {
    _lastResponce = VissonicCommandHelper.formatData(data).toString();
    _lastResponceTimeStamp = DateTime.now();
    print(
        '${DateTime.now().toString()} Vissonic сервер packet: ${_lastResponce}');

    // process vissonic initialization
    if (ServerState.isVissonicModuleInit == false) {
      processInitMessage(data);
      return;
    }

    // validate vissonic message length
    if ((data.length % 5) != 0) {
      print(
          '${DateTime.now().toString()} Vissonic сервер packet incorrect lenth: ${data.length}');
      return;
    }

    for (var i = 0; i < data.length / 5; i++) {
      final serverCommand =
          Uint16List.fromList(data.sublist(i * 5, (i + 1) * 5));
      var decodedServerCommand =
          VissonicCommandHelper.formatData(serverCommand);

      // process server command
      if (decodedServerCommand[0] == 'fe' && decodedServerCommand[4] == 'fc') {
        var terminalId = int.parse(
            decodedServerCommand[2][0] + decodedServerCommand[3],
            radix: 16);
        var command = int.parse(
            decodedServerCommand[1] + decodedServerCommand[2][1],
            radix: 16);

        _processServerCommand(serverCommand, command, terminalId);

        print(
            '${DateTime.now().toString()} Vissonic сервер: ${decodedServerCommand}');
        print(
            '${DateTime.now().toString()} Vissonic сервер: ${VissonicCommandHelper.commandToString(command)} ${VissonicCommandHelper.idToString(terminalId)}');
      }
    }
  }

  // process single server command
  void _processServerCommand(
      List<int> serverCommand, int command, int terminalId) {
    // process keepAlive message
    // FE 00 0E 00 FC
    if (terminalId == 0x000 && command == 0x00e) {
      return;
    }

    // mic command section
    if (!ServerState.currentMics
        .any((element) => element.micId == terminalId)) {
      return;
    }

    var foundTerminalMic = ServerState.currentMics
        .firstWhere((element) => element.micId == terminalId);

    // mic waiting enabled
    if (command == 0x112) {
      foundTerminalMic.setIsWaiting(true);
    }
    // mic waiting disabled
    if (command == 0x113) {
      foundTerminalMic.setIsWaiting(false);
    }
    // manager clear all active mics
    if (command == 0x11B) {
      for (var i = 0; i < ServerState.currentMics.length; i++) {
        if (!ServerState.currentMics[i].isUnblockedMic) {
          ServerState.currentMics[i].setIsSound(false);
        }
      }
    }

    // mic sound enabled
    if (command == 0x110) {
      foundTerminalMic.setIsSound(true);
    }

    // mic sound disabled
    if (command == 0x111) {
      foundTerminalMic.setIsSound(false);

      // block mic if MicsDisabled mode and it is not manager
      if (ServerState.micsEnabled == false &&
          !foundTerminalMic.isUnblockedMic) {
        var commands = <VissonicCommand>[];
        var stateCommand = foundTerminalMic.processSetMicEnabled(false);
        if (stateCommand != null) {
          commands.add(stateCommand);
        }

        _insertToQueue(commands);
      }
    }

    // mic state disabled
    if (command == 0x0c2) {
      foundTerminalMic.setIsEnabled(false);
    }
    // mic state enabled
    if (command == 0x0c3) {
      foundTerminalMic.setIsEnabled(true);
    }

    // remove duplicate commands from queue
    for (var i = 0; i < _sendQueue.length; i++) {
      if (_sendQueue[i].isSame(serverCommand)) {
        print(
            'Из очереди удалена дублирующая комманда ${VissonicCommandHelper.formatData(_sendQueue[i].getComand()).toString()}');
        _sendQueue.removeAt(i);
      }
    }

    _setIsSendState();
  }

  // ******************************************************************
  // Commands to Vissonic Server
  // ******************************************************************

  // process mic state change event for all mics
  // except unblocked mics
  void processSetAllMicsEnabled(bool isEnabled) {
    var commands = <VissonicCommand>[];

    // Disable sound on waiting and active mics
    if (isEnabled == false) {
      for (var i = 0; i < ServerState.currentMics.length; i++) {
        if (ServerState.currentMics[i].getIsWaiting() &&
            !ServerState.currentMics[i].isUnblockedMic) {
          commands.addAll(ServerState.currentMics[i].processSetMicSound(false));
        }
      }
      for (var i = 0; i < ServerState.currentMics.length; i++) {
        if (ServerState.currentMics[i].getIsSound() &&
            !ServerState.currentMics[i].isUnblockedMic) {
          commands.addAll(ServerState.currentMics[i].processSetMicSound(false));
        }
      }
    }

    //set state of mics one by one
    for (var i = 0; i < ServerState.currentMics.length; i++) {
      if (!ServerState.currentMics[i].isUnblockedMic) {
        var stateCommand =
            ServerState.currentMics[i].processSetMicEnabled(isEnabled);
        if (stateCommand != null) {
          commands.add(stateCommand);
        }
      }
    }

    _addToQueue(commands);
    ServerState.micsEnabled = isEnabled;
  }

  // enables/disables not active mics on start
  // except unblocked mics
  void processSetAllMicsEnabledOnStart(bool isEnabled) {
    if (isEnabled) {
      // enable all mics
      processSetAllMicsEnabled(isEnabled);
    } else {
      // disable not active mics
      var commands = <VissonicCommand>[];

      for (var i = 0; i < ServerState.currentMics.length; i++) {
        if (ServerState.currentMics[i].isUnblockedMic ||
            ServerState.currentMics[i].getIsSound()) {
          continue;
        }

        var stateCommand =
            ServerState.currentMics[i].processSetMicEnabled(isEnabled);
        if (stateCommand != null) {
          commands.add(stateCommand);
        }
      }

      _addToQueue(commands);
    }

    ServerState.micsEnabled = isEnabled;
  }

  // process single mic sound event
  void processSetMicSound(String? terminalIds, bool isMicrophoneOn) {
    var commands = <VissonicCommand>[];

    if (terminalIds == null) {
      return;
    }

    var parts = terminalIds.split(',').toList();
    for (var i = 0; i < parts.length; i++) {
      if (ServerState.currentMics
          .any((element) => element.micId == int.parse(parts[i]))) {
        var foundTerminalMic = ServerState.currentMics
            .firstWhere((element) => element.micId == int.parse(parts[i]));
        commands.addAll(foundTerminalMic.processSetMicSound(isMicrophoneOn));
      }
    }

    _addToQueue(commands);
  }

  // enables mic and set it unblocked state
  void processSetMicUnblocked(String? terminalIds) {
    var commands = <VissonicCommand>[];

    if (terminalIds == null) {
      return;
    }

    var parts = terminalIds.split(',').toList();
    for (var i = 0; i < parts.length; i++) {
      if (ServerState.currentMics
          .any((element) => element.micId == int.parse(parts[i]))) {
        var foundTerminalMic = ServerState.currentMics
            .firstWhere((element) => element.micId == int.parse(parts[i]));

        foundTerminalMic.isUnblockedMic = true;
        var stateCommand = foundTerminalMic.processSetMicEnabled(true);
        if (stateCommand != null) {
          commands.add(stateCommand);
        }
      }
    }

    _addToQueue(commands);
  }

  // disables mic and set it blocked state
  void processSetMicBlocked(String? terminalIds) {
    var commands = <VissonicCommand>[];

    if (terminalIds == null) {
      return;
    }

    var parts = terminalIds.split(',').toList();
    for (var i = 0; i < parts.length; i++) {
      if (ServerState.currentMics
          .any((element) => element.micId == int.parse(parts[i]))) {
        var foundTerminalMic = ServerState.currentMics
            .firstWhere((element) => element.micId == int.parse(parts[i]));

        foundTerminalMic.isUnblockedMic = false;

        if (ServerState.micsEnabled == false) {
          var stateCommand = foundTerminalMic.processSetMicEnabled(false);
          if (stateCommand != null) {
            commands.add(stateCommand);
          }
        } else {
          commands.addAll(foundTerminalMic.processSetMicSound(false));
        }
      }
    }

    _addToQueue(commands);
  }
}
