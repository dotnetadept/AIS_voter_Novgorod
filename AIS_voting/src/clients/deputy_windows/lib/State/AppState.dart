import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:flutter/material.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:ais_model/ais_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:global_configuration/global_configuration.dart';

class AppState with ChangeNotifier {
  static String _terminalId;
  static WebSocketChannel _channel;
  static ServerState _serverState;

  static List<User> _users;
  static User _currentUser;
  static Meeting _currentMeeting;
  static Settings _settings;
  static int _timeOffset;
  static bool _isLoadingComplete = false;

  static bool _isRegistred = false;
  static String _decision;
  static bool _askWordStatus = false;

  static String _currentPage = '';
  static SharedPreferences _prefs;

  static double _displayScale;

  static AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }

  AppState._internal() {}

  Future<void> loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadData(int meetingId) async {
    await loadPrefs().then((value) async {
      await http
          .get(Uri.parse(
              ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                  "/settings"))
          .then((response) {
            var settings = (json.decode(response.body) as List)
                .map((data) => Settings.fromJson(data))
                .toList()
                .first;
            AppState().setSettings(settings);
          })
          .then((value) async => {
                await NTP
                    .getNtpOffset(
                        localTime: DateTime.now(),
                        lookUpAddress:
                            GlobalConfiguration().getValue('ntp_server'))
                    .then((value) => {AppState().setTimeOffset(value)})
              })
          .then((value) async => await http
                  .get(Uri.parse(
                      ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                          "/users"))
                  .then((response) {
                var users = (json.decode(response.body) as List)
                    .map((data) => User.fromJson(data))
                    .toList();
                AppState().setUsers(users);
              }))
          .then((value) async {
            await http
                .get(Uri.parse(
                    ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                        '/meetings/$meetingId'))
                .then((response) {
              AppState().setCurrentMeeting(
                  Meeting.fromJson(json.decode(response.body)));

              setIsLoadingComplete(true);
            });
          });
    });
  }

  void setDisplayScale(double displayScale) {
    _displayScale = displayScale;
  }

  double getDisplayScale() {
    return _displayScale;
  }

  double getScaledSize(double size) {
    return (size / _displayScale).ceilToDouble();
  }

  double getHalfScaledSize(double size) {
    double halfScale = (_displayScale - 1) / 2;
    return (size / (1 + halfScale)).ceilToDouble();
  }

  int getTimeOffset() {
    return _timeOffset;
  }

  void setTimeOffset(int timeOffset) {
    _timeOffset = timeOffset;
  }

  String getTerminalId() {
    return _terminalId;
  }

  void setTerminalId(String terminalId) {
    _terminalId = terminalId;
  }

  String getSavedPassword() {
    return _prefs.getString('password') ?? '';
  }

  void setSavedPassword(String password) {
    _prefs.setString('password', password);
  }

  String getCurrentPage() {
    return _currentPage;
  }

  void setCurrentPage(String value) {
    _currentPage = value;
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

  User getCurrentUser() {
    return _currentUser;
  }

  void setCurrentUser(User user) {
    _currentUser = user;

    notifyListeners();
  }

  List<User> getUsers() {
    return _users;
  }

  void setUsers(List<User> users) {
    _users = users;
  }

  Meeting getCurrentMeeting() {
    return _currentMeeting;
  }

  void setCurrentMeeting(Meeting meeting) {
    _currentMeeting = meeting;
    if (_currentMeeting != null &&
        _currentMeeting.agenda.questions.length > 0) {
      _currentMeeting.agenda.questions
          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
    }

    notifyListeners();
  }

  Settings getSettings() {
    return _settings;
  }

  void setSettings(Settings settings) {
    _settings = settings;

    // adjust settings to display scale
    _settings.storeboardSettings.height = AppState()
        .getScaledSize(_settings.storeboardSettings.height.toDouble())
        .ceil();
    _settings.storeboardSettings.width = AppState()
        .getScaledSize(_settings.storeboardSettings.width.toDouble())
        .ceil();
    _settings.storeboardSettings.padding = AppState()
        .getHalfScaledSize(_settings.storeboardSettings.padding.toDouble())
        .ceil();

    _settings.storeboardSettings.clockFontSize = AppState()
        .getScaledSize(_settings.storeboardSettings.clockFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.customCaptionFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.customCaptionFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.customTextFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.customTextFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.detailsFontSize = AppState()
        .getScaledSize(_settings.storeboardSettings.detailsFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.groupFontSize = AppState()
        .getScaledSize(_settings.storeboardSettings.groupFontSize.toDouble())
        .ceil();

    _settings.storeboardSettings.meetingDescriptionFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.meetingDescriptionFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.meetingFontSize = AppState()
        .getScaledSize(_settings.storeboardSettings.meetingFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.questionDescriptionFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.questionDescriptionFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.questionNameFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.questionNameFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.questionNameFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.questionNameFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.resultItemsFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.resultItemsFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.resultTotalFontSize = AppState()
        .getScaledSize(
            _settings.storeboardSettings.resultTotalFontSize.toDouble())
        .ceil();
    _settings.storeboardSettings.timersFontSize = AppState()
        .getScaledSize(_settings.storeboardSettings.timersFontSize.toDouble())
        .ceil();
  }

  WebSocketChannel getWsChannel() {
    return _channel;
  }

  void setWsChannel(WebSocketChannel channel) {
    _channel = channel;
  }

  bool getIsRegistred() {
    return _isRegistred;
  }

  void setIsRegistred(bool value) {
    _isRegistred = value;

    notifyListeners();
  }

  String getDecision() {
    return _decision;
  }

  void setDecision(String value) {
    _decision = value;

    notifyListeners();
  }

  bool getAskWordStatus() {
    return _askWordStatus;
  }

  void setAskWordStatus(bool value) {
    _askWordStatus = value;

    notifyListeners();
  }
}
