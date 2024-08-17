import 'package:conduit_core/conduit_core.dart';
import 'user.dart';
import 'proxy.dart';

class ProxyUser extends ManagedObject<_ProxyUser> implements _ProxyUser {}

class _ProxyUser {
  @primaryKey
  late int id;

  @Relate(#subjects)
  late Proxy proxy;

  @Relate(#userProxys)
  late User user;
}
