import 'dart:io' as io;
import 'dart:convert' show json;
import 'dart:async';
import 'dart:io';

import 'package:ntp/ntp.dart';
import 'package:ais_model/ais_model.dart' as cm;
import 'package:services/models/system_log.dart';
//import 'package:process_run/shell_run.dart';
import 'package:uuid/uuid.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:pedantic/pedantic.dart';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:path/path.dart' as p;

import '../models/ais_model.dart';
import 'common_utils.dart';
import 'external_client.dart';
import 'ws_connection.dart';
import 'server_state.dart';
import '../settings.dart';
import 'package:ais_model/ais_model.dart' show DecisionModeHelper, Workplaces;

class WebSocketServer {
  final int _port;
  final String _address;
  final ManagedContext _context;

  final List<WSConnection> _connections = <WSConnection>[];
  final List<WSConnection> _tempRemovedConnections = <WSConnection>[];
  List<io.HttpRequest> _connectionQueue;
  List<Meeting> _meetings;
  List<Proxy> _proxies;
  cm.Settings _settings;

  int _interval;
  int _timeOffset;

  bool _isSendState = false;

  ExternalClient _externalClient;

  WebSocketServer(this._address, this._port, this._context);

  void load() async {
    var stopwatch = Stopwatch();

    print(
        '${DateTime.now().toString()} Начата инициализация веб сервера $APP_NAME');

    print('${DateTime.now().toString()} Начата синхронизация времени');
    _timeOffset = await NTP
        .getNtpOffset(
            localTime: DateTime.now(),
            lookUpAddress: NTP_SERVER,
            timeout: Duration(seconds: 10))
        .onError((error, stackTrace) {
      print(
          'Отсутствует синхронизация с сервером времени. ${error.toString()} ${stackTrace.toString()}');
      return null;
    });

    //do not continue without time sync
    if (_timeOffset == null) {
      io.exit(0);
    }

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Синхронизация времени завершена');

    // connect external client
    _externalClient = ExternalClient();

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Чтение базы данных ${PSQL_SERVER + '/' + PSQL_DATABASE} ...');

    _meetings = await CommonUtils.getAllMeetings(_context);
    _proxies = await CommonUtils.getAllProxies(_context);
    _settings = await CommonUtils.getCurrentSettings(_context);

    // find startedMeeting
    final queryMeetingSessions = Query<MeetingSession>(_context);
    var meetingSessions = await queryMeetingSessions.fetch();

    var startedMeetingSession = meetingSessions
        .lastWhere((element) => element.endDate == null, orElse: () => null);
    var startedMeeting = _meetings.firstWhere(
        (element) => element.id == startedMeetingSession?.meetingId,
        orElse: () => null);
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);

    if (startedMeetingSession != null && startedMeeting != null) {
      // fix db data:
      // close previous meeting sessions
      final updateMeetingSessionStart = Query<MeetingSession>(_context)
        ..values.startDate = lastUpdated
        ..where((ms) => ms.id).notEqualTo(startedMeetingSession.id)
        ..where((ms) => ms.startDate).isNull();
      var fixedSessions = await updateMeetingSessionStart.update();

      final updateMeetingSessionEnd = Query<MeetingSession>(_context)
        ..values.endDate = lastUpdated
        ..where((ms) => ms.id).notEqualTo(startedMeetingSession.id)
        ..where((ms) => ms.endDate).isNull();
      fixedSessions.addAll(await updateMeetingSessionEnd.update());

      // close previous meetings
      var updateMeetings = Query<Meeting>(_context)
        ..values.status = 'Завершено'
        ..values.lastUpdated = lastUpdated
        ..where((m) => m.id).notEqualTo(startedMeeting.id)
        ..where((m) => m.status).notEqualTo('Завершено')
        ..where((m) => m.status).notEqualTo('Ожидание');
      var fixedMeetings = await updateMeetings.update();

      if (fixedMeetings.isNotEmpty || fixedSessions.isNotEmpty) {
        print('Восстановление бд:');
        for (var fixedMeeting in fixedMeetings) {
          print(
              'Завершено заседание (наименование:ид): ${fixedMeeting.name}:${fixedMeeting.id}');
        }
        for (var fixedSession in fixedSessions) {
          print(
              'Завершена сессия (ид):${fixedSession.id} для заседания (ид): ${fixedSession.meetingId}');
        }
      }
      // to ensure only one pair of opened Meeting and
    }

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
      if (startedMeeting.status.startsWith('Регистрация')) {
        // fix meeting status
        var query = Query<Meeting>(_context)
          ..values.status = 'Начато'
          ..values.lastUpdated = lastUpdated
          ..where((u) => u.id).equalTo(startedMeeting.id);
        await query.update();

        startedMeeting.status = 'Начато';
        startedMeeting.lastUpdated = lastUpdated;
        ServerState.systemState = cm.SystemState.MeetingStarted;
      }
      if (startedMeeting.status.startsWith('Голосование')) {
        // fix meeting status
        var query = Query<Meeting>(_context)
          ..values.status = startedMeeting.status
              .replaceFirst('Голосование', 'Просмотр')
              .replaceFirst(' завершено', '')
          ..values.lastUpdated = lastUpdated
          ..where((u) => u.id).equalTo(startedMeeting.id);
        await query.update();

        startedMeeting.status = startedMeeting.status
            .replaceFirst('Голосование', 'Просмотр')
            .replaceFirst(' завершено', '');
        startedMeeting.lastUpdated = lastUpdated;

        ServerState.systemState = cm.SystemState.QuestionLocked;
      }

      if (startedMeeting.status.startsWith('Запись')) {
        // fix meeting status
        var query = Query<Meeting>(_context)
          ..values.status = startedMeeting.status
              .replaceFirst('Запись в очередь на выступление', 'Просмотр')
              .replaceFirst(' завершена', '')
          ..values.lastUpdated = lastUpdated
          ..where((u) => u.id).equalTo(startedMeeting.id);
        await query.update();

        startedMeeting.status = startedMeeting.status
            .replaceFirst('Запись в очередь на выступление', 'Просмотр')
            .replaceFirst(' завершена', '');
        startedMeeting.lastUpdated = lastUpdated;

        ServerState.systemState = cm.SystemState.QuestionLocked;
      }

      ServerState.selectedMeeting = startedMeeting;
      // load default users termnals if needed
      loadDefaultUsersTerminals(ServerState.selectedMeeting);
      ServerState.meetingSession = startedMeetingSession;

      ServerState.guestsPlaces = startedMeetingSession.guestPlaces == null
          ? <cm.GuestPlace>[]
          : (json.decode(startedMeetingSession.guestPlaces) as List)
              .map((data) => cm.GuestPlace.fromJson(data))
              .toList();

