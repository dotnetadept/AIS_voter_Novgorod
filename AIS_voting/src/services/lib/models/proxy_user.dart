import 'package:aqueduct/aqueduct.dart';
import 'user.dart';
import 'proxy.dart';

class ProxyUser extends ManagedObject<_ProxyUser> implements _ProxyUser {}

class _ProxyUser {
  @primaryKey
  int id;

  @Relate(#subjects)
  Proxy proxy;

  @Relate(#userProxys)
  User user;
}
