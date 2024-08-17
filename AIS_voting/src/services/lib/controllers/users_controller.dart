import 'package:conduit_core/conduit_core.dart';
import '../models/user.dart';

class UsersController extends ResourceController {
  UsersController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getUsers() async {
    final query = Query<User>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.get('id')
  Future<Response> getUserById(@Bind.path('id') int id) async {
    final q = Query<User>(context)..where((o) => o.id).equalTo(id);
    final user = await q.fetchOne();

    if (user == null) {
      return Response.notFound();
    }

    return Response.ok(user);
  }

  @Operation.post()
  Future<Response> addUser(@Bind.body() User user) async {
    final query = Query<User>(context)
      ..values.firstName = user.firstName
      ..values.secondName = user.secondName
      ..values.lastName = user.lastName
      ..values.login = user.login
      ..values.password = user.password
      ..values.cardId = user.cardId
      ..values.lastSession = user.lastSession
      ..values.isVoter = user.isVoter;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateUser(
      @Bind.path('id') int id, @Bind.body() User user) async {
    var query = Query<User>(context)
      ..values.firstName = user.firstName
      ..values.secondName = user.secondName
      ..values.lastName = user.lastName
      ..values.login = user.login
      ..values.password = user.password
      ..values.cardId = user.cardId
      ..values.lastSession = user.lastSession
      ..values.isVoter = user.isVoter
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteUser(@Bind.path('id') int id) async {
    var query = Query<User>(context)..where((u) => u.id).equalTo(id);

    var userDeleted = await query.delete();

    return Response.ok(userDeleted);
  }
}
