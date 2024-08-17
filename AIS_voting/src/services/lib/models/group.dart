
import 'package:conduit_core/conduit_core.dart';
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
  late int id;
  late String name;
  late ManagedSet<GroupUser> groupUsers;
  late int lawUsersCount;
  late int quorumCount;
  late int majorityCount;
  late int oneThirdsCount;
  late int twoThirdsCount;
  late int chosenCount;
  late int majorityChosenCount;
  late int oneThirdsChosenCount;
  late int twoThirdsChosenCount;
  late String roundingRoule;
  late String managerRoule;
  late String workplaces;
  late bool isActive;

  late bool isManagerCastingVote;
  late bool isUnregisterUserOnExit;
  late bool isFastRegistrationUsed;
  late bool isDeputyAutoRegistration;
  late bool isManagerAutoRegistration;
  late Meeting meetingGroup;

  late String unblockedMics;
  late String guests;
  late int MicsNotActiveFrom;
  late String managerTerminal;
}
