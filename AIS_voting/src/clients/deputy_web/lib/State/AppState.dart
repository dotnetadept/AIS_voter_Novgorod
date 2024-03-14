import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

class AppState with ChangeNotifier {
  static AppState _singleton;

  static ServerState _serverState;

  GlobalKey<NavigatorState> navigatorKey;

  static List<User> _users;
  static User _currentUser;
  static List<Meeting> _meetings;
  static Settings _settings;
  static bool _isLoadingComplete = false;

  // selected agenda items
  static Meeting _selectedMeeting;
  static Question _selectedQuestion;
  static QuestionFile _selectedQuestionFile;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = AppState(navigatorKey: navigatorKey);
  }

  static AppState getInstance() {
    return _singleton;
  }

  AppState({this.navigatorKey});

  Future<void> loadData() async {
    String settings = await rootBundle.loadString('assets/cfg/settings.json');
    AppState().setSettings((json.decode(settings) as List)
        .map((data) => Settings.fromJson(data))
        .toList()
        .first);

    String users = await rootBundle.loadString('assets/cfg/users.json');
    AppState().setUsers((json.decode(users) as List)
        .map((data) => User.fromJson(data))
        .toList());

    String meetings = await rootBundle.loadString('assets/cfg/meetings.json');
    AppState().setMeetings((json.decode(meetings) as List)
        .map((data) => Meeting.fromJson(data))
        .toList());

    setIsLoadingComplete(true);

    await navigatorKey.currentState.pushNamedAndRemoveUntil(
        '/viewAgenda', (Route<dynamic> route) => false);
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

  List<Meeting> getMeetings() {
    return _meetings;
  }

  void setMeetings(List<Meeting> meetings) {
    _meetings = meetings;
    notifyListeners();
  }

  Settings getSettings() {
    return _settings;
  }

  void setSettings(Settings settings) {
    _settings = settings;
  }

  Meeting getSelectedMeeting() {
    return _selectedMeeting;
  }

  void setSelectedMeeting(Meeting meeting) {
    _selectedMeeting = meeting;
  }

  Question getSelectedQuestion() {
    return _selectedQuestion;
  }

  void setSelectedQuestion(Question question) {
    _selectedQuestion = question;
  }

  QuestionFile getSelectedQuestionFile() {
    return _selectedQuestionFile;
  }

  void setSelectedQuestionFile(QuestionFile file) {
    _selectedQuestionFile = file;
  }
}
