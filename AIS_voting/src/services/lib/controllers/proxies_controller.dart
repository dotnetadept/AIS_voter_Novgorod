import 'package:collection/collection.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/proxy_user.dart';
import '../models/proxy.dart';
import '../models/user.dart';

class ProxiesController extends ResourceController {
  ProxiesController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getProxies() async {
    final query = Query<Proxy>(context)
      ..join(set: (s) => s.subjects).join(object: (pu) => pu.user);
    var allProxies = await query.fetch();

    final queryUsers = Query<User>(context);
    var allUsers = await queryUsers.fetch();

    for (var i = 0; i < allProxies.length; i++) {
      var proxy = allProxies[i];

      var user =
          allUsers.firstWhereOrNull((element) => element.id == proxy.proxy?.id);
      proxy.proxy = user;
    }

    return Response.ok(allProxies);
  }

  @Operation.post()
  Future<Response> addProxy(@Bind.body() Proxy proxy) async {
    final query = Query<Proxy>(context)
      ..values.proxy = proxy.proxy
      ..values.isActive = proxy.isActive
      ..values.lastUpdated = proxy.lastUpdated
      ..values.createdDate = proxy.createdDate;

    var insertedProxy = await query.insert();

    await Future.forEach(proxy.subjects, (ProxyUser pu) async {
      var proxyUser = Query<ProxyUser>(context)
        ..values.user = pu.user
        ..values.proxy = insertedProxy;

      return (await proxyUser.insert());
    });

    var insertedProxyQuery = Query<Proxy>(context)
      ..where((o) => o.id).equalTo(insertedProxy.id);

    return Response.ok(await insertedProxyQuery.fetchOne());
  }

  @Operation.put('id')
  Future<Response> updateProxy(
      @Bind.path('id') int id, @Bind.body() Proxy proxy) async {
    var query = Query<Proxy>(context)
      ..values.proxy = proxy.proxy
      ..values.isActive = proxy.isActive
      ..values.lastUpdated = proxy.lastUpdated
      ..values.createdDate = proxy.createdDate
      ..where((g) => g.id).equalTo(id);

    // Clear ProxyUsers
    var deleteProxyUsers = Query<ProxyUser>(context)
      ..where((gu) => gu.proxy.id).equalTo(id);
    await deleteProxyUsers.delete();

    // Insert ProxyUsers from payload
    await Future.forEach(proxy.subjects, (ProxyUser pu) async {
      var proxyUser = Query<ProxyUser>(context)
        ..values.user = pu.user
        ..values.proxy = proxy;

      return (await proxyUser.insert());
    });

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteProxy(@Bind.path('id') int id) async {
    var query = Query<Proxy>(context)..where((g) => g.id).equalTo(id);

    var proxyDeleted = await query.delete();

    return Response.ok(proxyDeleted);
  }
}