      // find registration session
      if (ServerState.selectedMeeting != null &&
          ServerState.meetingSession.startDate != null) {
        final queryRegistrationSessions = Query<RegistrationSession>(_context);
        var registrationSessions = await queryRegistrationSessions.fetch();
        registrationSessions.sort((a, b) => a.startDate.compareTo(b.startDate));

        var registrationSession = registrationSessions.lastWhere(
            (element) =>
                element.meetingId == ServerState.selectedMeeting.id &&
                element.startDate != null &&
                element.startDate.microsecondsSinceEpoch >
                    ServerState.meetingSession.startDate.microsecondsSinceEpoch,
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
      }

      if (startedMeeting.status.startsWith('Начато')) {
        ServerState.systemState = cm.SystemState.MeetingStarted;
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

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Завершена инициализация веб сервера $APP_NAME');

    // Init system timers

    //main timer
    Timer.periodic(Duration(milliseconds: STATE_INTERVAL), (v) async {
      if (ServerState != null && _interval != null) {
        if (ServerState.systemState == cm.SystemState.QuestionVoting) {
          var secondsElapsed =
              ((CommonUtils.getDateTimeNow(_timeOffset).millisecondsSinceEpoch -
                          ServerState.questionSession.startDate
                              .millisecondsSinceEpoch) /
                      1000)
                  .round();
          if (secondsElapsed > _interval && ServerState.autoEnd) {
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
          if (secondsElapsed > _interval && ServerState.autoEnd) {
            await completeRegistration();
            _isSendState = true;
          }
        }

        if (ServerState.systemState == cm.SystemState.AskWordQueue) {
          var secondsElapsed =
              ((CommonUtils.getDateTimeNow(_timeOffset).millisecondsSinceEpoch -
                          ServerState.askWordQueueSession.startDate
                              .millisecondsSinceEpoch) /
                      1000)
                  .round();
          if ((secondsElapsed > _interval) && ServerState.autoEnd) {
            await completeAskQueue();
            _isSendState = true;
          }
        }

        if (ServerState.storeboardState == cm.StoreboardState.Speaker) {
          var secondsElapsed =
              ((CommonUtils.getDateTimeNow(_timeOffset).millisecondsSinceEpoch -
                          ServerState.speakerSession.startDate
                              .millisecondsSinceEpoch) /
                      1000)
                  .round();
          if ((secondsElapsed > _interval) && ServerState.autoEnd) {
            await completeSpeaker();
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
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} Состояние отправлено на ${_connections.length} клиент за ${stopwatch.elapsedMicroseconds} мкс.');
        stopwatch.reset();
      }
    });

    //connections queue
    _connectionQueue = <io.HttpRequest>[];

    if (USE_CONNECTION_QUEUE) {
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
    }

    // remove connection info if no reconnect
    Timer.periodic(Duration(milliseconds: CONNECTION_INTERVAL), (v) async {
      // check for reconnected
      var reconnected = <WSConnection>[];
      for (var i = 0; i < _tempRemovedConnections.length; i++) {
        if (_connections.any((element) =>
            element.terminalId == _tempRemovedConnections[i].terminalId)) {
          reconnected.add(_tempRemovedConnections[i]);
        }
      }

      // remove reconnected
      for (var i = 0; i < reconnected.length; i++) {
        _tempRemovedConnections.remove(reconnected[i]);
      }

      // remove connection info for old records
      var removed = <WSConnection>[];
      for (var i = 0; i < _tempRemovedConnections.length; i++) {
        if (DateTime.now()
                .difference(_tempRemovedConnections[i].disconnectedTime) >
            Duration(seconds: 20)) {
          removed.add(_tempRemovedConnections[i]);
          removeConnectionInfo(_tempRemovedConnections[i]);
        }
      }

      // remove removed
      for (var i = 0; i < removed.length; i++) {
        _tempRemovedConnections.remove(removed[i]);
      }
    });

    //files upload timer
    Timer.periodic(Duration(milliseconds: _settings.fileSettings.queueInterval),
        (v) async {
      // process documentDownload
      if (ServerState.terminalsForDownload.isNotEmpty) {
        //add new client to download queue
        if (ServerState.terminalsLoadingDocuments.length <
            _settings.fileSettings.queueSize) {
          var freeDownloadSlots = _settings.fileSettings.queueSize -
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
  }

  void upgradeHttpRequest(io.HttpRequest request) async {
    await io.WebSocketTransformer.upgrade(request).then((io.WebSocket ws) {
      ws.pingInterval = Duration(milliseconds: CLIENT_PING_INTERVAL);
      createWSConnection(ws, request);
    },
        onError: (err) => print(
            '${CommonUtils.getDateTimeNow(_timeOffset).toString()} [!]Error -- ${err.toString()}'));
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
      if (USE_CONNECTION_QUEUE &&
          request.headers.value('terminalId') != null &&
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

    var version = request.headers.value('version');

    var connection = WSConnection(
      id: Uuid().v4(),
      type: type,
      terminalId: terminalId,
      version: version,
      socket: webSocket,
    );

    _connections.add(connection);
    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} connected $terminalId');

    if (ENABLE_LOG) {
      final queryInsertLog = Query<SystemLog>(_context)
        ..values.type = connection.type
        ..values.message =
            'Connected id:${connection.id} terminalId:$terminalId'
        ..values.time = DateTime.now();
      await queryInsertLog.insert();
    }

    if (connection.terminalId != null &&
        !ServerState.terminalsOnline.contains(connection.terminalId)) {
      ServerState.terminalsOnline.add(connection.terminalId);
    }

    if (connection.terminalId != null &&
        (connection.type == 'deputy' || connection.type == 'manager')) {
      addUserTerminal(connection.terminalId, connection.deputyId);
    }

    ServerState().setDevicesInfo(_connections);

    sendStateTo(<WSConnection>[connection]);
    _isSendState = true;

    var streamSubscription =
        webSocket.map((string) => json.decode(string)).listen((value) async {
      if (ENABLE_LOG) {
        final queryInsertLog = Query<SystemLog>(_context)
          ..values.type = connection.type
          ..values.message =
              'MESSAGE id:${connection.id} terminalId:${connection.terminalId} value: ${value.toString()}'
          ..values.time = DateTime.now();
        await queryInsertLog.insert();
      }

      if (connection.type == 'stream_player') {
        if (value['refresh_stream'] == 'true') {
          processSetRefreshStream();
        }

        if (value['isStreamStarted'] == true) {
          ServerState.isStreamStarted = true;
          ServerState.streamControl =
              json.decode(value['params'])['stream_control'];
          ServerState.showToManager =
              json.decode(value['params'])['show_to_manager'];
          ServerState.showAskWordButton =
              json.decode(value['params'])['show_askword_button'];

          _isSendState = true;
        }

        if (value['isStreamStarted'] == false) {
          ServerState.isStreamStarted = false;

          _isSendState = true;
        }

        if (value['shutdown_all'] == 'true') {
          processSetShutdownAll();
        }

        if (value['systemState'] != null) {
          await processOperatorMessage(
              EnumToString.fromString(
                  cm.SystemState.values, value['systemState']),
              value['params']);
        }
      }
      if (connection.type == 'operator') {
        var isMessageProcessed = false;

        if (value['play_sound'] != null) {
          ServerState.playSound = value['play_sound'];
          ServerState.playSoundTimestamp =
              CommonUtils.getDateTimeNow(_timeOffset).toString();

          ServerState.soundVolume = value['volume'];
          isMessageProcessed = true;
        } else {
          if (value['volume'] != null) {
            ServerState.soundVolume = value['volume'];
            isMessageProcessed = true;
          }
        }

        if (value['guest'] != null || value['guestTerminalId'] != null) {
          processSetGuest(
            value['guest'],
            value['guestTerminalId'],
          );
          isMessageProcessed = true;
        }
        if (value['remove_guest'] != null) {
          removeGuest(value['remove_guest']);
          isMessageProcessed = true;
        }

        if (value['guest_set_askword'] != null) {
          await processSetGuestAskWord(value['guest_set_askword']);
          isMessageProcessed = true;
        }
        if (value['guest_remove_askword'] != null) {
          await processRemoveGuestAskWord(value['guest_remove_askword']);
          isMessageProcessed = true;
        }

        if (value['terminalId'] != null) {
          if (value['userId'] == null) {
            await processSetUserExit(value['terminalId']);
          } else {
            await processSetUser(
                value['terminalId'], int.tryParse(value['userId']));
          }
          isMessageProcessed = true;
        }

        if (value['userId'] != null) {
          var userConnection = _connections.firstWhere(
              (element) => element.deputyId == value['userId'],
              orElse: () => null);
          if (userConnection != null && ServerState.isRegistrationCompleted) {
            if (value['setRegistration'] == true) {
              await setUserRegistration(userConnection, value['userId']);
            }
            if (value['undoRegistration'] == true) {
              await undoUserRegistration(userConnection, value['userId']);
            }
          }

          isMessageProcessed = true;
        }

        if (value['update_agenda'] != null) {
          await processSaveAgenda(json.encode(value['update_agenda']));
          isMessageProcessed = true;
        }

        if (value['download'] != null) {
          await processDocumentDownload(
              json.decode(value['download']).toList().cast<String>());
          isMessageProcessed = true;
        }

        if (value['download_stop'] != null) {
          await processDocumentDownloadStop();
          isMessageProcessed = true;
        }

        if (value['reset'] != null) {
          processSetTerminalReset(value['pcId']);

          isMessageProcessed = true;
        }
        if (value['shutdown'] != null) {
          processSetTerminalShutdown(value['pcId']);

          isMessageProcessed = true;
        }
        if (value['screen_on'] != null) {
          processSetTerminalScreenOn(value['pcId']);

          isMessageProcessed = true;
        }
        if (value['screen_off'] != null) {
          processSetTerminalScreenOff(value['pcId']);

          isMessageProcessed = true;
        }

        if (value['isDetailsStoreboard'] != null) {
          setDetailsStoreboard(value['isDetailsStoreboard']);

          isMessageProcessed = true;
        }

        if (value['isMicrophoneOn'] != null) {
          setActiveMic(value['speaker'], value['isMicrophoneOn']);

          isMessageProcessed = true;
        }

        if (value['speakerSession'] != null) {
          await processSetSpeakerStoreboard(
            value['speakerSession'],
            value['startSignal'],
            value['endSignal'],
            value['autoEnd'],
          );

          isMessageProcessed = true;
        }

        if (!isMessageProcessed) {
          if (value['isMeetingPreviev'] == true) {
            processSetSchemePreviev(value['meetingId']);
          }

          processSetStoreboard(
              EnumToString.fromString(
                  cm.StoreboardState.values, value['storeboardState']),
              value['storeboardParams']);

          processSetHistory(json.encode(value['voting_history']));

          if (value['refresh_stream'] == 'true') {
            processSetRefreshStream();
          }
          if (value['reset_all'] == 'true') {
            processSetResetAll();
          }
          if (value['shutdown_all'] == 'true') {
            processSetShutdownAll();
          }
          if (value['flush_navigation'] == 'true') {
            processSetFlushNavigation();
          }
          if (value['flush_meeting'] == 'true') {
            await processSetFlushMeeting();
          }

          // Запущен стрим
          if (value['isStreamStarted'] == true) {
            ServerState.isStreamStarted = true;
            ServerState.streamControl =
                json.decode(value['params'])['stream_control'];
            ServerState.showToManager =
                json.decode(value['params'])['show_to_manager'];
            ServerState.showAskWordButton =
                json.decode(value['params'])['show_askword_button'];

            _isSendState = true;
          }

          // стрим остановлен
          if (value['isStreamStarted'] == false) {
            ServerState.isStreamStarted = false;
            _isSendState = true;
          }

          if (value['value'] != null) {
            if (value['value'].toString() == 'ПРОШУ СЛОВА СБРОС ВСЕХ') {
              ServerState.usersAskSpeech = <int>[];
              ServerState.guestsAskSpeech = <String>[];
            } else if (value['value']
                .toString()
                .startsWith('ПРОШУ СЛОВА СБРОС')) {
              var userId = int.parse(value['value']
                  .toString()
                  .replaceFirst('ПРОШУ СЛОВА СБРОС ', ''));
              ServerState.usersAskSpeech
                  .removeWhere((element) => element == userId);

              var connection = _connections.firstWhere(
                  (element) => element.deputyId == userId,
                  orElse: () => null);
              if (connection != null) {
                sendMessage(connection,
                    <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'});
              }
            } else if (value['value']
                .toString()
                .startsWith('ПРОШУ СЛОВА ДЕПУТАТ')) {
              var userId = int.parse(value['value']
                  .toString()
                  .replaceFirst('ПРОШУ СЛОВА ДЕПУТАТ ', ''));
              if (!ServerState.usersAskSpeech.contains(userId)) {
                ServerState.usersAskSpeech.add(userId);
              }

              var connection = _connections.firstWhere(
                  (element) => element.deputyId == userId,
                  orElse: () => null);
              if (connection != null) {
                sendMessage(connection,
                    <String, String>{'askWordStatus': 'ПРОШУ СЛОВА'});
              }

              return true;
            }

            _isSendState = true;
          }

          // установка системного статуса
          if (value['systemState'] != null) {
            await processOperatorMessage(
                EnumToString.fromString(
                    cm.SystemState.values, value['systemState']),
                value['params']);
          }
        }
      }

      if (value['clientType'] != null) {
        await processClientTypeChange(
            connection,
            value['clientType'],
            value['deputyId'],
            value['terminalId'],
            value['isUseAuthCard'],
            value['isWindowsClient']);
        _isSendState = true;
      } else if (connection.type == 'guest') {
        //guest functions
        await processGuestMessage(connection, value['value'].toString());
        if (value['isMicrophoneOn'] != null) {
          setActiveMic(value['speaker'], value['isMicrophoneOn']);
        }
        if (value['guest'] != null || value['guestTerminalId'] != null) {
          processSetGuest(
            value['guest'],
            value['guestTerminalId'],
          );
        }
        if (value['remove_guest'] != null) {
          removeGuest(value['remove_guest']);
        }
      } else if (connection.type == 'deputy' || connection.type == 'manager') {
        // manager and deputy functions
        var isMessageProcessed = await processDeputyMessage(
            connection, value['deputyId'], value['value'].toString());

        if (value['isMicrophoneOn'] != null) {
          setActiveMic(value['speaker'], value['isMicrophoneOn']);

          isMessageProcessed = true;
        }

        // manager functions
        if (connection.type == 'manager') {
          if (value['guest'] != null || value['guestTerminalId'] != null) {
            processSetGuest(
              value['guest'],
              value['guestTerminalId'],
            );
            isMessageProcessed = true;
          }

          if (value['guest_set_askword'] != null) {
            await processSetGuestAskWord(value['guest_set_askword']);
            isMessageProcessed = true;
          }

          if (value['guest_remove_askword'] != null) {
            await processRemoveGuestAskWord(value['guest_remove_askword']);
            isMessageProcessed = true;
          }

          if (value['isDetailsStoreboard'] != null) {
            setDetailsStoreboard(value['isDetailsStoreboard']);

            isMessageProcessed = true;
          }

          if (value['speakerSession'] != null) {
            await processSetSpeakerStoreboard(
              value['speakerSession'],
              value['startSignal'],
              value['endSignal'],
              value['autoEnd'],
            );

            isMessageProcessed = true;
          }

          if (!isMessageProcessed) {
            if (value['isMeetingPreviev'] == true) {
              processSetSchemePreviev(value['meetingId']);
            }

            processSetStoreboard(
                EnumToString.fromString(
                  cm.StoreboardState.values,
                  value['storeboardState'],
                ),
                value['storeboardParams']);

            if (value['flush_navigation'] == 'true') {
              processSetFlushNavigation();
            }
          }
        }
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
      if (ServerState.isStreamStarted) {
        addConnectionForClose(connection);
      } else {
        closeConnection(connection);
      }

      streamSubscription.cancel();
    });
    streamSubscription.onError((err) async {
      print(
          'Connection error:${err.toString()} terminalId:${connection.terminalId}');
      if (ENABLE_LOG) {
        final queryInsertLog = Query<SystemLog>(_context)
          ..values.type = connection.type
          ..values.message =
              'Connection error:${err.toString()} terminalId:${connection.terminalId}'
          ..values.time = DateTime.now();
        await queryInsertLog.insert();
      }

      if (ServerState.isStreamStarted) {
        addConnectionForClose(connection);
      } else {
        closeConnection(connection);
      }

      await streamSubscription.cancel();
    });
  }

  // Sends full server state for operator and manager,
  // otherwise sends short serverState
  void sendStateTo(Iterable<WSConnection> connections) {
    Map<dynamic, dynamic> longState;
    if (connections.isNotEmpty) {
      for (var connection in connections) {
        if (connection.type == 'operator' ||
            connection.type == 'manager' ||
            connection.type == 'deputy' ||
            connection.type == 'guest' ||
            connection.type == 'storeboard' ||
            connection.type == 'stream_player') {
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

      ServerState.usersTerminals.removeWhere((key, value) =>
          key == connection.terminalId || value == connection.deputyId);

      if (ServerState.selectedMeeting != null) {
        if (ServerState.selectedMeeting.group.isUnregisterUserOnExit) {
          undoUserRegistration(connection, connection.deputyId);
        }
        // set user terminal back if it default
        var defaultUserTerminals =
            CommonUtils.getDefaultUsersTerminals(ServerState.selectedMeeting)
                .entries
                .toList();
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

      if (ENABLE_LOG) {
        final queryInsertLog = Query<SystemLog>(_context)
          ..values.type = connection.type
          ..values.message =
              'Disconnected id:${connection.id} terminalId:${connection.terminalId}'
          ..values.time = DateTime.now();
        await queryInsertLog.insert();
      }

      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} disconnected ${connection.terminalId}');
    }
  }

  /// add connection to close queue
  void addConnectionForClose(WSConnection connection) async {
    if (_connections.contains(connection)) {
      connection.disconnectedTime = DateTime.now();
      _connections.remove(connection);
      ServerState.terminalsOnline.remove(connection.terminalId);

      ServerState().setDevicesInfo(_connections);
      _isSendState = true;

      await connection.socket?.close();
      _tempRemovedConnections.add(connection);

      if (ENABLE_LOG) {
        final queryInsertLog = Query<SystemLog>(_context)
          ..values.type = connection.type
          ..values.message =
              'Disconnected id:${connection.id} terminalId:${connection.terminalId}'
          ..values.time = DateTime.now();
        await queryInsertLog.insert();
      }

      print(
          '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} disconnected ${connection.terminalId}');
    }
  }

  void removeConnectionInfo(WSConnection connection) async {
    //ServerState.terminalsOnline.remove(connection.terminalId);
    ServerState.terminalsWithDocuments.remove(connection.terminalId);
    ServerState.usersAskSpeech.remove(connection.deputyId);

    ServerState.usersTerminals.removeWhere((key, value) =>
        key == connection.terminalId || value == connection.deputyId);

    if (ServerState.selectedMeeting != null) {
      if (ServerState.selectedMeeting.group.isUnregisterUserOnExit) {
        undoUserRegistration(connection, connection.deputyId);
      }
      // set user terminal back if it default
      var defaultUserTerminals =
          CommonUtils.getDefaultUsersTerminals(ServerState.selectedMeeting)
              .entries
              .toList();
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

    print(
        '${CommonUtils.getDateTimeNow(_timeOffset).toString()} ${connection.id} ${connection.type} информация удалена ${connection.terminalId}');
  }

  void setActiveMic(String terminalId, bool isEnabled) {
    var userId = ServerState.usersTerminals[terminalId];
    ServerState.usersAskSpeech.remove(userId);

    ServerState.guestsAskSpeech.remove(terminalId);

    if (isEnabled) {
      ServerState.activeMics.putIfAbsent(terminalId,
          () => CommonUtils.getDateTimeNow(_timeOffset).toIso8601String());

      _externalClient.push(terminalId);
    } else {
      ServerState.activeMics.removeWhere((key, value) => key == terminalId);

      _externalClient.remove(terminalId);
    }

    _isSendState = true;
  }

  void removeGuest(String quest) {
    var foundGuestPlace = ServerState.guestsPlaces.firstWhere(
      (element) => element.name == quest,
      orElse: () => null,
    );

    if (foundGuestPlace != null) {
      ServerState.guestsPlaces.remove(foundGuestPlace);
    }

    // update meeting session
    ServerState.meetingSession.guestPlaces =
        json.encode(ServerState.guestsPlaces);

    final updateMeetingSession = Query<MeetingSession>(_context)
      ..values.guestPlaces = ServerState.meetingSession.guestPlaces
      ..where((ms) => ms.id).equalTo(ServerState.meetingSession.id);
    updateMeetingSession.update();
  }

  void removeGuestPlace(String terminalId) {
    if (terminalId == null) {
      return;
    }
    var foundGuestPlace = ServerState.guestsPlaces.firstWhere(
      (element) => element.terminalId == terminalId,
      orElse: () => null,
    );

    if (foundGuestPlace != null) {
      ServerState.guestsPlaces.remove(foundGuestPlace);
    }

    // update meeting session
    ServerState.meetingSession.guestPlaces =
        json.encode(ServerState.guestsPlaces);

    final updateMeetingSession = Query<MeetingSession>(_context)
      ..values.guestPlaces = ServerState.meetingSession.guestPlaces
      ..where((ms) => ms.id).equalTo(ServerState.meetingSession.id);
    updateMeetingSession.update();
  }

  void addUserTerminal(String terminalId, int deputyId) {
    ServerState.usersTerminals
        .removeWhere((key, value) => key == terminalId || value == deputyId);

    if (terminalId != null && deputyId != null) {
      ServerState.usersTerminals.putIfAbsent(terminalId, () => deputyId);
    }
  }

  Future<bool> processGuestMessage(
      WSConnection connection, String value) async {
    if (value == 'ПРОШУ СЛОВА') {
      if (!ServerState.guestsAskSpeech.contains(connection.terminalId)) {
        ServerState.guestsAskSpeech.add(connection.terminalId);
      }

      sendMessage(connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА'});
      return true;
    }
    if (value == 'ПРОШУ СЛОВА СБРОС') {
      ServerState.guestsAskSpeech
          .removeWhere((element) => element == connection.terminalId);
      sendMessage(
          connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'});
      return true;
    }

    return false;
  }

  Future<bool> processDeputyMessage(
      WSConnection connection, int deputyId, String value) async {
    if (ServerState.systemState == cm.SystemState.Registration) {
      if (value == 'ЗАРЕГИСТРИРОВАТЬСЯ') {
        await setUserRegistration(connection, deputyId);
        return true;
      }
      if (value == 'ОТМЕНИТЬ РЕГИСТРАЦИЮ') {
        undoUserRegistration(connection, deputyId);
        return true;
      }
    }

    if (ServerState.systemState == cm.SystemState.QuestionVoting) {
      if (value == 'ЗА' ||
          value == 'ПРОТИВ' ||
          value == 'ВОЗДЕРЖАЛСЯ' ||
          value == 'СБРОС') {
        ServerState.usersDecisions
            .removeWhere((key, value) => key == deputyId.toString());
        ServerState.usersDecisions
            .putIfAbsent(deputyId.toString(), () => value);
        sendMessage(connection, <String, String>{'voting': value});

        // vote for proxies
        var proxy = _proxies.firstWhere(
            (element) => element.proxy.id == deputyId,
            orElse: () => null);
        if (proxy != null) {
          for (var proxyUser in proxy.getVotingSubjects()) {
            ServerState.usersDecisions.removeWhere(
                (key, value) => key == proxyUser.user.id.toString());
            ServerState.usersDecisions
                .putIfAbsent(proxyUser.user.id.toString(), () => value);

            var proxyConnection = _connections.firstWhere(
                (element) => element.deputyId == proxyUser.user.id,
                orElse: () => null);
            if (proxyConnection != null) {
              sendMessage(connection, <String, String>{'voting': value});
            }
          }
        }

        return true;
      }
    }

    if (value == 'ПРОШУ СЛОВА') {
      if (!ServerState.usersAskSpeech.contains(deputyId)) {
        ServerState.usersAskSpeech.add(deputyId);
      }

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
        ServerState.guestsAskSpeech = <String>[];
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
    } else if (value.startsWith('ПРОШУ СЛОВА ДЕПУТАТ')) {
      var userId = int.parse(value.replaceFirst('ПРОШУ СЛОВА ДЕПУТАТ ', ''));

      if (!ServerState.usersAskSpeech.contains(userId)) {
        ServerState.usersAskSpeech.add(userId);
      }

      var connection = _connections.firstWhere(
          (element) => element.deputyId == userId,
          orElse: () => null);
      if (connection != null) {
        sendMessage(
            connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА'});
      }

      return true;
    }

    return false;
  }

  void setUserRegistration(WSConnection connection, int deputyId) async {
    if (ServerState.registrationSession == null) {
      return;
    }

    var registrationsForInsert = <Registration>[];

    if (!ServerState.usersRegistered.contains(deputyId)) {
      ServerState.usersRegistered.add(deputyId);

      var deputyRegistration = Registration();
      deputyRegistration.userId = deputyId;
      deputyRegistration.registrationSession = ServerState.registrationSession;
      registrationsForInsert.add(deputyRegistration);
    }
    sendMessage(
        connection, <String, String>{'registration': 'ЗАРЕГИСТРИРОВАН'});

    // registration for proxies
    var proxy = _proxies.firstWhere((element) => element.proxy.id == deputyId,
        orElse: () => null);
    if (proxy != null) {
      for (var i = 0; i < proxy.getVotingSubjects().length; i++) {
        var proxyUser = proxy.getVotingSubjects()[i];
        if (!ServerState.usersRegistered.contains(proxyUser.user.id)) {
          ServerState.usersRegistered.add(proxyUser.user.id);

          var proxyRegistration = Registration();
          proxyRegistration.userId = proxyUser.user.id;
          proxyRegistration.proxyId = proxy.id;
          proxyRegistration.registrationSession =
              ServerState.registrationSession;
          registrationsForInsert.add(proxyRegistration);
        }

        var proxyConnection = _connections.firstWhere(
            (element) => element.deputyId == proxyUser.user.id,
            orElse: () => null);
        if (proxyConnection != null) {
          sendMessage(
              connection, <String, String>{'registration': 'ЗАРЕГИСТРИРОВАН'});
        }
      }
    }

    for (var i = 0; i < registrationsForInsert.length; i++) {
      var insertRegistrationQuery = Query<Registration>(_context)
        ..values.userId = registrationsForInsert[i].userId
        ..values.proxyId = registrationsForInsert[i].proxyId
        ..values.registrationSession.id =
            registrationsForInsert[i].registrationSession.id;
      unawaited(insertRegistrationQuery.insert());
    }
  }

  void undoUserRegistration(WSConnection connection, int deputyId) async {
    var registrationsForDelete = <Registration>[];

    var deputyRegistration = Registration();
    deputyRegistration.userId = deputyId;
    deputyRegistration.registrationSession = ServerState.registrationSession;
    registrationsForDelete.add(deputyRegistration);

    ServerState.usersRegistered.remove(deputyId);
    sendMessage(
        connection, <String, String>{'registration': 'НЕЗАРЕГИСТРИРОВАН'});

    // registration for proxies
    var proxy = _proxies.firstWhere((element) => element.proxy.id == deputyId,
        orElse: () => null);
    if (proxy != null) {
      for (var proxyUser in proxy.getVotingSubjects()) {
        var proxyRegistration = Registration();
        proxyRegistration.userId = proxyUser.user.id;
        proxyRegistration.registrationSession = ServerState.registrationSession;
        registrationsForDelete.add(proxyRegistration);

        ServerState.usersRegistered.remove(proxyUser.user.id);

        var proxyConnection = _connections.firstWhere(
            (element) => element.deputyId == proxyUser.user.id,
            orElse: () => null);
        if (proxyConnection != null) {
          sendMessage(connection,
              <String, String>{'registration': 'НЕЗАРЕГИСТРИРОВАН'});
        }
      }
    }

    for (var i = 0; i < registrationsForDelete.length; i++) {
      var queryDelete = Query<Registration>(_context)
        ..where((r) => r.userId).equalTo(registrationsForDelete[i].userId)
        ..where((r) => r.registrationSession.id)
            .equalTo(registrationsForDelete[i].registrationSession.id);
      unawaited(queryDelete.delete());
    }
  }

  void sendMessage(WSConnection connection, Map<String, String> message) {
    connection.socket.add(json.encode(message));
  }

  void processDocumentDownload(List<String> terminals) async {
    if (!ServerState.isLoadingDocuments == true) {
      ServerState.terminalsDocumentErrors.clear();
      ServerState.terminalsLoadingDocuments.clear();

      ServerState.terminalsForDownload = terminals;
      ServerState.isLoadingDocuments = true;
      _isSendState = true;
    }
  }

  void processDocumentDownloadStop() async {
    ServerState.terminalsForDownload = <String>[];
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
      bool isWindowsClient) async {
    print(terminalId);

    if (terminalId != null) {
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

    connection.isUseAuthcard = isUseAuthCard == true;
    connection.isWindowsClient = isWindowsClient == true;
    connection.type = clientType;
    ServerState().setDevicesInfo(_connections);

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
        ServerState.usersAskSpeech.remove(connection.deputyId);
        ServerState.usersTerminals.removeWhere((key, value) =>
            key == connection.terminalId || value == connection.deputyId);

        if (ServerState?.selectedMeeting?.group?.isUnregisterUserOnExit ==
            true) {
          undoUserRegistration(connection, connection.deputyId);
        }
      }

      connection.deputyId = deputyId;
    }

    // auto registration
    if (deputyId != null) {
      if (ServerState.selectedMeeting.group.isFastRegistrationUsed ||
          (connection.type == 'deputy' &&
              ServerState.selectedMeeting.group.isDeputyAutoRegistration) ||
          (connection.type == 'manager' &&
              ServerState.selectedMeeting.group.isManagerAutoRegistration)) {
        await setUserRegistration(connection, deputyId);
      }
    }

    // set empty guest place if needed
    if (connection.type == 'guest') {
      var foundPlace = ServerState.guestsPlaces.firstWhere(
          (element) => element.terminalId == connection.terminalId,
          orElse: () => null);

      if (foundPlace == null) {
        ServerState.guestsPlaces
            .add(cm.GuestPlace(name: '', terminalId: connection.terminalId));
      }
    }
    // else {
    //   removeGuestPlace(connection.terminalId);
    // }
  }

  void processSetUser(String terminalId, int userId) async {
    // remove guest askword
    ServerState.guestsAskSpeech.remove(terminalId);

    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);
    if (connection != null && userId != null) {
      // change type of terminal
      var clientType = ServerState.selectedMeeting.group.groupUsers
              .any((element) => element.isManager && element.user.id == userId)
          ? 'manager'
          : 'deputy';
      await processClientTypeChange(
          connection,
          clientType,
          userId,
          connection.terminalId,
          connection.isUseAuthcard,
          connection.isWindowsClient);

      // sent state to connection first
      var sentToConnection = <WSConnection>[];
      sentToConnection.add(connection);
      sendStateTo(sentToConnection);

      sendMessage(connection, <String, String>{'setUser': userId.toString()});
    }

    _isSendState = true;
  }

  void processSetGuestAskWord(String guest) {
    if (!ServerState.guestsAskSpeech.contains(guest)) {
      ServerState.guestsAskSpeech.add(guest);

      var connection = _connections.firstWhere(
          (element) => element.terminalId == guest,
          orElse: () => null);
      if (connection != null) {
        sendMessage(
            connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА'});
      }
    }

    _isSendState = true;
  }

  void processRemoveGuestAskWord(String guest) {
    if (ServerState.guestsAskSpeech.contains(guest)) {
      ServerState.guestsAskSpeech.remove(guest);

      var connection = _connections.firstWhere(
          (element) => element.terminalId == guest,
          orElse: () => null);
      if (connection != null) {
        sendMessage(
            connection, <String, String>{'askWordStatus': 'ПРОШУ СЛОВА СБРОС'});
      }
    }

    _isSendState = true;
  }

  void processSetGuest(String guest, String terminalId) {
    // remove guest based on place
    var guestFoundByPlace = ServerState.guestsPlaces.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    ServerState.guestsAskSpeech.remove(guestFoundByPlace?.name);
    ServerState.guestsPlaces.remove(guestFoundByPlace);

    // remove guest based on name
    var guestFoundByName = ServerState.guestsPlaces
        .firstWhere((element) => element.name == guest, orElse: () => null);

    ServerState.guestsAskSpeech.remove(guestFoundByName?.name);
    ServerState.guestsPlaces.remove(guestFoundByName);

    // add new guest
    if (guest != null && guest.isNotEmpty) {
      ServerState.guestsPlaces
          .add(cm.GuestPlace(name: guest, terminalId: terminalId));
    }

    // update meeting session
    ServerState.meetingSession.guestPlaces =
        json.encode(ServerState.guestsPlaces);

    final updateMeetingSession = Query<MeetingSession>(_context)
      ..values.guestPlaces = ServerState.meetingSession.guestPlaces
      ..where((ms) => ms.id).equalTo(ServerState.meetingSession.id);
    updateMeetingSession.update();

    _isSendState = true;
  }

  void processSetUserExit(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    undoUserRegistration(connection, connection.deputyId);
    if (connection != null) {
      sendMessage(connection, <String, String>{'setUserExit': 'true'});
    }

    _isSendState = true;
  }

  void processSetTerminalReset(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    if (connection != null) {
      sendMessage(connection, <String, String>{'reset': 'true'});
    }
  }

  void processSetTerminalShutdown(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    if (connection != null) {
      sendMessage(connection, <String, String>{'shutdown': 'true'});
    }
  }

  void processSetTerminalScreenOn(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    if (connection != null) {
      sendMessage(connection, <String, String>{'screen_on': 'true'});
    }
  }

  void processSetTerminalScreenOff(String terminalId) {
    var connection = _connections.firstWhere(
        (element) => element.terminalId == terminalId,
        orElse: () => null);

    if (connection != null) {
      sendMessage(connection, <String, String>{'screen_off': 'true'});
    }
  }

  Future<void> processSetSpeakerStoreboard(String speakerSession,
      String signalStart, String signalEnd, bool autoEnd) async {
    if (speakerSession != null) {
      var session = SpeakerSession.fromClient(
          cm.SpeakerSession.fromJson(json.decode(speakerSession)));

      final insertedSpeakerSession = Query<SpeakerSession>(_context)
        ..values.meetingId = session.id
        ..values.userId = session.userId
        ..values.terminalId = session.terminalId
        ..values.name = session.name
        ..values.type = session.type
        ..values.interval = session.interval
        ..values.startDate = CommonUtils.getDateTimeNow(_timeOffset);

      ServerState.speakerSession = await insertedSpeakerSession.insert();
      ServerState.storeboardState = cm.StoreboardState.Speaker;
      ServerState.startSignal = json.decode(signalStart) == null
          ? null
          : cm.Signal.fromJson(json.decode(signalStart));
      ServerState.endSignal = json.decode(signalEnd) == null
          ? null
          : cm.Signal.fromJson(json.decode(signalEnd));
      ServerState.autoEnd = autoEnd;

      _interval = ServerState.speakerSession.interval;

      setActiveMic(session.terminalId, true);
    } else {
      await completeSpeaker();
    }

    _isSendState = true;
  }

  void processSetSchemePreviev(int meetingId) {
    var startedMeeting = _meetings
        .firstWhere((element) => element.id == meetingId, orElse: () => null);

    if (startedMeeting != null) {
      loadDefaultUsersTerminals(startedMeeting);
    }

    _isSendState = true;
  }

  void processSetStoreboard(
      cm.StoreboardState storeboardState, String storeboardParams) {
    ServerState.storeboardState = storeboardState;
    ServerState.storeboardParams = storeboardParams;

    _isSendState = true;
  }

  void setDetailsStoreboard(bool isDetailsStoreboard) {
    ServerState.isDetailsStoreboard = isDetailsStoreboard;

    _isSendState = true;
  }

  void processSetRefreshStream() {
    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        if (connection.type != 'operator' &&
            connection.type != 'stream_player') {
          sendMessage(connection, <String, String>{'refresh_stream': 'true'});
        }
      }
    }
  }

  void processSetResetAll() {
    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        if (connection.type != 'operator' &&
            connection.type != 'storeboard' &&
            connection.type != 'stream_player') {
          sendMessage(connection, <String, String>{'reset': 'true'});
        }
      }
    }
  }

  void processSetShutdownAll() {
    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        if (connection.type != 'operator' &&
            connection.type != 'storeboard' &&
            connection.type != 'stream_player') {
          sendMessage(connection, <String, String>{'shutdown': 'true'});
        }
      }
    }
  }

  void processSetFlushNavigation() {
    if (_connections.isNotEmpty) {
      for (var connection in _connections) {
        if (connection.type != 'operator' &&
            connection.type != 'storeboard' &&
            connection.type != 'stream_player') {
          sendMessage(connection, <String, String>{'flush_navigation': 'true'});
        }
      }
    }
  }

  void processSetFlushMeeting() async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    // update meeting state
    var updateMeeting = Query<Meeting>(_context)
      ..values.status = 'Начато'
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);

    await updateMeeting.update();

    await completeSpeaker();

    ServerState.systemState = cm.SystemState.MeetingStarted;
    ServerState.selectedMeeting.status = 'Начато';
    ServerState.selectedMeeting.lastUpdated = lastUpdated;
    ServerState.selectedQuestion = null;
    ServerState.questionSession = null;
    ServerState.usersDecisions = <String, String>{};

    _isSendState = true;
  }

  void processSetHistory(String value) {
    if (value != null && value.isNotEmpty && value != 'null') {
      ServerState.votingHistory = cm.VotingHistory.fromJson(json.decode(value));
    } else {
      ServerState.votingHistory = null;
    }

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
        ..values.accessRights = question.toJson()['accessRights']
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
        ..values.accessRights = question.toJson()['accessRights']
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

        var insertedFile = await insertedQuestionFile.insert();
        question.files[question.files.indexOf(filesForAdd[j])].id =
            insertedFile.id;
        question.files[question.files.indexOf(filesForAdd[j])].questionId =
            updatedQuestion.id;
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
        if (connection.type != 'stream_player') {
          sendMessage(connection, <String, String>{
            'update_agenda': json.encode(agendaForSave.toJson())
          });
        }
      }
    }

    processDocumentDownloadForAll();
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
      var updatedMeeting =
          await CommonUtils.getMeetingById(_context, meetingId);

      ServerState.systemState = cm.SystemState.MeetingPreparation;
      ServerState.selectedMeeting = updatedMeeting;
      loadDefaultUsersTerminals(ServerState.selectedMeeting);
      ServerState.meetingSession = insertedMeetingSession;
      ServerState.selectedQuestion = null;
      ServerState.questionSession = null;
      ServerState.usersDecisions = <String, String>{};

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
      ServerState.guestsAskSpeech = <String>[];

      ServerState.selectedMeeting = null;
      ServerState.meetingSession = null;
      ServerState.selectedQuestion = null;
      ServerState.questionSession = null;
      ServerState.registrationSession = null;

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
      var updatedMeeting =
          await CommonUtils.getMeetingById(_context, meetingId);

      ServerState.systemState = cm.SystemState.MeetingStarted;
      ServerState.selectedMeeting = updatedMeeting;
      ServerState.meetingSession = updatedMeetingSession;
      ServerState.selectedQuestion = null;
      ServerState.questionSession = null;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersAskSpeech = <int>[];
      ServerState.guestsAskSpeech = <String>[];

      if (ServerState.selectedMeeting.group.isFastRegistrationUsed) {
        await fastRegistration();
        await processSetFlushMeeting();
      }
      return;
    }

    var selectedQuestion = ServerState.selectedMeeting.agenda.questions
        .firstWhere((element) => element.id == questionId, orElse: () => null);
    var votingInterval = json.decode(params)['voting_interval'];
    var registrationInterval = json.decode(params)['registration_interval'];
    var askWordQueueInterval = json.decode(params)['askwordqueue_interval'];
    var votingModeId = json.decode(params)['voting_mode_id'];
    var votingDecision = json.decode(params)['voting_decision'];
    var successCount = json.decode(params)['success_count'];
    var votingRegim = json.decode(params)['voting_regim'];

    // Регистрация
    if (systemState == cm.SystemState.Registration) {
      if (ServerState.selectedMeeting.group.isFastRegistrationUsed) {
        await fastRegistration();
        return;
      }

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

      await completeSpeaker();
      ServerState.systemState = cm.SystemState.Registration;
      updateServerStateMeeting(updatedMeeting);
      ServerState.registrationSession = insertedRegistrationSession;
      ServerState.usersDecisions = <String, String>{};
      ServerState.usersRegistered = <int>[];
      ServerState.usersAskSpeech = <int>[];
      ServerState.guestsAskSpeech = <String>[];

      ServerState.startSignal = json
                  .decode(json.decode(params)['startSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['startSignal']));
      ServerState.endSignal = json.decode(json.decode(params)['endSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['endSignal']));

      ServerState.autoEnd = json.decode(params)['autoEnd'];

      return;
    }

    // Регистрация завершена
    if (systemState == cm.SystemState.RegistrationComplete) {
      await completeRegistration();
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
        ServerState.guestsAskSpeech = <String>[];
      }

      ServerState.questionSession = null;
      ServerState.usersDecisions = <String, String>{};
      return;
    }

    // Голосование
    if (systemState == cm.SystemState.QuestionVoting) {
      var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
      _interval = votingInterval;

      final insertQuestionSession = Query<QuestionSession>(_context)
        ..values.meetingSessionId = ServerState.meetingSession.id
        ..values.questionId = questionId
        ..values.votingRegim = votingRegim
        ..values.interval = _interval
        ..values.votingModeId = votingModeId
        ..values.decision = votingDecision
        ..values.usersCountRegistred = ServerState.usersRegistered.length
        ..values.usersCountForSuccess = successCount
        ..values.usersCountForSuccessDisplay = successCount
        ..values.startDate = lastUpdated;
      var insertedQuestionSession = await insertQuestionSession.insert();

      var query = Query<Meeting>(_context)
        ..values.status =
            'Голосование ${selectedQuestion.name} ${selectedQuestion.orderNum}'
        ..values.lastUpdated = lastUpdated
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await query.update()).first;

      await completeSpeaker();
      ServerState.systemState = cm.SystemState.QuestionVoting;
      updateServerStateMeeting(updatedMeeting);
      ServerState.questionSession = insertedQuestionSession;
      ServerState.usersDecisions = <String, String>{};
      //ServerState.usersAskSpeech = <int>[];
      //ServerState.guestsAskSpeech = <String>[];

      ServerState.startSignal = json
                  .decode(json.decode(params)['startSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['startSignal']));
      ServerState.endSignal = json.decode(json.decode(params)['endSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['endSignal']));
      ServerState.autoEnd = json.decode(params)['autoEnd'];

      return;
    }

    // Голосование завершено
    if (systemState == cm.SystemState.QuestionVotingComplete) {
      await completeVoting(selectedQuestion);
      return;
    }

    // Запись в очередь начата
    if (systemState == cm.SystemState.AskWordQueue) {
      var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
      _interval = askWordQueueInterval;

      final insertAskWordQueueSession = Query<AskWordQueueSession>(_context)
        ..values.meetingSessionId = ServerState.meetingSession.id
        ..values.questionId = questionId
        ..values.interval = _interval
        ..values.votingModeId = votingModeId
        ..values.decision = votingDecision
        ..values.startDate = lastUpdated
        ..values.users = '';

      var insertedAskWordQueueSession =
          await insertAskWordQueueSession.insert();

      var updateMeeting = Query<Meeting>(_context)
        ..values.status =
            'Запись в очередь на выступление ${selectedQuestion.name} ${selectedQuestion.orderNum}'
        ..values.lastUpdated = lastUpdated
        ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
      var updatedMeeting = (await updateMeeting.update()).first;

      await completeSpeaker();
      ServerState.systemState = cm.SystemState.AskWordQueue;
      updateServerStateMeeting(updatedMeeting);
      ServerState.askWordQueueSession = insertedAskWordQueueSession;

      ServerState.usersAskSpeech = <int>[];
      ServerState.guestsAskSpeech = <String>[];

      ServerState.startSignal = json
                  .decode(json.decode(params)['startSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['startSignal']));
      ServerState.endSignal = json.decode(json.decode(params)['endSignal']) ==
              null
          ? null
          : cm.Signal.fromJson(json.decode(json.decode(params)['endSignal']));

      ServerState.autoEnd = json.decode(params)['autoEnd'];

      return;
    }

    // Запись в очередь завершена
    if (systemState == cm.SystemState.AskWordQueueCompleted) {
      await completeAskQueue();
      return;
    }

    // Заседание завершено
    if (systemState == cm.SystemState.MeetingCompleted) {
      var endDate = CommonUtils.getDateTimeNow(_timeOffset);

      final updateMeetingSessionStart = Query<MeetingSession>(_context)
        ..values.startDate = endDate
        ..where((ms) => ms.meetingId).equalTo(meetingId)
        ..where((ms) => ms.startDate).isNull();
      await updateMeetingSessionStart.update();

      final updateMeetingSessionEnd = Query<MeetingSession>(_context)
        ..values.endDate = endDate
        ..where((ms) => ms.meetingId).equalTo(meetingId)
        ..where((ms) => ms.endDate).isNull();
      await updateMeetingSessionEnd.update();

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
      ServerState.guestsAskSpeech = <String>[];
      ServerState.selectedMeeting = null;
      ServerState.meetingSession = null;
      ServerState.selectedQuestion = null;
      ServerState.questionSession = null;
      ServerState.registrationSession = null;

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

    ServerState.isRegistrationCompleted = true;
    ServerState.systemState = cm.SystemState.RegistrationComplete;
    updateServerStateMeeting(updatedMeeting);
    ServerState.registrationSession = updatedRegistationSession;
    ServerState.registrationResult = ServerState.usersRegistered.length;
  }

  Future fastRegistration() async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);

    final insertRegistrationSession = Query<RegistrationSession>(_context)
      ..values.meetingId = ServerState.selectedMeeting.id
      ..values.interval = 0
      ..values.startDate = lastUpdated;
    var insertedRegistrationSession = await insertRegistrationSession.insert();

    await completeSpeaker();
    ServerState.systemState = cm.SystemState.Registration;
    ServerState.registrationSession = insertedRegistrationSession;
    ServerState.usersDecisions = <String, String>{};
    ServerState.usersRegistered = <int>[];
    ServerState.usersAskSpeech = <int>[];
    ServerState.guestsAskSpeech = <String>[];

    if (ServerState.usersTerminals.isNotEmpty) {
      for (var userTerminal in ServerState.usersTerminals.entries) {
        if (ServerState.terminalsOnline.contains(userTerminal.key) &&
            userTerminal.value != null &&
            !ServerState.usersRegistered.contains(userTerminal.value)) {
          ServerState.usersRegistered.add(userTerminal.value);
        }
      }
    }

    await completeRegistration();
  }

  Future completeVoting(Question selectedQuestion) async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    _interval = null;

    ServerState.questionSession.managerId = cm.GroupUtil().getManagerId(
        ServerState.selectedMeeting.group.toClient(),
        ServerState.usersTerminals);

    var registredAndOnline = <int>[];
    // Set user voted indifferent if it registered and not voted
    for (var i = 0; i < ServerState.usersRegistered.length; i++) {
      //is online
      if (!ServerState.usersTerminals
          .containsValue(ServerState.usersRegistered[i])) {
        continue;
      }

      registredAndOnline.add(ServerState.usersRegistered[i]);
    }

    // update success count for registered and online users
    var isManagerVoted = ServerState.usersDecisions.entries.firstWhere(
          (element) =>
              element.key == ServerState.questionSession.managerId.toString() &&
              (element.value == 'ЗА' || element.value == 'ПРОТИВ'),
          orElse: () => null,
        ) !=
        null;
    ServerState.questionSession.usersCountRegistred = registredAndOnline.length;
    if ((DecisionModeHelper.getEnumValue(
                ServerState.questionSession.decision) ==
            cm.DecisionMode.MajorityOfRegistredMembers) ||
        (DecisionModeHelper.getEnumValue(
                ServerState.questionSession.decision) ==
            cm.DecisionMode.TwoThirdsOfRegistredMembers) ||
        (DecisionModeHelper.getEnumValue(
                ServerState.questionSession.decision) ==
            cm.DecisionMode.OneThirdsOfRegistredMembers)) {
      ServerState.questionSession.usersCountForSuccess =
          DecisionModeHelper.getSuccuessValue(
              DecisionModeHelper.getEnumValue(
                  ServerState.questionSession.decision),
              ServerState.selectedMeeting.group.toClient(),
              registredAndOnline,
              isManagerVoted);
    }

    // Set user voted indifferent if it registered and not voted
    for (var i = 0; i < registredAndOnline.length; i++) {
      var foundDecision = ServerState.usersDecisions.entries.firstWhere(
          (element) => element.key == registredAndOnline[i].toString(),
          orElse: () => null);

      if (foundDecision == null) {
        ServerState.usersDecisions
            .putIfAbsent(registredAndOnline[i].toString(), () => 'ВОЗДЕРЖАЛСЯ');
      }
    }

    if (ServerState.usersDecisions.entries.isNotEmpty) {
      for (var decision in ServerState.usersDecisions.entries) {
        var proxy = _proxies.firstWhere(
            (element) => element.proxy.id.toString() == decision.key,
            orElse: () => null);

        var insertDecisionQuery = Query<Result>(_context)
          ..values.questionSession.id = ServerState.questionSession.id
          ..values.userId = int.parse(decision.key)
          ..values.proxyId = proxy?.id
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
      ..values.managerId = cm.GroupUtil().getManagerId(
          ServerState.selectedMeeting.group.toClient(),
          ServerState.usersTerminals)
      ..values.usersCountRegistred =
          ServerState.questionSession.usersCountRegistred
      ..values.usersCountForSuccess =
          ServerState.questionSession.usersCountForSuccess
      ..values.endDate = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.questionSession.id);
    var updatedQuestionSession = (await updateQuestionSession.update()).first;

    var query = Query<Meeting>(_context)
      ..values.status =
          'Голосование ${selectedQuestion.name} ${selectedQuestion.orderNum} завершено'
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
    var updatedMeeting = (await query.update()).first;

    ServerState.systemState = cm.SystemState.QuestionVotingComplete;
    updateServerStateMeeting(updatedMeeting);
    ServerState.questionSession = updatedQuestionSession;

    ServerState.votingResultYes = ServerState.usersDecisions.values
        .where((element) => element == 'ЗА')
        .length;
    ServerState.votingResultNo = ServerState.usersDecisions.values
        .where((element) => element == 'ПРОТИВ')
        .length;
    ServerState.votingResultIndiffirent = ServerState.usersDecisions.values
        .where((element) => element == 'ВОЗДЕРЖАЛСЯ')
        .length;
    ServerState.votingTotalVotes = ServerState.usersDecisions.values
        .where((element) => element != 'СБРОС')
        .length;
  }

  Future completeAskQueue() async {
    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    _interval = null;

    var updateAskWordSession = Query<AskWordQueueSession>(_context)
      ..values.endDate = lastUpdated
      ..values.users = ServerState.usersAskSpeech.join(',')
      ..where((u) => u.id).equalTo(ServerState.askWordQueueSession.id);
    var updatedAskWordSession = (await updateAskWordSession.update()).first;

    var updateMeeting = Query<Meeting>(_context)
      ..values.status = ServerState.selectedMeeting.status + ' завершена'
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
    var updatedMeeting = (await updateMeeting.update()).first;

    ServerState.askWordQueueSession = updatedAskWordSession;
    ServerState.systemState = cm.SystemState.AskWordQueueCompleted;
    updateServerStateMeeting(updatedMeeting);
  }

  Future completeSpeaker() async {
    if (ServerState.speakerSession == null) {
      return;
    }

    var lastUpdated = CommonUtils.getDateTimeNow(_timeOffset);
    _interval = null;

    var updateSpeakerSession = Query<SpeakerSession>(_context)
      ..values.endDate = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.speakerSession.id);
    var updatedSpeakerSession = (await updateSpeakerSession.update()).first;

    var updateMeeting = Query<Meeting>(_context)
      ..values.lastUpdated = lastUpdated
      ..where((u) => u.id).equalTo(ServerState.selectedMeeting.id);
    var updatedMeeting = (await updateMeeting.update()).first;

    ServerState.activeMics.removeWhere(
        (key, value) => key == ServerState.speakerSession.terminalId);
    _externalClient.remove(ServerState.speakerSession.terminalId);

    ServerState.storeboardState = cm.StoreboardState.None;
    updateServerStateMeeting(updatedMeeting);
    ServerState.speakerSession = null;
    ServerState.startSignal = null;
    ServerState.endSignal = null;

    _isSendState = true;
  }

  void loadDefaultUsersTerminals(Meeting meeting) {
    var defaultUserTerminals =
        CommonUtils.getDefaultUsersTerminals(meeting).entries.toList();

    for (var i = 0; i < defaultUserTerminals.length; i++) {
      if (!ServerState.usersTerminals.entries.any((element) =>
          element.key == defaultUserTerminals[i].key &&
          element.value == defaultUserTerminals[i].value)) {
        addUserTerminal(
            defaultUserTerminals[i].key, defaultUserTerminals[i].value);
      }
    }
  }
}
