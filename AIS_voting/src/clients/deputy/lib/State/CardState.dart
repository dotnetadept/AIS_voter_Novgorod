import 'dart:async';
import 'package:ais_model/ais_model.dart';
import 'package:jacarta_token/jacarta_token.dart';
import 'package:uuid/uuid.dart';
import 'AppState.dart';

class CardState {
  static var _refresh = false;

  static var _isJacartaEnabled = false;

  static void setRefresh(bool refresh) {
    _refresh = refresh;
  }

  static bool get getRefresh => _refresh;

  static void init() {
    // Init flag from build enviroment argument
    const isJacartaEnabled = bool.fromEnvironment("JACARTA_ENABLED");

    _isJacartaEnabled = isJacartaEnabled;

    if (_isJacartaEnabled) {
      JacartaTokenPlugin.initialize();
    }
  }

  static Future<bool> isCardOn() async {
    var slotsCount = 0;

    if (_isJacartaEnabled) {
      slotsCount = await JacartaTokenPlugin.getSlots();
    }

    return slotsCount != null && slotsCount > 0;
  }

  static Future<User> updateCardUser() async {
    var token = Uuid().v4();
    if (_isJacartaEnabled) {
      token = await JacartaTokenPlugin.getToken();
    }

    if (AppState().getCurrentMeeting() == null) {
      return null;
    }

    var foundUser = AppState()
        .getUsers()
        .firstWhere((element) => element.cardId == token, orElse: () => null);

    _refresh = false;

    return foundUser;
  }
}
