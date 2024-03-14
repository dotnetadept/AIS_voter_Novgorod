import 'package:aqueduct/aqueduct.dart';
import 'group_user.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int id;
  String firstName;
  String secondName;
  String lastName;
  @Column(unique: true)
  String login;
  String password;
  String cardId;
  @Column(nullable: true)
  DateTime lastSession;
  bool isVoter;
  ManagedSet<GroupUser> userGroups;
}
