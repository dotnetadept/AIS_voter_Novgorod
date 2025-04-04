import 'dart:convert';
import 'package:ais_model/ais_model.dart' as cm;
import 'package:ais_model/ais_model.dart' show Workplaces;
import 'package:collection/collection.dart';
import 'package:conduit_core/conduit_core.dart';
import '../models/ais_model.dart';

class CommonUtils {
  static DateTime getDateTimeNow(int clientTimeOffset) {
    return DateTime.now().add(Duration(milliseconds: clientTimeOffset));
  }

  static Map<String, int?> getDefaultUsersTerminals(Meeting selectedMeeting) {
    var defaultUsersTerminals = <String, int?>{};

    if (selectedMeeting.group == null) {
      return defaultUsersTerminals;
    }

    var workplaces =
        Workplaces.fromJson(json.decode(selectedMeeting.group!.workplaces!));

    for (var i = 0; i < workplaces.managementPlacesCount; i++) {
      defaultUsersTerminals.putIfAbsent(
          workplaces.managementTerminalIds[i].toString(),
          () => workplaces.schemeManagement[i]);

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

    return defaultUsersTerminals;
  }

  // list of unblocked mics from group setting  + list of managers terminals
  static List<int> getUnblockedMicsList(
      Meeting selectedMeeting, Map<String, int> usersTerminals) {
    var result = <int>[];

    if (selectedMeeting.group == null) {
      return result;
    }

    // add mics from group setting
    var parts = selectedMeeting.group!.unblockedMics!.split(',');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result.add(int.parse(parts[i]));
      }
    }

    // add managers mics
    var managerIds = selectedMeeting.group!.groupUsers!
        .where((element) => element.isManager)
        .map((e) => e.user.id)
        .toList();
    var managerTerminals = usersTerminals.entries
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

  static Future<cm.Settings> getCurrentSettings(ManagedContext context) async {
    final query = Query<Settings>(context);

    var allSettings = await query.fetch();

    var firstSetting =
        allSettings.firstWhereOrNull((element) => element.isSelected);

    return cm.Settings.fromJson(Response.ok(firstSetting).body);
  }

  static Future<List<Meeting>> getAllMeetings(ManagedContext context) async {
    final query = Query<Meeting>(context);
    var allMeetings = await query.fetch();

    final queryGroups = Query<Group>(context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user);
    var allGroups = await queryGroups.fetch();

    final queryAgenda = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files);
    var allAgendas = await queryAgenda.fetch();

    for (var i = 0; i < allMeetings.length; i++) {
      var meeting = allMeetings[i];

      var group = allGroups
          .firstWhereOrNull((element) => element.id == meeting.group?.id);
      meeting.group = group;
      var agenda = allAgendas
          .firstWhereOrNull((element) => element.id == meeting.agenda?.id);
      meeting.agenda = agenda;
    }
    return allMeetings;
  }

  static Future<Meeting?> getMeetingById(
      ManagedContext context, int meetingId) async {
    final q = Query<Meeting>(context)..where((o) => o.id).equalTo(meetingId);
    final meeting = await q.fetchOne();

    if (meeting == null) {
      return null;
    }

    final queryGroup = Query<Group>(context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user)
      ..where((g) => g.id).equalTo(meeting.group?.id ?? 0);
    var group = await queryGroup.fetchOne();
    meeting.group = group;

    final queryAgenda = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files)
      ..where((a) => a.id).equalTo(meeting.agenda?.id ?? 0);
    var agenda = await queryAgenda.fetchOne();
    meeting.agenda = agenda;

    return meeting;
  }

  static Future<List<Proxy>> getAllProxies(ManagedContext context) async {
    // final query = Query<Proxy>(context)
    //   ..join(set: (s) => s.subjects).join(object: (pu) => pu.user)
    //   ..where((s) => s.isActive == true).equalTo(true);

    final query = Query<Proxy>(context);

    var allProxies = await query.fetch();

    final queryUsers = Query<User>(context);
    var allUsers = await queryUsers.fetch();

    for (var i = 0; i < allProxies.length; i++) {
      var proxy = allProxies[i];

      var user =
          allUsers.firstWhereOrNull((element) => element.id == proxy.proxy?.id);
      proxy.proxy = user;
    }
    return allProxies;
  }
}
