import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:operator_panel/Providers/SoundPlayer.dart';

import 'WebSocketConnection.dart';

class AppState with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;

  void Function() navigateUsersPage;
  void Function() navigateGroupsPage;
  void Function() navigateProxiesPage;
  void Function() navigateAgendasPage;
  void Function() navigateSettingsPage;
  void Function() navigateMeetingsPage;
  void Function() navigateHistoryPage;

  void Function(void Function() f) refreshDialog;

  void Function() onStartStream;
  void Function() onLoadDocuments;

  List<Signal> _signals;
  List<ais.Interval> _intervals;
  ais.Interval _selectedInterval;
  bool _autoEnd = false;
  double _volume = 100.0;

  void setSignals(List<Signal> signals) {
    _signals = signals;
  }

  List<Signal> getSignals() {
    return _signals;
  }

  void setIntervals(List<ais.Interval> intervals) {
    _intervals = intervals;
  }

  List<ais.Interval> getIntervals() {
    return _intervals;
  }

  void setInterval(ais.Interval selectedInterval) {
    _selectedInterval = selectedInterval;
    if (selectedInterval != null) {
      setAutoEnd(selectedInterval.isAutoEnd);
    }

    notifyListeners();
  }

  ais.Interval getSelectedInterval() {
    return _selectedInterval;
  }

  void setAutoEnd(bool autoEnd) {
    _autoEnd = autoEnd;

    notifyListeners();
  }

  bool getAutoEnd() {
    return _autoEnd;
  }

  void setVolume(double volume) {
    _volume = volume;
    WebSocketConnection.getInstance().setVolume(volume);
    SoundPlayer.setVolume(volume);

    notifyListeners();
  }

  double getVolume() {
    return _volume;
  }

  bool isLoadingComplete = false;
  bool getIsLoadingComplete() {
    return isLoadingComplete;
  }

  void setIsLoadingComplete(bool isLoadingComplete) {
    this.isLoadingComplete = isLoadingComplete;
    //notifyListeners();
  }

  static AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = AppState._internal(navigatorKey: navigatorKey);
  }

  AppState._internal({this.navigatorKey});

  navigateMainPage() async {
    navigatorKey.currentState.pushNamed('/main');
  }
}
