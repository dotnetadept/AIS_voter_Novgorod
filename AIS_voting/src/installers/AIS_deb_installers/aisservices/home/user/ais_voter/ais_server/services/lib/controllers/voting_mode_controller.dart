import 'package:aqueduct/aqueduct.dart';
import '../models/voting_mode.dart';

class VotingModeController extends ResourceController {
  VotingModeController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getVotingModes() async {
    final query = Query<VotingMode>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addVotingMode(@Bind.body() VotingMode votingMode) async {
    final query = Query<VotingMode>(context)
      ..values.name = votingMode.name
      ..values.defaultDecision = votingMode.defaultDecision
      ..values.includedDecisions = votingMode.includedDecisions
      ..values.orderNum = votingMode.orderNum;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateVotingMode(
      @Bind.path('id') int id, @Bind.body() VotingMode votingMode) async {
    var query = Query<VotingMode>(context)
      ..values.name = votingMode.name
      ..values.defaultDecision = votingMode.defaultDecision
      ..values.includedDecisions = votingMode.includedDecisions
      ..values.orderNum = votingMode.orderNum
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteVotingMode(@Bind.path('id') int id) async {
    var query = Query<VotingMode>(context)..where((u) => u.id).equalTo(id);

    var votingModeDeleted = await query.delete();

    return Response.ok(votingModeDeleted);
  }
}
