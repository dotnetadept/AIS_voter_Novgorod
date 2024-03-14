import 'dart:io' as io;
import 'dart:convert' show json;
import 'dart:async';
import 'dart:io';

import 'package:ntp/ntp.dart';
import 'package:ais_model/ais_model.dart' as cm;
//import 'package:process_run/shell_run.dart';
import 'package:services/web_socket/vissonic_client/terminal_mic.dart';
import 'package:uuid/uuid.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:pedantic/pedantic.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:path/path.dart' as p;

import '../models/ais_model.dart';
import 'common_utils.dart';
import 'ws_connection.dart';
import 'server_state.dart';
import '../settings.dart';
import 'package:ais_model/ais_model.dart' show Workplaces;

class WebSocketServer {
  final int _port;
  final String _address;
  final ManagedContext _context;

  final List<WSConnection> _connections = <WSConnection>[];
  List<io.HttpRequest> _connectionQueue;

  int _interval;
  int _timeOffset;

  bool _isSendState = false;
  void setIsSendState() {
    _isSendState = true;
  }

  WebSocketServer(this._address, this._port, this._context);

  void load() async {
    var stopwatch = Stopwatch();

    print(
        '${DateTime.now().toString()} Начата инициализация веб сервера $APP_NAME');

    print('${DateTime.now().toString()} Начата синхронизация времени');
    _timeOffset = await NTP.getNtpOffset(
        localTime: DateTime.now(), lookUpAddress: NTP_SERVER);
    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Синхронизация времени завершена');

    _connectionQueue = <io.HttpRequest>[];

    //main timer
    Timer.periodic(Duration(milliseconds: STATE_INTERVAL), (v) async {
      if (ServerState != null && _interval != null) {
        if (ServerState.systemState == cm.SystemState.QuestionVoting) {
          var secondsElapsed =
              ((CommonUtils.getDateTimeNow(_timeOffset).millisecondsSinceEpoch -
                          ServerState.selectedQuestionSession.startDate
                              .millisecondsSinceEpoch) /
                      1000)
                  .round();
          if (secondsElapsed > _interval) {
            await completeVoting(ServerState.selectedQuestion);
            _isSendState = true;
          }
        }
        if (ServerState.systemState == cm.SystemState.Registration) {
          var secondsElapsed =
              ((CommonUtils.getDateTimeNow(_timeOffset).millisecondsSinceEpoch -
                          ServerState.registrationSession.startDate
                              .millisecondsSinceEpoch) /
                      1000)
                  .round();
          if (secondsElapsed > _interval) {
            await completeRegistration();
            _isSendState = true;
          }
        }
      }

      // send ServerState to all connected clients
      if (_isSendState) {
        stopwatch.start();

        sendStateTo(_connections);
        _isSendState = false;

        stopwatch.stop();
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Состояние отправлено ${stopwatch.elapsedMicroseconds} мкс.');
        stopwatch.reset();
      }
    });

    //connections queue
    Timer.periodic(Duration(milliseconds: CONNECTION_INTERVAL), (v) async {
      if (_connectionQueue.isNotEmpty) {
        var firstItem = _connectionQueue.first;

        // remove other requests from same terminalId
        _connectionQueue.removeWhere((element) =>
            element.headers.value('terminalId') ==
            firstItem.headers.value('terminalId'));

        upgradeHttpRequest(firstItem);
      }
    });

    //files upload timer
    Timer.periodic(Duration(milliseconds: FILE_SENT_INTERVAL), (v) async {
      // process documentDownload
      if (ServerState.terminalsForDownload.isNotEmpty) {
        //add new client to download queue
        if (ServerState.terminalsLoadingDocuments.length <
            FILE_SENT_QUEUE_SIZE) {
          var freeDownloadSlots = FILE_SENT_QUEUE_SIZE -
              ServerState.terminalsLoadingDocuments.length;

          for (var i = 0; i < freeDownloadSlots; i++) {
            if (i >= ServerState.terminalsForDownload.length) {
              break;
            }
            // set new client for download
            var connection = _connections.firstWhere(
                (element) =>
                    element.terminalId == ServerState.terminalsForDownload[i],
                orElse: () => null);
            if (connection != null) {
              sendMessage(
                  connection, <String, String>{'documents': 'ЗАГРУЗИТЬ'});
            }
          }
        }
      } else {
        //loading completed
        if (ServerState.isLoadingDocuments) {
          ServerState.isLoadingDocuments = false;
          _isSendState = true;
        }
      }
    });

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Чтение базы данных...');

    var meetings = await getAllMeetings();

    // find startedMeeting
    final queryMeetingSessions = Query<MeetingSession>(_context);
    var meetingSessions = await queryMeetingSessions.fetch();

    var startedMeetingSession = meetingSessions
        .firstWhere((element) => element.endDate == null, orElse: () => null);

    var startedMeeting = meetings.firstWhere(
        (element) => element.id == startedMeetingSession?.meetingId,
        orElse: () => null);

    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    // end previous registration session
    var updateRegistationSession = Query<RegistrationSession>(_context)
      ..values.endDate = lastUpdated
      ..where((u) => u.endDate).isNull();
    await updateRegistationSession.update();

    // end previous voting session
    QuestionSession updatedQuestionSession;
    var updateQuestionSession = Query<QuestionSession>(_context)
      ..values.usersCountVoted = 0
      ..values.usersCountVotedYes = 0
      ..values.usersCountVotedNo = 0
      ..values.usersCountVotedIndiffirent = 0
      ..values.endDate = lastUpdated
      ..where((u) => u.endDate).isNull();
    var updateQuestionSessionRequest = (await updateQuestionSession.update());
    if (updateQuestionSessionRequest.isNotEmpty) {
      updatedQuestionSession = updateQuestionSessionRequest.first;
    }

    if (startedMeeting != null) {
      if (startedMeeting.status == 'Регистрация') {
        // fix meeting status
        var query = Query<Meeting>(_context)
          ..values.status = 'Начато'
          ..values.lastUpdated = lastUpdated
          ..where((u) => u.id).equalTo(startedMeeting.id);
        await query.update();

        startedMeeting.status = 'Начато';
        startedMeeting.lastUpdated = lastUpdated;
      }
      if (startedMeeting.status.startsWith('Голосование') &&
          !startedMeeting.status.endsWith('завершено')) {
        // fix meeting status
        var query = Query<Meeting>(_context)
          ..values.status =
              startedMeeting.status.replaceFirst('Голосование', 'Просмотр')
          ..values.lastUpdated = lastUpdated
          ..where((u) => u.id).equalTo(startedMeeting.id);
        await query.update();

        startedMeeting.status =
            startedMeeting.status.replaceFirst('Голосование', 'Просмотр');
        startedMeeting.lastUpdated = lastUpdated;
      }

      ServerState.selectedMeeting = startedMeeting;
      // load default users termnals if needed
      loadDefaultUsersTerminals();
      ServerState.selectedMeetingSession = startedMeetingSession;

      // find registration session
      if (ServerState.selectedMeeting != null &&
          ServerState.selectedMeetingSession.startDate != null) {
        final queryRegistrationSessions = Query<RegistrationSession>(_context);
        var registrationSessions = await queryRegistrationSessions.fetch();

        var registrationSession = registrationSessions.lastWhere(
            (element) =>
                element.meetingId == ServerState.selectedMeeting.id &&
                element.startDate != null &&
                element.startDate.microsecondsSinceEpoch >
                    ServerState.selectedMeetingSession.startDate
                        .microsecondsSinceEpoch,
            orElse: () => null);
        ServerState.registrationSession = registrationSession;
        if (registrationSession != null) {
          // load registred users from db
          final queryRegistrationUsers = Query<Registration>(_context);
          var registrationUsers = await queryRegistrationUsers.fetch();

          if (registrationUsers.isNotEmpty) {
            var usersRegistred = registrationUsers
                .where((element) =>
                    element.registrationSession.id == registrationSession.id)
                .toList();

            for (var i = 0; i < usersRegistred.length; i++) {
              if (!ServerState.usersRegistered
                  .contains(usersRegistred[i].userId)) {
                ServerState.usersRegistered.add(usersRegistred[i].userId);
              }
            }
          }

          ServerState.isRegistrationCompleted = true;
        }
      }

      // set system state
      if (startedMeetingSession.startDate == null) {
        ServerState.systemState = cm.SystemState.MeetingPreparation;
      } else {
        ServerState.systemState = cm.SystemState.MeetingIdle;
      }

      // find selectedQuestion
      if (startedMeeting.status.startsWith('Просмотр')) {
        Question selectedQuestion;
        if (updatedQuestionSession != null) {
          selectedQuestion = startedMeeting.agenda.questions.firstWhere(
              (element) => element.id == updatedQuestionSession.questionId,
              orElse: () => null);
        } else {
          selectedQuestion = startedMeeting.agenda.questions.firstWhere(
              (element) =>
                  startedMeeting.status ==
                  'Просмотр ${element.name} ${element.orderNum}',
              orElse: () => null);
        }
        if (selectedQuestion != null) {
          ServerState.systemState = cm.SystemState.QuestionLocked;
        }
        ServerState.selectedQuestion = selectedQuestion;
      }
    }

    // set mic sound settings
    sendVissonicMessage('setAllState', isEnabled: !getIsMicsEnabledState());

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Завершена инициализация веб сервера $APP_NAME');
  }

