import 'package:collection/collection.dart';

import 'group_user.dart';
import 'settings.dart';
import 'server_state.dart';
import 'workplaces.dart';
import 'dart:convert';

class Group {
  late int id;
  late String name;
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
  late bool isActive;
  late bool isManagerCastingVote;
  late bool isUnregisterUserOnExit;
  late bool isFastRegistrationUsed;
  late bool isDeputyAutoRegistration;
  late bool isManagerAutoRegistration;
  late Workplaces workplaces;
  late List<GroupUser> groupUsers;
  late String unblockedMics;
  late String guests;
  late int MicsNotActiveFrom;
  late String managerTerminal;

  Group() {
    id = 0;
    name = '';
    lawUsersCount = 0;
    quorumCount = 0;
    majorityCount = 0;
    oneThirdsCount = 0;
    twoThirdsCount = 0;
    chosenCount = 0;
    majorityChosenCount = 0;
    oneThirdsChosenCount = 0;
    twoThirdsChosenCount = 0;
    roundingRoule = 'Отбросить после запятой';
    managerRoule = 'Председатель определяется рабочим местом';
    isActive = false;
    isManagerCastingVote = false;
    isUnregisterUserOnExit = false;
    isFastRegistrationUsed = false;
    isDeputyAutoRegistration = false;
    isManagerAutoRegistration = false;
    workplaces = Workplaces();
    groupUsers = <GroupUser>[];
    unblockedMics = '';
    guests = '';
    MicsNotActiveFrom = 900;
    managerTerminal = '003';
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'lawUsersCount': lawUsersCount,
        'quorumCount': quorumCount,
        'majorityCount': majorityCount,
        'oneThirdsCount': oneThirdsCount,
        'twoThirdsCount': twoThirdsCount,
        'chosenCount': chosenCount,
        'majorityChosenCount': majorityChosenCount,
        'oneThirdsChosenCount': oneThirdsChosenCount,
        'twoThirdsChosenCount': twoThirdsChosenCount,
        'roundingRoule': roundingRoule,
        'managerRoule': managerRoule,
        'isActive': isActive,
        'isManagerCastingVote': isManagerCastingVote,
        'isUnregisterUserOnExit': isUnregisterUserOnExit,
        'isFastRegistrationUsed': isFastRegistrationUsed,
        'isDeputyAutoRegistration': isDeputyAutoRegistration,
        'isManagerAutoRegistration': isManagerAutoRegistration,
        'workplaces': jsonEncode(workplaces.toJson()).toString(),
        'groupUsers': groupUsers,
        'unblockedMics': unblockedMics,
        'guests': guests,
        'MicsNotActiveFrom': MicsNotActiveFrom,
        'managerTerminal': managerTerminal,
      };

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lawUsersCount = json['lawUsersCount'],
        quorumCount = json['quorumCount'],
        majorityCount = json['majorityCount'],
        oneThirdsCount = json['oneThirdsCount'],
        twoThirdsCount = json['twoThirdsCount'],
        chosenCount = json['chosenCount'],
        majorityChosenCount = json['majorityChosenCount'],
        oneThirdsChosenCount = json['oneThirdsChosenCount'],
        twoThirdsChosenCount = json['twoThirdsChosenCount'],
        roundingRoule = json['roundingRoule'],
        managerRoule = json['managerRoule'],
        isActive = json['isActive'],
        isManagerCastingVote = json['isManagerCastingVote'],
        isUnregisterUserOnExit = json['isUnregisterUserOnExit'],
        isFastRegistrationUsed = json['isFastRegistrationUsed'],
        isDeputyAutoRegistration = json['isDeputyAutoRegistration'],
        isManagerAutoRegistration = json['isManagerAutoRegistration'],
        workplaces = Workplaces.fromJson(jsonDecode(json['workplaces'])),
        groupUsers = json['groupUsers']
            .map<GroupUser>((gu) => GroupUser.fromJson(gu))
            .toList(),
        unblockedMics = json['unblockedMics'],
        guests = json['guests'],
        MicsNotActiveFrom = json['MicsNotActiveFrom'],
        managerTerminal = json['managerTerminal'];

  List<GroupUser> getVoters() {
    return groupUsers.where((element) => element.user.isVoter).toList();
  }

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '$name';
  }
}

class GroupUtil {
  static bool isTerminalGuest(ServerState serverState, String terminalId) {
    if (terminalId == null || terminalId.isEmpty) {
      return false;
    }

    // not user terminal
    return !(serverState.usersTerminals.entries
        .any((element) => element.key == terminalId && element.value != null
            //&&        serverState.terminalsOnline.contains(terminalId)
            ));
  }

  int? getManagerId(Group group, Map<String, int> usersTerminals) {
    var nameManagerId = group.groupUsers
        .firstWhereOrNull((element) => element.isManager)
        ?.user
        ?.id;

    if (!usersTerminals.values.contains(nameManagerId)) {
      nameManagerId = null;
    }

    var placeManagerId = usersTerminals[group.managerTerminal];

    if (group.managerRoule == 'Председатель определяется по ФИО') {
      return nameManagerId;
    } else if (group.managerRoule ==
        'Председатель определяется рабочим местом') {
      return placeManagerId;
    } else if (group.managerRoule ==
        'Председатель определяется вначале ФИО затем рабочим местом') {
      return nameManagerId ?? placeManagerId;
    } else if (group.managerRoule ==
        'Председатель определяется вначале рабочим местом затем ФИО') {
      return placeManagerId ?? nameManagerId;
    } else {
      return null;
    }
  }
}
