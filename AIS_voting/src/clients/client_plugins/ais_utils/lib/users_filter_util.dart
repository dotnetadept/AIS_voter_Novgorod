import 'package:ais_model/ais_model.dart';

class UsersFilterUtil {
  static List<User> getNotVotedUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> registredUsers = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhere(
          (element) => element.id == group.groupUsers[i].user.id,
          orElse: () => null);
      if (serverState.usersRegistered.contains(user.id)) {
        registredUsers.add(user);
      }
    }

    return registredUsers;
  }

  static List<User> getRegisteredUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> registredUsers = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhere(
          (element) => element.id == group.groupUsers[i].user.id,
          orElse: () => null);
      if (serverState.usersRegistered.contains(user.id)) {
        registredUsers.add(user);
      }
    }

    return registredUsers;
  }

  static List<User> getUnregisterUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> usersNotRegistered = <User>[];

    for (int i = 0; i < users.length; i++) {
      var foundUserTerminal = serverState.usersTerminals.entries.firstWhere(
          (element) => element.value == users[i].id,
          orElse: () => null);

      if (foundUserTerminal != null &&
          serverState.terminalsOnline.contains(foundUserTerminal.key) &&
          !serverState.usersRegistered.contains(users[i].id)) {
        usersNotRegistered.add(users[i]);
      }
    }

    return usersNotRegistered;
  }

  static List<User> getAbsentUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> usersAbsent = <User>[];

    var registered = getRegisteredUserList(users, group, serverState);
    var unregistered = getUnregisterUserList(users, group, serverState);

    for (int i = 0; i < users.length; i++) {
      if (!(registered.contains(users[i]) || unregistered.contains(users[i]))) {
        usersAbsent.add(users[i]);
      }
    }

    usersAbsent.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });

    return usersAbsent;
  }
}