  void upgradeHttpRequest(io.HttpRequest request) async {
    await io.WebSocketTransformer.upgrade(request).then((io.WebSocket ws) {
      ws.pingInterval = Duration(milliseconds: CLIENT_PING_INTERVAL);
      createWSConnection(ws, request);
    },
        onError: (err) => print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} [!]Error -- ${err.toString()}'));
  }

  bool getIsMicsEnabledState() {
    return !cm.SystemStateHelper.isStarted(ServerState.systemState);
  }

  void updateServerStateMeeting(Meeting updatedMeeting) {
    ServerState.selectedMeeting.status = updatedMeeting.status;
    ServerState.selectedMeeting.lastUpdated = updatedMeeting.lastUpdated;
  }

  /// Bind the server
  void bind() {
    io.HttpServer.bind(_address, _port).then(connectServer);
  }

  /// Callback when server is ready
  void connectServer(io.HttpServer server) {
    listenData(server);
  }

  /// Bind routes
  void listenData(io.HttpServer server) {
    server.listen((io.HttpRequest request) {
      // puts deputy clients to connection queue
      if (request.headers.value('terminalId') != null &&
          request.headers.value('terminalId').isNotEmpty) {
        _connectionQueue.add(request);
      } else {
        // connect other clients without queue
        upgradeHttpRequest(request);
      }
    },
        cancelOnError: true,
        onDone: () => print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} [!]OnDone'),
        onError: (err) => print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} [!]Error -- ${err.toString()}'));
  }

  Duration toDuration(String isoString) {
    if (isoString == null || isoString.isEmpty || isoString == 'null') {
      return Duration(hours: 0, minutes: 0, seconds: 0);
    }
    var parts = isoString.split(':');

    return Duration(
      hours: int.tryParse(parts[0]) ?? 0,
      minutes: int.tryParse(parts[1]) ?? 0,
      seconds: double.tryParse(parts[2])?.ceil() ?? 0,
    );
  }

  void createWSConnection(
      io.WebSocket webSocket, io.HttpRequest request) async {
    var terminalId = request.headers.value('terminalId');

    var requestUriString = request.uri.toString();
    if (requestUriString.contains('terminalId=')) {
      terminalId = requestUriString.substring(
          requestUriString.indexOf('terminalId=') + 11,
          requestUriString.length);
    }

    if (terminalId != null &&
        _connections.any((element) => element.terminalId == terminalId)) {
      webSocket?.add('$terminalId уже используется');
      await webSocket?.close();
      return;
    }

    var type = request.headers.value('type');
    if (requestUriString.contains('type=')) {
      terminalId = requestUriString.substring(
          requestUriString.indexOf('type=') + 5,
          requestUriString.indexOf('&terminalId='));
    }

    var connection = WSConnection(
        id: Uuid().v4(), type: type, terminalId: terminalId, socket: webSocket);

    _connections.add(connection);
    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} connected $terminalId');

    if (connection.terminalId != null &&
        !ServerState.terminalsOnline.contains(connection.terminalId)) {
      ServerState.terminalsOnline.add(connection.terminalId);
    }

    if (connection.terminalId != null &&
        (connection.type == 'deputy' || connection.type == 'manager')) {
      addUserTerminal(connection.terminalId, connection.deputyId);
    }
    ServerState().setDevicesInfo(_connections);

    if (connection.type == 'vissonic_client') {
      ServerState.isVissonicModuleOnline = true;
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Подключен модуль Vissonic.');
    }

    sendStateTo(<WSConnection>[connection]);
    _isSendState = true;

    var streamSubscription =
        webSocket.map((string) => json.decode(string)).listen((value) async {
      if (connection.type == 'operator') {
        var isMessageProcessed = false;

        if (value['terminalId'] != null) {
          if (value['userId'] == null) {
            await processSetUserExit(value['terminalId']);
          } else {
            await processSetUser(
                value['terminalId'], int.tryParse(value['userId']));
          }
          isMessageProcessed = true;
        }

        if (value['update_agenda'] != null) {
          await processSaveAgenda(json.encode(value['update_agenda']));
          isMessageProcessed = true;
        }

        if (value['storeboard_template'] != null) {
          processSetStoreboardTemplate(
              json.encode(value['storeboard_template']));
          isMessageProcessed = true;
        }

        if (value['download'] != null) {
          await processDocumentDownload(
              json.decode(value['download']).toList().cast<String>());
          isMessageProcessed = true;
        }

        if (value['download_all'] != null) {
          await processDocumentDownloadForAll();
          isMessageProcessed = true;
        }

        if (value['restore_vissonic'] != null) {
          await restoreVissonicConnection();
          isMessageProcessed = true;
        }

        if (value['isMicrophoneOn'] != null) {
          sendVissonicMessage('setMicSound',
              terminalId: value['speaker'], isEnabled: value['isMicrophoneOn']);

          isMessageProcessed = true;
        }

        if (value['isMicsEnabled'] != null) {
          sendVissonicMessage('setAllState', isEnabled: value['isMicsEnabled']);

          isMessageProcessed = true;
        }

        if (!isMessageProcessed) {
          processSetSpeakerStoreboard(value['speaker'], value['type'],
              value['name'], value['timelimit']);

          processSetStoreboard(
              value['setStoreboardCaption'],
              value['setStoreboardText'],
              value['isMeetingCompleted'] == 'true',
              value['isDetailsStoreboard'] == 'true');

          processSetBreak(value['breakTime'] == null
              ? null
              : DateTime.parse(json.decode(value['breakTime'])));

          processSetFlushStoreboard(value['flush_storeboard'] == 'true', false);

          if (value['flush_navigation'] == 'true') {
            processSetFlushNavigation();
          }

          if (value['systemState'] != null) {
            await processOperatorMessage(
                EnumToString.fromString(
                    cm.SystemState.values, value['systemState']),
                value['params']);
          }
        }
      }

      if (value['clientType'] != null) {
        processClientTypeChange(
            connection,
            value['clientType'],
            value['deputyId'],
            value['terminalId'],
            value['isUseAuthCard'],
            value['isWindowsClient']);
        _isSendState = true;
      } else if (connection.type == 'deputy' || connection.type == 'manager') {
        // manager and deputy functions
        var isMessageProcessed = processDeputyMessage(
            connection, value['deputyId'], value['value'].toString());

        // manager functions
        if (connection.type == 'manager') {
          if (value['isMicrophoneOn'] != null) {
            sendVissonicMessage('setMicSound',
                terminalId: value['speaker'],
                isEnabled: value['isMicrophoneOn']);
            isMessageProcessed = true;
          }

          if (!isMessageProcessed) {
            processSetSpeakerStoreboard(value['speaker'], value['type'],
                value['name'], value['timelimit']);

            processSetFlushStoreboard(
                value['flush_storeboard'] == 'true', true);
          }
        }
      }

      if (connection.type == 'vissonic_client') {
        processVissonicClientMessage(value);
      }

      if (value['value'] == 'ЗАГРУЖЕНЫ') {
        String terminalId = value['terminalId'];
        ServerState.terminalsLoadingDocuments.remove(terminalId);
        if (!ServerState.terminalsWithDocuments.contains(terminalId)) {
          ServerState.terminalsWithDocuments.add(terminalId);
        }
      }
      if (value['value'] == 'НЕЗАГРУЖЕНЫ') {
        String terminalId = value['terminalId'];
        ServerState.terminalsWithDocuments.remove(terminalId);
        ServerState.terminalsLoadingDocuments.remove(terminalId);
      }
      if (value['value'] == 'ИДЕТ_ЗАГРУЗКА') {
        String terminalId = value['terminalId'];
        ServerState.terminalsForDownload.remove(terminalId);
        if (!ServerState.terminalsLoadingDocuments.contains(terminalId)) {
          ServerState.terminalsLoadingDocuments.add(terminalId);
        }
      }
      if (value['value'].toString().startsWith('ОШИБКА_ЗАГРУЗКИ')) {
        String terminalId = value['terminalId'];
        var errorText =
            value['value'].toString().substring('ОШИБКА_ЗАГРУЗКИ'.length);

        ServerState.terminalsWithDocuments.remove(terminalId);
        ServerState.terminalsLoadingDocuments.remove(terminalId);
        ServerState.terminalsDocumentErrors
            .putIfAbsent(terminalId, () => errorText);
      }

      sendStateTo(<WSConnection>[connection]);
      _isSendState = true;
    }, cancelOnError: true);
    streamSubscription.onDone(() {
      closeConnection(connection);
      streamSubscription.cancel();
    });
    streamSubscription.onError((err) {
      closeConnection(connection);
      streamSubscription.cancel();
    });
  }

  // Sends full server state for operator and manager,
  // otherwise sends short serverState
  void sendStateTo(Iterable<WSConnection> connections) {
    Map<dynamic, dynamic> longState;
    if (connections.isNotEmpty) {
      for (var connection in connections) {
        // do not sent any state to vissonic client
        if (connection.type == 'vissonic_client') {
          continue;
        }
        if (connection.type == 'operator' || connection.type == 'manager') {
          longState ??= ServerState().toJson();
          connection.socket.add(json.encode(longState));
        } else {
          connection.socket
              .add(json.encode(ServerState().toShortJson(connection)));
        }
      }
    }
  }

  /// Close user connections
  void closeConnection(WSConnection connection) async {
    if (_connections.contains(connection)) {
      _connections.remove(connection);

      ServerState.terminalsOnline.remove(connection.terminalId);
      ServerState.terminalsWithDocuments.remove(connection.terminalId);
      ServerState.usersAskSpeech.remove(connection.deputyId);

      // disable sound on deputy mics
      if (connection.type == 'deputy') {
        sendVissonicMessage('setMicSound',
            terminalId: connection.terminalId, isEnabled: false);
      }
      // block managerMics
      if (connection.type == 'manager') {
        sendVissonicMessage('blockMic', terminalId: connection.terminalId);
      }
      // disable mic state on vissonic client disconnect
      if (connection.type == 'vissonic_client') {
        ServerState.isVissonicModuleOnline = false;
        ServerState.isVissonicServerOnline = false;
        ServerState.isVissonicModuleInit = false;
        ServerState.micsEnabled = null;
        ServerState.activeMics = <int>[];
        ServerState.waitingMics = <int>[];
      }

      ServerState.usersTerminals.removeWhere((key, value) =>
          key == connection.terminalId || value == connection.deputyId);

      // set user terminal back if it default
      if (ServerState.selectedMeeting != null) {
        var defaultUserTerminals =
            CommonUtils.getDefaultUsersTerminals().entries.toList();
        var defaultUserTerminal = defaultUserTerminals.firstWhere(
            (element) =>
                element.key == connection.terminalId &&
                element.value == connection.deputyId,
            orElse: () => null);

        if (defaultUserTerminal != null) {
          addUserTerminal(defaultUserTerminal.key, defaultUserTerminal.value);
        }
      }

      ServerState().setDevicesInfo(_connections);
      _isSendState = true;

      await connection.socket?.close();

      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} disconnected ${connection.terminalId}');
    }
  }

  void addUserTerminal(String terminalId, int deputyId) {
    ServerState.usersTerminals
        .removeWhere((key, value) => key == terminalId || value == deputyId);

    if (terminalId != null) {
      ServerState.usersTerminals.putIfAbsent(terminalId, () => deputyId);

      // enable managers mics
      var managerIds = ServerState.selectedMeeting.group.groupUsers
          .where((element) => element.isManager)
          .map((e) => e.user.id)
          .toList();
      var managerTerminals = ServerState.usersTerminals.entries
          .where((element) => managerIds.contains(element.value))
          .toList();
      if (managerTerminals.any((element) => terminalId == element.key)) {
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Микрофон ${terminalId} разблокирован при входе председателя');

        sendVissonicMessage('unblockMic', terminalId: terminalId);
      }
    }
  }

  void processVissonicClientMessage(dynamic message) {
    var vissonicServerState = VissonicServerState.fromJson(message);

    if (!ServerState.isVissonicServerOnline &&
        vissonicServerState.isVissonicServerOnline) {
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Подключен сервер Vissonic.');
    }
    if (ServerState.isVissonicServerOnline &&
        !vissonicServerState.isVissonicServerOnline) {
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Отключен сервер Vissonic.');
    }

    if (!ServerState.isVissonicModuleInit &&
        vissonicServerState.isVissonicModuleInit) {
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Завершена инициализация модуля Vissonic.');
    }

    ServerState.isVissonicServerOnline =
        vissonicServerState.isVissonicServerOnline;
    ServerState.isVissonicModuleInit = vissonicServerState.isVissonicModuleInit;

    ServerState.micsEnabled = vissonicServerState.micsEnabled;
    ServerState.activeMics = vissonicServerState.activeMics;
    ServerState.waitingMics = vissonicServerState.waitingMics;

    // remove enabled ask word users
    for (var i = 0; i < ServerState.usersAskSpeech.length; i++) {
      var foundUserTerminal = ServerState.usersTerminals.entries.firstWhere(
          (element) => element.value == ServerState.usersAskSpeech[i],
          orElse: () => null);

      if (foundUserTerminal != null) {
        var parts = foundUserTerminal.key.split(',');

        for (var j = 0; j < parts.length; j++) {
          if (parts[j].isNotEmpty &&
              ServerState.activeMics.contains(int.parse(parts[j]))) {
            ServerState.usersAskSpeech.removeAt(i);
            break;
          }
        }
      }
    }

    _isSendState = true;
  }

  bool processDeputyMessage(
      WSConnection connection, int deputyId, String value) {
    if (ServerState.systemState == cm.SystemState.Registration) {
      if (value == 'ЗАРЕГИСТРИРОВАТЬСЯ') {
        if (!ServerState.usersRegistered.contains(deputyId)) {
          ServerState.usersRegistered.add(deputyId);
        }
        sendMessage(
            connection, <String, String>{'registration': 'ЗАРЕГИСТРИРОВАН'});
        return true;
      }
      if (value == 'ОТМЕНИТЬ РЕГИСТРАЦИЮ') {
        ServerState.usersRegistered.remove(deputyId);
        sendMessage(
            connection, <String, String>{'registration': 'НЕЗАРЕГИСТРИРОВАН'});
        return true;
      }
    }

    if (ServerState.systemState == cm.SystemState.QuestionVoting) {
      if (value == 'СБРОС') {
        ServerState.usersDecisions
            .removeWhere((key, value) => key == deputyId.toString());
        sendMessage(connection, <String, String>{'voting': 'СБРОС'});
        return true;
      }
      if (value == 'ЗА' || value == 'ПРОТИВ' || value == 'ВОЗДЕРЖАЛСЯ') {
        ServerState.usersDecisions
            .removeWhere((key, value) => key == deputyId.toString());
        ServerState.usersDecisions
            .putIfAbsent(deputyId.toString(), () => value);
        sendMessage(connection, <String, String>{'voting': value});
        return true;
      }
    }

    if (value == 'ПРОШУ СЛОВА') {
      ServerState.usersAskSpeech.add(deputyId);
      sendMessage(connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА'});
      return true;
    }
    if (value == 'ПРОШУ СЛОВА СБРОС') {
      ServerState.usersAskSpeech.removeWhere((element) => element == deputyId);
      sendMessage(
          connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'});
      return true;
    } else if (value.startsWith('ПРОШУ СЛОВА СБРОС')) {
      if (value == 'ПРОШУ СЛОВА СБРОС ВСЕХ') {
        ServerState.usersAskSpeech = <int>[];
      } else {
        var userId = int.parse(value.replaceFirst('ПРОШУ СЛОВА СБРОС ', ''));
        ServerState.usersAskSpeech.removeWhere((element) => element == userId);

        var connection = _connections.firstWhere(
            (element) => element.deputyId == userId,
            orElse: () => null);
        if (connection != null) {
          sendMessage(connection,
              <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'});
        }
      }

      return true;
    }

    return false;
  }

  void sendMessage(WSConnection connection, Map<String, String> message) {
    connection.socket.add(json.encode(message));
  }

  void processDocumentDownload(List<String> terminals) async {
    ServerState.terminalsDocumentErrors.clear();
    ServerState.terminalsLoadingDocuments.clear();

    ServerState.terminalsForDownload = terminals;
    ServerState.isLoadingDocuments = true;
  }

  void processDocumentDownloadForAll() async {
    await processDocumentDownload(_connections
        .where((element) =>
            element.type == 'deputy' ||
            element.type == 'guest' ||
            element.type == 'unknown_client')
        .map((e) => e.terminalId)
        .toList());
  }

  void processClientTypeChange(
      WSConnection connection,
      String clientType,
      int deputyId,
      String terminalId,
      bool isUseAuthCard,
      bool isWindowsClient) {
    connection.isUseAuthcard = isUseAuthCard == true;
    connection.isWindowsClient = isWindowsClient == true;

    if (terminalId != null) {
      // if (_connections.any((element) => element.terminalId == terminalId)) {
      //   connection.socket?.add(
      //       'Пользователь уже используется. Вы уже вошли на терминале ${connection.terminalId}');
      //   return;
      // }
      if (ServerState.terminalsOnline.contains(connection.terminalId)) {
        ServerState.terminalsOnline.remove(connection.terminalId);
      }
      connection.terminalId = terminalId;
      if (!ServerState.terminalsOnline.contains(connection.terminalId)) {
        ServerState.terminalsOnline.add(connection.terminalId);
      }
    }

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} -> ${clientType} client type changed on ${connection.terminalId}');
    connection.type = clientType;

    if (connection.deputyId != deputyId) {
      if (deputyId != null &&
          _connections.any((element) => element.deputyId == deputyId)) {
        connection.socket?.add(
            'Пользователь уже используется. Вы уже вошли на терминале ${connection.terminalId}');
        return;
      }

      if (deputyId != null) {
        addUserTerminal(connection.terminalId, deputyId);
      } else {
        // disable connection mics
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Микрофон ${connection.terminalId} отключен при выходе пользователя');
        sendVissonicMessage('setMicSound',
            terminalId: connection.terminalId, isEnabled: false);

        ServerState.usersAskSpeech.remove(connection.deputyId);
        ServerState.usersTerminals.removeWhere((key, value) =>
            key == connection.terminalId || value == connection.deputyId);
      }

      connection.deputyId = deputyId;
    }

    ServerState().setDevicesInfo(_connections);
  }

  void processSetUser(String terminalId, int userId) async {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);
    if (connection != null && userId != null) {
      // change type of terminal
      var clientType = ServerState.selectedMeeting.group.groupUsers
              .any((element) => element.isManager && element.user.id == userId)
          ? 'manager'
          : 'deputy';
      processClientTypeChange(
          connection,
          clientType,
          userId,
          connection.terminalId,
          connection.isUseAuthcard,
          connection.isWindowsClient);
      // register assigned user
      if (ServerState.isRegistrationCompleted) {
        if (!ServerState.usersRegistered.contains(userId)) {
          //add new registration session
          if (ServerState.registrationSession != null) {
            var insertRegistrationQuery = Query<Registration>(_context)
              ..values.userId = userId
              ..values.registrationSession.id =
                  ServerState.registrationSession.id;
            await insertRegistrationQuery.insert();
          }

          ServerState.usersRegistered.add(userId);
        }
      }

      sendMessage(connection, <String, String>{'setUser': userId.toString()});
    }
  }

  void processSetUserExit(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    ServerState.usersRegistered.remove(connection.deputyId);
    if (connection != null) {
      sendMessage(connection, <String, String>{'setUserExit': 'true'});
    }
  }

  // restores connection from ais_server to vissonic_main_unit
  // uses connected ais_vissonic_client module
  // otherwise start new ais_vissonic_client module
  void restoreVissonicConnection() async {
    ServerState.isVissonicServerOnline = true;
    ServerState.isVissonicModuleInit = false;

    if (!initVissonicModule()) {
      // killall previous ais_vissonic_client if they can't connect to ais_server
      // for some reasons
      try {
        var evinceCheck = Process.runSync('pgrep', <String>['ais_vissonic']);
        if (evinceCheck.stdout.toString().isNotEmpty) {
          Process.runSync('killall', <String>['ais_vissonic_client.exe']);
        }
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Остановлена работа модуля Vissonic.');
      } catch (exc) {
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Запущенных модулей Vissonic не найдено.');
      }
      // start new ais_vissonic_client and await till it connects to ais_server
      try {
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Запуск модуля Vissonic .${VISSONIC_MODULE_PATH}ais_vissonic_client.exe.');
        await Process.run(VISSONIC_MODULE_PATH + 'ais_vissonic_client.exe', []);
        //var shell = await Shell().cd(VISSONIC_MODULE_PATH);
        //shell.run('./ais_vissonic_client.exe');
        await waitUntilVissonicModuleConnect(50, Duration(milliseconds: 200));
      } catch (exc) {
        print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Модуль Vissonic не найден.');
      }
    }
  }

  // awaits till ais_vissonic_client connects to ais_server
  // and starts ais_vissonic_client module initialization
  Future<int> waitUntilVissonicModuleConnect(
      int maxIterations, Duration step) async {
    var iterations = 0;

    for (; iterations < maxIterations; iterations++) {
      await Future.delayed(step);
      if (ServerState.isVissonicModuleOnline) {
        initVissonicModule();
        break;
      }
    }

    if (iterations >= maxIterations) {
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Превышено время ожидания подключения модуля Vissonic ${step.inMilliseconds * maxIterations} мс.');
      ServerState.isVissonicModuleOnline = false;
      ServerState.isVissonicModuleInit = false;
      ServerState.isVissonicServerOnline = false;
      _isSendState = true;
    }

    return iterations;
  }

  // returns true if init was started, false otherwise
  bool initVissonicModule() {
    var wasInit = false;
    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Инициализация модуля Vissonic.');
    var vissonicClientConnection = _connections.firstWhere(
        (element) => element.type == 'vissonic_client',
        orElse: () => null);

    if (vissonicClientConnection != null) {
      var currentMics = loadDefaultTerminalMics();

      vissonicClientConnection.socket.add(json.encode(currentMics));
      sendVissonicMessage('connect', isEnabled: getIsMicsEnabledState());
      wasInit = true;
    } else {
      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Не найдено подключение модуля Vissonic.');
    }

    return wasInit;
  }

  void sendVissonicMessage(String command,
      {String terminalId, bool isEnabled}) {
    var vissonicClientConnection = _connections.firstWhere(
        (element) => element.type == 'vissonic_client',
        orElse: () => null);

    if (vissonicClientConnection != null) {
      vissonicClientConnection.socket.add(json.encode({
        'command': command,
        'terminalId': terminalId,
        'isEnabled': isEnabled
      }));
    }
  }

  void processSetSpeakerStoreboard(String speakerTerminalId, String speakerType,
      String speakerName, String speakeTimeLimit) {
    if (speakerTerminalId != null) {
      ServerState.currentSpeaker = speakerTerminalId;
      ServerState.speakerType = speakerType;
      ServerState.speakerName = speakerName;
      ServerState.speakerTimelimit = toDuration(speakeTimeLimit);
    } else {
      ServerState.currentSpeaker = null;
      ServerState.speakerType = null;
      ServerState.speakerName = null;
      ServerState.speakerTimelimit = null;
    }

    _isSendState = true;
  }

  void processSetStoreboard(String caption, String text,
      bool isMeetingCompleted, bool isDetailsStoreboard) {
    ServerState.storeboardCustomCaption = caption;
    ServerState.storeboardCustomText = text;
    ServerState.isMeetingCompleted = isMeetingCompleted;
    ServerState.isDetailsStoreboard = isDetailsStoreboard;

    _isSendState = true;
  }

  void processSetBreak(DateTime breakTime) {
    ServerState.breakTime = breakTime;

    _isSendState = true;
  }

  void processSetFlushStoreboard(bool isFlushStoreboard, bool isManager) {
    ServerState.isFlushStoreboard = isFlushStoreboard;

    if (ServerState.isFlushStoreboard && !isManager) {
      // operator also flushes usersDecisions
      ServerState.usersDecisions = <String, String>{};
    }

    _isSendState = true;
  }

  void processSetFlushNavigation() {
    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        sendMessage(connection, <String, String>{'flush_navigation': 'true'});
      }
    }
  }

  void processSetStoreboardTemplate(String value) {
    ServerState.storeboardTemplate =
        cm.StoreboardTemplate.fromJson(json.decode(value));
    _isSendState = true;
  }

  void processSaveAgenda(String value) async {
    var agendaForSave = cm.Agenda.fromJson(json.decode(value));
    var previousAgenda = ServerState.selectedMeeting.agenda;

    // delete questions
    var questionsForDelete = previousAgenda.questions
        .where((prevElement) => !agendaForSave.questions
            .any((element) => element.id == prevElement.id))
        .toList();

    for (var i = 0; i < questionsForDelete.length; i++) {
      final queryDelete = Query<Question>(_context)
        ..where((u) => u.id).equalTo(questionsForDelete[i].id);
      await queryDelete.delete();
    }

    var sendQuestions = ManagedSet<Question>();

    // add new questions
    var questionsForAdd = agendaForSave.questions
        .where((prevElement) => !previousAgenda.questions
            .any((element) => element.id == prevElement.id))
        .toList();

    for (var i = 0; i < questionsForAdd.length; i++) {
      var question = questionsForAdd[i];
      // insert new question
      var parentAgenda = Agenda();
      parentAgenda.id = question.agendaId;

      final queryInsert = Query<Question>(_context)
        ..values.name = question.name
        ..values.folder = question.folder
        ..values.orderNum = question.orderNum
        ..values.agenda = parentAgenda
        ..values.description = question.toJson()['description'];
      var insertedQuestion = await queryInsert.insert();

      question.id = insertedQuestion.id;
      insertedQuestion.files = ManagedSet<File>();

      // insert questionFiles
      for (var j = 0; j < question.files.length; j++) {
        final insertedQuestionFile = Query<File>(_context)
          ..values.path = question.files[j].relativePath
          ..values.fileName = question.files[j].fileName
          ..values.version = question.files[j].version
          ..values.description = question.files[j].description
          ..values.question = insertedQuestion;

        var insertedFile = await insertedQuestionFile.insert();

        insertedQuestion.files.add(insertedFile);
        question.files[question.files.indexOf(question.files[j])].id =
            insertedFile.id;
        question.files[question.files.indexOf(question.files[j])].questionId =
            insertedQuestion.id;
      }

      sendQuestions.add(insertedQuestion);
      agendaForSave.questions[agendaForSave.questions.indexOf(question)].id =
          question.id;

      //copy files from temp folder
      var fromPath = 'documents/' +
          previousAgenda.folder +
          '/temp/' +
          insertedQuestion.folder;
      var toPath =
          'documents/' + previousAgenda.folder + '/' + insertedQuestion.folder;

      await copyPath(fromPath, toPath);

      //clear question tempFolder
      if (await io.Directory(fromPath).exists()) {
        await io.Directory(fromPath).delete(recursive: true);
      }
    }

    // update other questions
    var questionsForUpdate = agendaForSave.questions
        .where((prevElement) => previousAgenda.questions
            .any((element) => element.id == prevElement.id))
        .toList();

    for (var i = 0; i < questionsForUpdate.length; i++) {
      var question = questionsForUpdate[i];
      final queryUpdate = Query<Question>(_context)
        ..values.name = question.name
        ..values.orderNum = question.orderNum
        ..values.description = question.toJson()['description']
        ..where((u) => u.id).equalTo(question.id);
      var updatedQuestions = await queryUpdate.update();

      var updatedQuestion = updatedQuestions[0];
      var oldQuestion = previousAgenda.questions.firstWhere(
          (element) => element.id == question.id,
          orElse: () => null);

      //update question files
      // add files
      var filesForAdd = question.files
          .where((prevElement) =>
              !oldQuestion.files.any((element) => element.id == prevElement.id))
          .toList();
      for (var j = 0; j < filesForAdd.length; j++) {
        final insertedQuestionFile = Query<File>(_context)
          ..values.question.id = filesForAdd[j].questionId
          ..values.path = filesForAdd[j].relativePath
          ..values.fileName = filesForAdd[j].fileName
          ..values.version = filesForAdd[j].version
          ..values.description = filesForAdd[j].description
          ..values.question = updatedQuestion;

        await insertedQuestionFile.insert();
      }

      // delete files
      var filesForDelete = oldQuestion.files
          .where((prevElement) =>
              !question.files.any((element) => element.id == prevElement.id))
          .toList();

      for (var j = 0; j < filesForDelete.length; j++) {
        final queryDelete = Query<File>(_context)
          ..where((f) => f.id).equalTo(filesForDelete[j].id);
        await queryDelete.delete();
      }

      //ToDo: updateFiles
      var q = Query<Question>(_context)
        ..join(set: (q) => q.files)
        ..where((o) => o.id).equalTo(updatedQuestion.id);
      final selectedUpdatedQuestion = await q.fetchOne();

      //copy files from temp folder
      var fromPath = 'documents/' +
          previousAgenda.folder +
          '/temp/' +
          selectedUpdatedQuestion.folder;
      var toPath = 'documents/' +
          previousAgenda.folder +
          '/' +
          selectedUpdatedQuestion.folder;

      await copyPath(fromPath, toPath);

      //clear question tempFolder
      if (await io.Directory(fromPath).exists()) {
        await io.Directory(fromPath).delete(recursive: true);
      }

      sendQuestions.add(selectedUpdatedQuestion);
    }

    // update agenda last updated
    var query = Query<Agenda>(_context)
      ..values.lastUpdated = CommonUtils.getDateTimeNow(_timeOffset)
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.agenda.id);

    await query.update();

    //clear all tempFolders
    if (await io.Directory('documents/' + previousAgenda.folder + '/temp/')
        .exists()) {
      await io.Directory('documents/' + previousAgenda.folder + '/temp/')
          .delete(recursive: true);
    }

    ServerState.selectedMeeting.agenda.questions = sendQuestions;

    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        sendMessage(connection, <String, String>{
          'update_agenda': json.encode(agendaForSave.toJson())
        });
      }
    }
  }

  Future<void> copyPath(String from, String to) async {
    if (!await io.Directory(from).exists()) {
      return;
    }
    await io.Directory(to).create(recursive: true);
    await for (final file in io.Directory(from).list(recursive: true)) {
      final copyTo = p.join(to, p.relative(file.path, from: from));
      if (file is io.Directory) {
        await io.Directory(copyTo).create(recursive: true);
      } else if (file is io.File) {
        await io.File(file.path).copy(copyTo);
      }
    }
  }

  void processOperatorMessage(cm.SystemState systemState, String params) async {
    var meetingId = json.decode(params)['meeting_id'];
    var questionId = json.decode(params)['question_id'];

    // Начата подготовка к заседанию
    if (systemState == cm.SystemState.MeetingPreparation) {
      // insert meeting session
      final insertMeetingSession = Query<MeetingSession>(_context)
        ..values.meetingId = meetingId;
      var insertedMeetingSession = await insertMeetingSession.insert();

      // update meeting state
      var updateMeeting = Query<Meeting>(_context)
        ..values.status = 'Подготовка'
        ..values.lastUpdated = CommonUtils.getDateTimeNow(_timeOffset)
        ..where((u) => u.id).equalTo(meetingId);
      await updateMeeting.update();

      //select meeting with agenda and group
      var updatedMeeting = await getMeetingById(meetingId);

      ServerState.systemState = cm.SystemState.MeetingPreparation;
      ServerState.selectedMeeting = updatedMeeting;
      loadDefaultUsersTerminals();
      ServerState.selectedMeetingSession = insertedMeetingSession;
      ServerState.selectedQuestion = null;
      ServerState.selectedQuestionSession = null;
      ServerState.usersDecisions = <String, String>{};

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }

    // Остановлена подготовка к заседанию
    if (systemState == cm.SystemState.MeetingPreparationComplete) {
      // delete meeting session
      final deleteMeetingSession = Query<MeetingSession>(_context)
        ..where((ms) => ms.meetingId).equalTo(meetingId)
        ..where((ms) => ms.startDate).isNull();
      await deleteMeetingSession.delete();

      // update meeting state
      var updateMeeting = Query<Meeting>(_context)
        ..values.status = 'Ожидание'
        ..values.lastUpdated = CommonUtils.getDateTimeNow(_timeOffset)
        ..where((u) => u.id).equalTo(meetingId);
      await updateMeeting.update();

      ServerState.systemState = cm.SystemState.MeetingCompleted;
      ServerState.isRegistrationCompleted = false;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersRegistered = <int>[];
      ServerState.terminalsWithDocuments = <String>[];
      ServerState.usersAskSpeech = <int>[];

      ServerState.selectedMeeting = null;
      ServerState.selectedMeetingSession = null;
      ServerState.selectedQuestion = null;
      ServerState.selectedQuestionSession = null;
      ServerState.registrationSession = null;

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }

    // Начато новое заседание
    if (systemState == cm.SystemState.MeetingStarted) {
      var startDate = CommonUtils.getDateTimeNow(_timeOffset);

      // update meeting session
      final updateMeetingSession = Query<MeetingSession>(_context)
        ..values.startDate = startDate
        ..where((ms) => ms.meetingId).equalTo(meetingId)
        ..where((ms) => ms.startDate).isNull();
      var updatedMeetingSession = (await updateMeetingSession.update()).first;

      // update meeting state
      var updateMeeting = Query<Meeting>(_context)
        ..values.status = 'Начато'
        ..values.lastUpdated = startDate
        ..where((u) => u.id).equalTo(meetingId);
      await updateMeeting.update();

      //select meeting with agenda and group
      var updatedMeeting = await getMeetingById(meetingId);

      ServerState.systemState = cm.SystemState.MeetingStarted;
      ServerState.selectedMeeting = updatedMeeting;
      ServerState.selectedMeetingSession = updatedMeetingSession;
      ServerState.selectedQuestion = null;
      ServerState.selectedQuestionSession = null;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersAskSpeech = <int>[];

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }

    var selectedQuestion = ServerState.selectedMeeting.agenda.questions
        .firstWhere((element) => element.id == questionId, orElse: () => null);
    var votingInterval = json.decode(params)['voting_interval'];
    var registrationInterval = json.decode(params)['registration_interval'];
    var votingModeId = json.decode(params)['voting_mode_id'];
    var votingDecision = json.decode(params)['voting_decision'];
    var successCount = json.decode(params)['success_count'];

    // Регистрация
    if (systemState == cm.SystemState.Registration) {
      var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
      _interval = registrationInterval;

      final insertRegistrationSession = Query<RegistrationSession>(_context)
        ..values.meetingId = ServerState.selectedMeeting.id
        ..values.interval = registrationInterval
        ..values.startDate = lastUpdated;
      var insertedRegistrationSession =
          await insertRegistrationSession.insert();

      var updateMeeting = Query<Meeting>(_context)
        ..values.status = 'Регистрация'
        ..values.lastUpdated = lastUpdated
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await updateMeeting.update()).first;

      ServerState.systemState = cm.SystemState.Registration;
      updateServerStateMeeting(updatedMeeting);
      ServerState.registrationSession = insertedRegistrationSession;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersRegistered = <int>[];
      ServerState.usersAskSpeech = <int>[];

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }

    // Регистрация завершена
    if (systemState == cm.SystemState.RegistrationComplete) {
      await completeRegistration();
      return;
    }

    // Запущен стрим
    if (systemState == cm.SystemState.Stream) {
      ServerState.systemState = cm.SystemState.Stream;
      ServerState.streamUrl = json.decode(params)['stream_url'];
      ServerState.streamControl = json.decode(params)['stream_control'];
      ServerState.usersDecisions = <String, String>{};
      return;
    }

    // Просмотр вопроса
    if (systemState == cm.SystemState.QuestionLocked) {
      var query = Query<Meeting>(_context)
        ..values.status =
            'Просмотр ${selectedQuestion.name} ${selectedQuestion.orderNum}'
        ..values.lastUpdated = CommonUtils.getDateTimeNow(_timeOffset)
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await query.update()).first;

      updateServerStateMeeting(updatedMeeting);

      ServerState.systemState = cm.SystemState.QuestionLocked;
      ServerState.selectedQuestion = selectedQuestion;
      if (ServerState.previousSelectedQuestion?.id != selectedQuestion?.id) {
        ServerState.previousSelectedQuestion = selectedQuestion;
        ServerState.usersAskSpeech = <int>[];
      }

      ServerState.selectedQuestionSession = null;
      ServerState.usersDecisions = <String, String>{};
      return;
    }

    // Вопрос снят
    if (systemState == cm.SystemState.MeetingIdle) {
      var query = Query<Meeting>(_context)
        ..values.status = 'Начато'
        ..values.lastUpdated = CommonUtils.getDateTimeNow(_timeOffset)
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await query.update()).first;

      ServerState.systemState = cm.SystemState.MeetingStarted;
      updateServerStateMeeting(updatedMeeting);
      ServerState.selectedQuestion = null;
      ServerState.usersDecisions = <String, String>{};
      return;
    }

    // Голосование
    if (systemState == cm.SystemState.QuestionVoting) {
      var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
      _interval = votingInterval;

      final insertQuestionSession = Query<QuestionSession>(_context)
        ..values.meetingSessionId = ServerState.selectedMeetingSession.id
        ..values.questionId = questionId
        ..values.interval = votingInterval
        ..values.votingModeId = votingModeId
        ..values.desicion = votingDecision
        ..values.usersCountRegistred = ServerState.usersRegistered.length
        ..values.usersCountForSuccess = successCount
        ..values.startDate = lastUpdated;
      var insertedQuestionSession = await insertQuestionSession.insert();

      var query = Query<Meeting>(_context)
        ..values.status =
            'Голосование ${selectedQuestion.name} ${selectedQuestion.orderNum}'
        ..values.lastUpdated = lastUpdated
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await query.update()).first;

      ServerState.systemState = cm.SystemState.QuestionVoting;
      updateServerStateMeeting(updatedMeeting);
      ServerState.selectedQuestionSession = insertedQuestionSession;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersAskSpeech = <int>[];

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }

    // Голосование завершено
    if (systemState == cm.SystemState.QuestionVotingComplete) {
      await completeVoting(selectedQuestion);
      return;
    }

    // Заседание завершено
    if (systemState == cm.SystemState.MeetingCompleted) {
      var endDate = CommonUtils.getDateTimeNow(_timeOffset);

      final updateMeetingSession = Query<MeetingSession>(_context)
        ..values.endDate = endDate
        ..where((ms) => ms.meetingId).equalTo(meetingId)
        ..where((ms) => ms.endDate).isNull();
      await updateMeetingSession.update();

      var query = Query<Meeting>(_context)
        ..values.status = 'Завершено'
        ..values.lastUpdated = endDate
        ..where((u) => u.id).equalTo(meetingId);
      await query.update();

      ServerState.systemState = cm.SystemState.MeetingCompleted;
      ServerState.isRegistrationCompleted = false;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersRegistered = <int>[];
      ServerState.terminalsWithDocuments = <String>[];
      ServerState.usersAskSpeech = <int>[];
      ServerState.selectedMeeting = null;
      ServerState.selectedMeetingSession = null;
      ServerState.selectedQuestion = null;
      ServerState.selectedQuestionSession = null;
      ServerState.registrationSession = null;

      // set mic sound settings
      sendVissonicMessage('setAllState', isEnabled: getIsMicsEnabledState());

      return;
    }
  }

  Future completeRegistration() async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    _interval = null;

    if (ServerState.usersRegistered.isNotEmpty) {
      for (var registration in ServerState.usersRegistered) {
        var insertRegistrationQuery = Query<Registration>(_context)
          ..values.userId = registration
          ..values.registrationSession.id = ServerState.registrationSession.id;

        unawaited(insertRegistrationQuery.insert());
      }
    }

    var updateRegistationSession = Query<RegistrationSession>(_context)
      ..values.endDate = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.registrationSession.id);
    var updatedRegistationSession =
        (await updateRegistationSession.update()).first;

    var updateMeeting = Query<Meeting>(_context)
      ..values.status = 'Регистрация завершена'
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
    var updatedMeeting = (await updateMeeting.update()).first;

    ServerState.isFlushStoreboard = false;
    ServerState.isRegistrationCompleted = true;
    ServerState.systemState = cm.SystemState.RegistrationComplete;
    updateServerStateMeeting(updatedMeeting);
    ServerState.registrationSession = updatedRegistationSession;
    ServerState.registrationResult = ServerState.usersRegistered.length;
  }

  Future completeVoting(Question selectedQuestion) async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    _interval = null;

    if (ServerState.usersDecisions.entries.isNotEmpty) {
      for (var decision in ServerState.usersDecisions.entries) {
        var insertDecisionQuery = Query<Result>(_context)
          ..values.questionSession.id = ServerState.selectedQuestionSession.id
          ..values.userId = int.parse(decision.key)
          ..values.result = decision.value;
        unawaited(insertDecisionQuery.insert());
      }
    }

    var updateQuestionSession = Query<QuestionSession>(_context)
      ..values.usersCountVoted = ServerState.usersDecisions.length
      ..values.usersCountVotedYes = ServerState.usersDecisions.values
          .where((element) => element == 'ЗА')
          .length
      ..values.usersCountVotedNo = ServerState.usersDecisions.values
          .where((element) => element == 'ПРОТИВ')
          .length
      ..values.usersCountVotedIndiffirent = ServerState.usersDecisions.values
          .where((element) => element == 'ВОЗДЕРЖАЛСЯ')
          .length
      ..values.endDate = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedQuestionSession.id);
    var updatedQuestionSession = (await updateQuestionSession.update()).first;

    var query = Query<Meeting>(_context)
      ..values.status =
          'Голосование ${selectedQuestion.name} ${selectedQuestion.orderNum} завершено'
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
    var updatedMeeting = (await query.update()).first;

    ServerState.systemState = cm.SystemState.QuestionVotingComplete;
    updateServerStateMeeting(updatedMeeting);
    ServerState.selectedQuestionSession = updatedQuestionSession;
    ServerState.isFlushStoreboard = false;

    ServerState.votingResultYes = ServerState.usersDecisions.values
        .where((element) => element == 'ЗА')
        .length;
    ServerState.votingResultNo = ServerState.usersDecisions.values
        .where((element) => element == 'ПРОТИВ')
        .length;
    ServerState.votingResultIndiffirent = ServerState.usersDecisions.values
        .where((element) => element == 'ВОЗДЕРЖАЛСЯ')
        .length;
    ServerState.votingTotalVotes = ServerState.usersDecisions.values.length;
  }

  void loadDefaultUsersTerminals() {
    var defaultUserTerminals =
        CommonUtils.getDefaultUsersTerminals().entries.toList();

    for (var i = 0; i < defaultUserTerminals.length; i++) {
      addUserTerminal(
          defaultUserTerminals[i].key, defaultUserTerminals[i].value);
    }
  }

  List<TerminalMic> loadDefaultTerminalMics() {
    var currentMics = <TerminalMic>[];

    if (ServerState.selectedMeeting == null) {
      return currentMics;
    }

    var unblockedMics = CommonUtils.getUnblockedMicsList();

    // add workplaces mics
    var defaultUserTerminals =
        CommonUtils.getDefaultUsersTerminals().entries.toList();

    for (var i = 0; i < defaultUserTerminals.length; i++) {
      var parts = defaultUserTerminals[i].key.split(',');

      for (var j = 0; j < parts.length; j++) {
        if (parts[j].isNotEmpty) {
          var micId = int.parse(parts[j]);
          var terminalMic = TerminalMic(defaultUserTerminals[i].key, micId,
              unblockedMics.contains(micId));

          if (!currentMics
              .any((element) => element.micId == terminalMic.micId)) {
            currentMics.add(terminalMic);
          }
        }
      }
    }

    // add tribune mics
    var workplaces = Workplaces.fromJson(
        json.decode(ServerState.selectedMeeting.group.workplaces));

    for (var i = 0; i < workplaces.tribuneTerminalIds.length; i++) {
      var parts = workplaces.tribuneTerminalIds[i].split(',');

      for (var j = 0; j < parts.length; j++) {
        if (parts[j].isNotEmpty) {
          var micId = int.parse(parts[j]);
          var terminalMic = TerminalMic(workplaces.tribuneTerminalIds[i], micId,
              unblockedMics.contains(micId));

          if (!currentMics
              .any((element) => element.micId == terminalMic.micId)) {
            currentMics.add(terminalMic);
          }
        }
      }
    }

    return currentMics;
  }

  Future<List<Meeting>> getAllMeetings() async {
    final query = Query<Meeting>(_context);
    var allMeetings = await query.fetch();

    final queryGroups = Query<Group>(_context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user);
    var allGroups = await queryGroups.fetch();

    final queryAgenda = Query<Agenda>(_context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files);
    var allAgendas = await queryAgenda.fetch();

    for (var i = 0; i < allMeetings.length; i++) {
      var meeting = allMeetings[i];

      var group = allGroups.firstWhere(
          (element) => element.id == meeting.group.id,
          orElse: () => null);
      meeting.group = group;
      var agenda = allAgendas.firstWhere(
          (element) => element.id == meeting.agenda.id,
          orElse: () => null);
      meeting.agenda = agenda;
    }
    return allMeetings;
  }

  Future<Meeting> getMeetingById(int meetingId) async {
    final q = Query<Meeting>(_context)..where((o) => o.id).equalTo(meetingId);
    final meeting = await q.fetchOne();

    if (meeting == null) {
      return null;
    }

    final queryGroup = Query<Group>(_context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user)
      ..where((g) => g.id).equalTo(meeting.group.id);
    var group = await queryGroup.fetchOne();
    meeting.group = group;

    final queryAgenda = Query<Agenda>(_context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files)
      ..where((a) => a.id).equalTo(meeting.agenda.id);
    var agenda = await queryAgenda.fetchOne();
    meeting.agenda = agenda;

    return meeting;
  }
}
