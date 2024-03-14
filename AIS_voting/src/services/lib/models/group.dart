import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/ais_model.dart';

import 'package:ais_model/ais_model.dart' as client_models;

class Group extends ManagedObject<_Group> implements _Group {
  // ToDo: other fields
  client_models.Group toClient() {
    var gu = <client_models.GroupUser>[];

    for (var i = 0; i < groupUsers.length; i++) {
      gu.add(groupUsers[i].toClient());
    }

    var group = client_models.Group();

    group.id = id;
    group.name = name;
    group.lawUsersCount = lawUsersCount;
    group.quorumCount = quorumCount;
    group.majorityCount = majorityCount;
    group.oneThirdsCount = oneThirdsCount;
    group.twoThirdsCount = twoThirdsCount;
    group.chosenCount = chosenCount;
    group.majorityChosenCount = majorityChosenCount;
    group.oneThirdsChosenCount = oneThirdsChosenCount;
    group.twoThirdsChosenCount = twoThirdsChosenCount;
    group.roundingRoule = roundingRoule;
    group.managerRoule = managerRoule;
    group.isActive = isActive;

    group.isManagerCastingVote = isManagerCastingVote;
    group.isUnregisterUserOnExit = isUnregisterUserOnExit;
    group.isFastRegistrationUsed = isFastRegistrationUsed;
    group.isDeputyAutoRegistration = isDeputyAutoRegistration;
    group.isManagerAutoRegistration = isManagerAutoRegistration;
    group.groupUsers = gu;

    return group;
  }
}

class _Group {
  @primaryKey
  int id;
  String name;
  ManagedSet<GroupUser> groupUsers;
  int lawUsersCount;
  int quorumCount;
  int majorityCount;
  int oneThirdsCount;
  int twoThirdsCount;
  int chosenCount;
  int majorityChosenCount;
  int oneThirdsChosenCount;
  int twoThirdsChosenCount;
  String roundingRoule;
  String managerRoule;
  String workplaces;
  bool isActive;

  bool isManagerCastingVote;
  bool isUnregisterUserOnExit;
  bool isFastRegistrationUsed;
  bool isDeputyAutoRegistration;
  bool isManagerAutoRegistration;
  Meeting meetingGroup;

  String unblockedMics;
  String guests;
  int MicsNotActiveFrom;
  String managerTerminal;
}
