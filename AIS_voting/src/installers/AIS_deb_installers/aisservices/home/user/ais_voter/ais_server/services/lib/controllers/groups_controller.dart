import 'package:aqueduct/aqueduct.dart';
import '../models/group.dart';
import '../models/group_user.dart';

class GroupsController extends ResourceController {
  GroupsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getGroups() async {
    final query = Query<Group>(context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user);
    return Response.ok(await query.fetch());
  }

  @Operation.get('id')
  Future<Response> getGroupById(@Bind.path('id') int id) async {
    final q = Query<Group>(context)..where((o) => o.id).equalTo(id);
    final group = await q.fetchOne();

    if (group == null) {
      return Response.notFound();
    }

    return Response.ok(group);
  }

  @Operation.post()
  Future<Response> addGroup(@Bind.body() Group group) async {
    if (group.name == null) {
      return Response.badRequest(body: {'error': 'Group name is required.'});
    }

    final query = Query<Group>(context)
      ..values.name = group.name
      ..values.workplaces = group.workplaces
      ..values.lawUsersCount = group.lawUsersCount
      ..values.quorumCount = group.quorumCount
      ..values.majorityCount = group.majorityCount
      ..values.oneThirdsCount = group.oneThirdsCount
      ..values.twoThirdsCount = group.twoThirdsCount
      ..values.majorityChosenCount = group.majorityChosenCount
      ..values.oneThirdsChosenCount = group.oneThirdsChosenCount
      ..values.twoThirdsChosenCount = group.twoThirdsChosenCount
      ..values.roundingRoule = group.roundingRoule
      ..values.isManagerAutoAuthentication = group.isManagerAutoAuthentication
      ..values.isManagerAutoRegistration = group.isManagerAutoRegistration
      ..values.isActive = group.isActive
      ..values.unblockedMics = group.unblockedMics;

    var insertedGroup = await query.insert();

    await Future.forEach(group.groupUsers, (GroupUser gu) async {
      var groupUser = Query<GroupUser>(context)
        ..values.isManager = gu.isManager
        ..values.user = gu.user
        ..values.group = insertedGroup;

      return (await groupUser.insert());
    });

    var insertedGroupQuery = Query<Group>(context)
      ..where((o) => o.id).equalTo(insertedGroup.id);

    return Response.ok(await insertedGroupQuery.fetchOne());
  }

  @Operation.put('id')
  Future<Response> updateGroup(
      @Bind.path('id') int id, @Bind.body() Group group) async {
    var query = Query<Group>(context)
      ..values.name = group.name
      ..values.workplaces = group.workplaces
      ..values.lawUsersCount = group.lawUsersCount
      ..values.quorumCount = group.quorumCount
      ..values.majorityCount = group.majorityCount
      ..values.oneThirdsCount = group.oneThirdsCount
      ..values.twoThirdsCount = group.twoThirdsCount
      ..values.majorityChosenCount = group.majorityChosenCount
      ..values.oneThirdsChosenCount = group.oneThirdsChosenCount
      ..values.twoThirdsChosenCount = group.twoThirdsChosenCount
      ..values.roundingRoule = group.roundingRoule
      ..values.isManagerAutoAuthentication = group.isManagerAutoAuthentication
      ..values.isManagerAutoRegistration = group.isManagerAutoRegistration
      ..values.isActive = group.isActive
      ..values.unblockedMics = group.unblockedMics
      ..where((g) => g.id).equalTo(id);

    // Clear GroupUsers
    var deleteGroupUsers = Query<GroupUser>(context)
      ..where((gu) => gu.group.id).equalTo(id);
    await deleteGroupUsers.delete();

    // Insert GroupUsers from payload
    await Future.forEach(group.groupUsers, (GroupUser gu) async {
      var groupUser = Query<GroupUser>(context)
        ..values.isManager = gu.isManager
        ..values.user = gu.user
        ..values.group = group;

      return (await groupUser.insert());
    });

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteGroup(@Bind.path('id') int id) async {
    var query = Query<Group>(context)..where((g) => g.id).equalTo(id);

    var groupDeleted = await query.delete();

    return Response.ok(groupDeleted);
  }
}
