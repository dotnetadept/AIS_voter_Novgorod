import 'package:aqueduct/aqueduct.dart';
import 'user.dart';
import 'group.dart';

import 'package:ais_model/ais_model.dart' as client_models;

class GroupUser extends ManagedObject<_GroupUser> implements _GroupUser {
  // ToDo: otherFields
  client_models.GroupUser toClient() {
    var groupUser = client_models.GroupUser();

    groupUser.id = id;
    groupUser.isManager = isManager;
    groupUser.user = client_models.User();
    groupUser.user.id = user.id;

    return groupUser;
  }
}

class _GroupUser {
  @primaryKey
  int id;
  @Column(nullable: true)
  bool isManager;

  @Relate(#groupUsers, onDelete: DeleteRule.cascade)
  Group group;

  @Relate(#userGroups, onDelete: DeleteRule.cascade)
  User user;
}