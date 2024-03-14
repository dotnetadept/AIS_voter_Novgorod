import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/result.dart';

class ResultController extends ResourceController {
  ResultController(this.context);

  final ManagedContext context;

  @Operation.get('question_session_id')
  Future<Response> getQuestionSessionResult(
      @Bind.path('question_session_id') int questionSessionId) async {
    final query = Query<Result>(context)
      ..where((r) => r.questionSession.id).equalTo(questionSessionId);
    return Response.ok(await query.fetch());
  }
}
