import 'dart:ffi';

import 'package:collection/collection.dart';

import '../ais_model.dart';

enum DecisionMode {
  MajorityOfLawMembers,
  TwoThirdsOfLawMembers,
  OneThirdsOfLawMembers,
  MajorityOfChosenMembers,
  TwoThirdsOfChosenMembers,
  OneThirdsOfChosenMembers,
  MajorityOfRegistredMembers,
  TwoThirdsOfRegistredMembers,
  OneThirdsOfRegistredMembers,
}

class DecisionModeHelper {
  static String getStringValue(DecisionMode decisionMode) {
    switch (decisionMode) {
      case DecisionMode.MajorityOfLawMembers:
        return 'Большинство от установленного числа';
      case DecisionMode.TwoThirdsOfLawMembers:
        return '2/3 от установленного числа';
      case DecisionMode.OneThirdsOfLawMembers:
        return '1/3 от установленного числа';
      case DecisionMode.MajorityOfChosenMembers:
        return 'Большинство от избранных';
      case DecisionMode.TwoThirdsOfChosenMembers:
        return '2/3 от избранных';
      case DecisionMode.OneThirdsOfChosenMembers:
        return '1/3 от избранных';
      case DecisionMode.MajorityOfRegistredMembers:
        return 'Большинство от зарегистрированных';
      case DecisionMode.TwoThirdsOfRegistredMembers:
        return '2/3 от зарегистрированных';
      case DecisionMode.OneThirdsOfRegistredMembers:
        return '1/3 от зарегистрированных';
      default:
        // todo: notFound
        return 'Большинство от установленного числа';
    }
  }

  static DecisionMode getEnumValue(String value) {
    switch (value) {
      case 'Большинство от установленного числа':
        return DecisionMode.MajorityOfLawMembers;
      case '2/3 от установленного числа':
        return DecisionMode.TwoThirdsOfLawMembers;
      case '1/3 от установленного числа':
        return DecisionMode.OneThirdsOfLawMembers;
      case 'Большинство от избранных':
        return DecisionMode.MajorityOfChosenMembers;
      case '2/3 от избранных':
        return DecisionMode.TwoThirdsOfChosenMembers;
      case '1/3 от избранных':
        return DecisionMode.OneThirdsOfChosenMembers;
      case 'Большинство от зарегистрированных':
        return DecisionMode.MajorityOfRegistredMembers;
      case '2/3 от зарегистрированных':
        return DecisionMode.TwoThirdsOfRegistredMembers;
      case '1/3 от зарегистрированных':
        return DecisionMode.OneThirdsOfRegistredMembers;
      default:
        // todo: notFound
        return DecisionMode.MajorityOfLawMembers;
    }
  }

  static int getSuccuessValue(DecisionMode decisionMode, Group selectedGroup,
      List<int> usersRegistered, bool isManagerVoted) {
    switch (decisionMode) {
      case DecisionMode.MajorityOfLawMembers:
        return getRoundedValue(selectedGroup.majorityCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.TwoThirdsOfLawMembers:
        return getRoundedValue(selectedGroup.twoThirdsCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.OneThirdsOfLawMembers:
        return getRoundedValue(selectedGroup.oneThirdsCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.MajorityOfChosenMembers:
        return getRoundedValue(selectedGroup.majorityChosenCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.TwoThirdsOfChosenMembers:
        return getRoundedValue(selectedGroup.twoThirdsChosenCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.OneThirdsOfChosenMembers:
        return getRoundedValue(selectedGroup.oneThirdsChosenCount.toDouble(),
            selectedGroup.roundingRoule);
      case DecisionMode.MajorityOfRegistredMembers:
        // if 6 registred users voted
        // without manager then success value = 4
        // if with manager = 3
        return getRoundedValue(
            usersRegistered.length % 2 == 1
                ? usersRegistered.length / 2
                : (usersRegistered.length / 2) +
                    (selectedGroup.isManagerCastingVote && isManagerVoted
                        ? 0
                        : 1),
            selectedGroup.roundingRoule);
      case DecisionMode.TwoThirdsOfRegistredMembers:
        return getRoundedValue(
            2 * usersRegistered.length / 3, selectedGroup.roundingRoule);
      case DecisionMode.OneThirdsOfRegistredMembers:
        return getRoundedValue(
            usersRegistered.length / 3, selectedGroup.roundingRoule);
      default:
        return double.maxFinite.toInt();
    }
  }

  static int getRoundedValue(double value, String roundingRoule) {
    if (roundingRoule == 'Отбросить после запятой') {
      return value.floor();
    }
    if (roundingRoule == 'Округлить вверх если есть знак после запятой') {
      return value.ceil();
    }
    if (roundingRoule ==
        'Больше или равно 0,5 округляется  вверх, меньше - вниз') {
      return value.round();
    }

    return 0;
  }
}
