import 'dart:convert';

import 'package:ais_model/ais_model.dart' show Workplaces;

import 'server_state.dart';

class CommonUtils {
  static DateTime getDateTimeNow(int clientTimeOffset) {
    return DateTime.now().add(Duration(milliseconds: clientTimeOffset));
  }

  static Map<String, int> getDefaultUsersTerminals() {
    var defaultUsersTerminals = <String, int>{};

    if (ServerState.selectedMeeting == null) {
      return defaultUsersTerminals;
    }

    var workplaces = Workplaces.fromJson(
        json.decode(ServerState.selectedMeeting.group.workplaces));

    if (workplaces != null) {
      for (var i = 0; i < workplaces.managementPlacesCount; i++) {
        if (workplaces.managementTerminalIds[i] != null) {
          defaultUsersTerminals.putIfAbsent(
              workplaces.managementTerminalIds[i].toString(),
              () => workplaces.schemeManagement[i]);
        }

        for (var i = 0; i < workplaces.rows.length; i++) {
          var row = workplaces.rows[i];
          for (var j = 0; j < row; j++) {
            if (workplaces.workplacesTerminalIds[i][j] != null) {
              defaultUsersTerminals.putIfAbsent(
                  workplaces.workplacesTerminalIds[i][j].toString(),
                  () => workplaces.schemeWorkplaces[i][j]);
            }
          }
        }
      }
    }

    return defaultUsersTerminals;
  }

  // list of unblocked mics from group setting  + list of managers terminals
  static List<int> getUnblockedMicsList() {
    var result = <int>[];

    if (ServerState.selectedMeeting == null) {
      return result;
    }

    // add mics from group setting
    var parts = ServerState.selectedMeeting.group.unblockedMics.split(',');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result.add(int.parse(parts[i]));
      }
    }

    // add managers mics
    var managerIds = ServerState.selectedMeeting.group.groupUsers
        .where((element) => element.isManager)
        .map((e) => e.user.id)
        .toList();
    var managerTerminals = ServerState.usersTerminals.entries
        .where((element) => managerIds.contains(element.value))
        .toList();

    for (var i = 0; i < managerTerminals.length; i++) {
      var parts = managerTerminals[i].key.split(',');
      for (var j = 0; j < parts.length; j++) {
        if (parts[i].isNotEmpty) {
          result.add(int.parse(parts[i]));
        }
      }
    }

    return result;
  }
}
