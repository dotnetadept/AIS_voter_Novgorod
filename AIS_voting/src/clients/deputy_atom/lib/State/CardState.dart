import 'dart:async';
import 'package:ais_model/ais_model.dart';
import 'package:jacarta_token/jacarta_token.dart';
import 'AppState.dart';

class CardState {
  static var _refresh = false;

  static void setRefresh(bool refresh) {
    _refresh = refresh;
  }

  static bool get getRefresh => _refresh;

  static void init() {
    JacartaTokenPlugin.initialize();
  }

  static Future<bool> isCardOn() async {
    var slotsCount = await JacartaTokenPlugin.getSlots();
    return slotsCount != null && slotsCount > 0;
  }

  static Future<User> updateCardUser() async {
    var token = await JacartaTokenPlugin.getToken();

    if (AppState().getCurrentMeeting() == null) {
      return null;
    }
    var foundUser = AppState()
        .getUsers()
        .firstWhere((element) => element.cardId == token, orElse: () => null);

    // check if user in group
    if (foundUser != null &&
        (AppState().getCurrentMeeting() == null ||
            !AppState()
                .getCurrentMeeting()
                .group
                .groupUsers
                .any((element) => element.user.id == foundUser.id))) {
      foundUser = null;
    }

    _refresh = false;

    return foundUser;
  }
}
