import 'package:aqueduct/aqueduct.dart';
import 'user.dart';
import 'group.dart';

class GroupUser extends ManagedObject<_GroupUser> implements _GroupUser {}

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
