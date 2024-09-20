import 'dart:convert';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:ntp/ntp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:storeboard/State/SoundPlayer.dart';
import 'package:storeboard/Utils/stream_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';

class AppState with ChangeNotifier {
  static late ServerState _serverState;

  static late List<VotingMode> _votingModes;
  static late List<User> _users;
  static Meeting? _currentMeeting;
  static Settings? _settings;
  static late int _timeOffset;
  static bool _isOnline = false;
  static bool _isLoadingComplete = false;

  static bool _isLoadingInProgress = false;
  static String _currentPage = '';

  static AppState _singleton = AppState._internal();

  // selected agenda items
  static Question? _currentQuestion;

  //stream
  static Future<void> Function()? refreshStream;

  factory AppState() {
    return _singleton;
  }

  AppState._internal();

  Future<void> loadData(int? meetingId, int? selectedQuestionId) async {
    if (meetingId != null) {
      await http
          .get(Uri.http(
              ServerConnection.getHttpServerUrl(GlobalConfiguration()),
              '/meetings/$meetingId'))
          .then((response) {
        _currentMeeting = Meeting.fromJson(json.decode(response.body));
        _currentQuestion = _currentMeeting?.agenda?.questions
            .firstWhereOrNull((element) => element.id == selectedQuestionId);
      });
    } else {
      _currentMeeting = null;
      _currentQuestion = null;
    }

    await http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/settings'))
        .then((response) {
      _settings = (json.decode(response.body) as List)
          .map((data) => Settings.fromJson(data))
          .toList()
          .firstWhere((element) => element.isSelected);

      SoundPlayer.setIsActive(_settings!.signalsSettings.isStoreboardPlaySound);
    });
    await http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/voting_modes"))
        .then((response) {
      _votingModes = (json.decode(response.body) as List)
          .map((data) => VotingMode.fromJson(data))
          .toList();
    });
    await http
        .get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"))
        .then((response) {
      _users = (json.decode(response.body) as List)
          .map((data) => User.fromJson(data))
          .toList();

      _users.sort((a, b) => a.getShortName().compareTo(b.getShortName()));
    });
    await http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/signals"))
        .then((response) {
      var signals = (json.decode(response.body) as List)
          .map((data) => Signal.fromJson(data))
          .toList();

      for (int i = 0; i < signals.length; i++) {
        if (signals[i].soundPath != null && signals[i].soundPath.isNotEmpty) {
          SoundPlayer.loadSound(signals[i].soundPath, signals[i].id.toString());
        }
      }

      SoundPlayer.loadSound(_settings!.signalsSettings.hymnStart, 'hymn_start');
      SoundPlayer.loadSound(_settings!.signalsSettings.hymnEnd, 'hymn_end');
    });
    await NTP
        .getNtpOffset(
            localTime: DateTime.now(),
            lookUpAddress: GlobalConfiguration().getValue('ntp_server'),
            timeout: Duration(seconds: 10))
        .onError((error, stackTrace) {
      print(
          'Отсутствует синхронизация с сервером времени. ${error.toString()} ${stackTrace.toString()}');
      return 0;
    }).then((offset) {
      _timeOffset = offset;
      setIsLoadingComplete(true);
    });
  }

  String getCurrentPage() {
    return _currentPage;
  }

  void setCurrentPage(String value) {
    _currentPage = value;
  }

  bool getIsOnline() {
    return _isOnline;
  }

  void setIsOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
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

  List<VotingMode> getVotingModes() {
    return _votingModes;
  }

  List<User> getUsers() {
    return _users;
  }

  Meeting? getCurrentMeeting() {
    return _currentMeeting;
  }

  void setCurrentMeeting(Meeting? meeting) {
    _currentMeeting = meeting;
    if (_currentMeeting != null &&
        _currentMeeting!.agenda!.questions.length > 0) {
      _currentMeeting!.agenda!.questions
          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
    }

    notifyListeners();
  }

  void setCurrentQuestion(Question? question) {
    _currentQuestion = question;
  }

  Question? getCurrentQuestion() {
    return _currentQuestion;
  }

  Settings? getSettings() {
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

  bool getIsLoadingInProgress() {
    return _isLoadingInProgress;
  }

  void setIsLoadingInProgress(bool isInProgress) {
    _isLoadingInProgress = isInProgress;
  }
}
