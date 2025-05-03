import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/proxy.dart';
import 'package:services/models/proxy_user.dart';
import 'group_user.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  late int? id;
  late String firstName;
  late String secondName;
  late String lastName;
  @Column(unique: true)
  late String login;
  late String password;
  late String cardId;
  @Column(nullable: true)
  DateTime? lastSession;
  late bool isVoter;
  late ManagedSet<GroupUser> userGroups;
  late ManagedSet<ProxyUser> userProxys;
  late ManagedSet<Proxy> proxys;
}
