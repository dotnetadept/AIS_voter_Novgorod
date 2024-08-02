import 'package:ais_model/ais_model.dart';
import 'package:collection/collection.dart';

class UsersFilterUtil {
  static List<User> getNotVotedUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> notVotedUsers = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhereOrNull(
          (element) => element.id == group.groupUsers[i].user.id);

      if (user != null) {
        if (!serverState.usersDecisions.keys.contains(user.id.toString())) {
          notVotedUsers.add(user);
        }
      }
    }

    notVotedUsers.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });

    return notVotedUsers;
  }

  static List<User> getRegisteredUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> registredUsers = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhereOrNull(
          (element) => element.id == group.groupUsers[i].user.id);
      if (user != null) {
        if (serverState.usersRegistered.contains(user.id)) {
          registredUsers.add(user);
        }
      }
    }

    registredUsers.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });

    return registredUsers;
  }

  static List<User> getUnregisterUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> usersNotRegistered = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhereOrNull(
          (element) => element.id == group.groupUsers[i].user.id);
      if (user != null) {
        if (!serverState.usersRegistered.contains(user.id)) {
          usersNotRegistered.add(user);
        }
      }
    }

    usersNotRegistered.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });

    return usersNotRegistered;
  }

  static List<User> getAbsentUserList(
      List<User> users, Group group, ServerState serverState) {
    List<User> usersAbsent = <User>[];

    for (int i = 0; i < group.groupUsers.length; i++) {
      var user = users.firstWhereOrNull(
          (element) => element.id == group.groupUsers[i].user.id);

      var foundUserTerminal =
          serverState.usersTerminals.entries.firstWhereOrNull(
        (element) =>
            element.value == users[i].id &&
            serverState.terminalsOnline.contains(element.key),
      );

      if (user != null) {
        if (foundUserTerminal == null) {
          usersAbsent.add(user);
        }
      }
    }

    usersAbsent.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });

    return usersAbsent;
  }
}
