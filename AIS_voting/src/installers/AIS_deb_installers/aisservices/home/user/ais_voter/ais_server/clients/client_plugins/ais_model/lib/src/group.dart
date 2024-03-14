import 'group_user.dart';
import 'workplaces.dart';
import 'dart:convert';

class Group {
  int id;
  String name;
  int lawUsersCount;
  int quorumCount;
  int majorityCount;
  int oneThirdsCount;
  int twoThirdsCount;
  int majorityChosenCount;
  int oneThirdsChosenCount;
  int twoThirdsChosenCount;
  String roundingRoule;
  bool isActive;
  bool isManagerAutoAuthentication;
  bool isManagerAutoRegistration;
  Workplaces workplaces;
  List<GroupUser> groupUsers;
  String unblockedMics;

  Group() {
    id = 0;
    name = '';
    lawUsersCount = 0;
    quorumCount = 0;
    majorityCount = 0;
    oneThirdsCount = 0;
    twoThirdsCount = 0;
    majorityChosenCount = 0;
    oneThirdsChosenCount = 0;
    twoThirdsChosenCount = 0;
    roundingRoule = 'Отбросить после запятой';
    isActive = false;
    isManagerAutoAuthentication = false;
    isManagerAutoRegistration = false;
    workplaces = Workplaces();
    groupUsers = <GroupUser>[];
    unblockedMics = '';
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'lawUsersCount': lawUsersCount,
        'quorumCount': quorumCount,
        'majorityCount': majorityCount,
        'oneThirdsCount': oneThirdsCount,
        'twoThirdsCount': twoThirdsCount,
        'majorityChosenCount': majorityChosenCount,
        'oneThirdsChosenCount': oneThirdsChosenCount,
        'twoThirdsChosenCount': twoThirdsChosenCount,
        'roundingRoule': roundingRoule,
        'isActive': isActive,
        'isManagerAutoAuthentication': isManagerAutoAuthentication,
        'isManagerAutoRegistration': isManagerAutoRegistration,
        'workplaces': jsonEncode(workplaces.toJson()).toString(),
        'groupUsers': groupUsers,
        'unblockedMics': unblockedMics,
      };

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lawUsersCount = json['lawUsersCount'],
        quorumCount = json['quorumCount'],
        majorityCount = json['majorityCount'],
        oneThirdsCount = json['oneThirdsCount'],
        twoThirdsCount = json['twoThirdsCount'],
        majorityChosenCount = json['majorityChosenCount'],
        oneThirdsChosenCount = json['oneThirdsChosenCount'],
        twoThirdsChosenCount = json['twoThirdsChosenCount'],
        roundingRoule = json['roundingRoule'],
        isActive = json['isActive'],
        isManagerAutoAuthentication = json['isManagerAutoAuthentication'],
        isManagerAutoRegistration = json['isManagerAutoRegistration'],
        workplaces = Workplaces.fromJson(jsonDecode(json['workplaces'])),
        groupUsers = json['groupUsers']
            .map<GroupUser>((gu) => GroupUser.fromJson(gu))
            .toList(),
        unblockedMics = json['unblockedMics'];

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '$name';
  }
}
