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
        return 'Большинство от выбранных членов';
      case DecisionMode.TwoThirdsOfChosenMembers:
        return '2/3 от выбранных членов';
      case DecisionMode.OneThirdsOfChosenMembers:
        return '1/3 от выбранных членов';
      case DecisionMode.MajorityOfRegistredMembers:
        return 'Большинство от зарегистрированных членов';
      case DecisionMode.TwoThirdsOfRegistredMembers:
        return '2/3 от зарегистрированных членов';
      case DecisionMode.OneThirdsOfRegistredMembers:
        return '1/3 от зарегистрированных членов';
      default:
        return null;
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
      case 'Большинство от выбранных членова':
        return DecisionMode.MajorityOfChosenMembers;
      case '2/3 от выбранных членов':
        return DecisionMode.TwoThirdsOfChosenMembers;
      case '1/3 от выбранных членов':
        return DecisionMode.OneThirdsOfChosenMembers;
      case 'Большинство от зарегистрированных членов':
        return DecisionMode.MajorityOfRegistredMembers;
      case '2/3 от зарегистрированных членов':
        return DecisionMode.TwoThirdsOfRegistredMembers;
      case '1/3 от зарегистрированных членов':
        return DecisionMode.OneThirdsOfRegistredMembers;
      default:
        return null;
    }
  }

  static int getSuccuessValue(
      DecisionMode decisionMode, Group selectedGroup, ServerState serverState) {
    switch (decisionMode) {
      case DecisionMode.MajorityOfLawMembers:
        return getRoundedValue(
            selectedGroup.majorityCount.toDouble(), selectedGroup);
      case DecisionMode.TwoThirdsOfLawMembers:
        return getRoundedValue(
            selectedGroup.twoThirdsCount.toDouble(), selectedGroup);
      case DecisionMode.OneThirdsOfLawMembers:
        return getRoundedValue(
            selectedGroup.oneThirdsCount.toDouble(), selectedGroup);
      case DecisionMode.MajorityOfChosenMembers:
        return getRoundedValue(
            selectedGroup.majorityChosenCount.toDouble(), selectedGroup);
      case DecisionMode.TwoThirdsOfChosenMembers:
        return getRoundedValue(
            selectedGroup.twoThirdsChosenCount.toDouble(), selectedGroup);
      case DecisionMode.OneThirdsOfChosenMembers:
        return getRoundedValue(
            selectedGroup.oneThirdsChosenCount.toDouble(), selectedGroup);
      case DecisionMode.MajorityOfRegistredMembers:
        return getRoundedValue(
            serverState.usersRegistered.length / 2, selectedGroup);
      case DecisionMode.TwoThirdsOfRegistredMembers:
        return getRoundedValue(
            2 * serverState.usersRegistered.length / 3, selectedGroup);
      case DecisionMode.OneThirdsOfRegistredMembers:
        return getRoundedValue(
            serverState.usersRegistered.length / 3, selectedGroup);
      default:
        return null;
    }
  }

  static int getRoundedValue(double value, Group selectedGroup) {
    if (selectedGroup.roundingRoule == 'Отбросить после запятой') {
      return value.floor();
    }
    if (selectedGroup.roundingRoule ==
        'Округлить вверх если есть знак после запятой') {
      return value.ceil();
    }
    if (selectedGroup.roundingRoule ==
        'Больше или равно 0,5 округляется  вверх, меньше - вниз') {
      return value.round();
    }

    return 0;
  }
}
