import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/ais_model.dart';

class Group extends ManagedObject<_Group> implements _Group {}

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
  int majorityChosenCount;
  int oneThirdsChosenCount;
  int twoThirdsChosenCount;
  String roundingRoule;
  String workplaces;
  bool isActive;

  bool isManagerAutoAuthentication;
  bool isManagerAutoRegistration;
  Meeting meetingGroup;

  String unblockedMics;
}
