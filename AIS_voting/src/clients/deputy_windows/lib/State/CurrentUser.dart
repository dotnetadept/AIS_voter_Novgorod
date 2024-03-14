import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'AppState.dart';

class CurrentUser with ChangeNotifier {
  var _currentUser;

  CurrentUser(User currentUser) {
    setCurrentUser(currentUser);
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    AppState().setCurrentUser(_currentUser);
    notifyListeners();
  }

  User get getCurrentUser => _currentUser;
}
