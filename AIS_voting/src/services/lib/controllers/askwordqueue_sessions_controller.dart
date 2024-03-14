import 'package:aqueduct/aqueduct.dart';
import '../models/question_session.dart';

class AskWordQueueController extends ResourceController {
  AskWordQueueController(this.context);

  final ManagedContext context;

  @Operation.get('meeting_session_id')
  Future<Response> getAskWordQueueSessions(
      @Bind.path('meeting_session_id') int meetingSessionId) async {
    final query = Query<QuestionSession>(context)
      ..join(set: (o) => o.results)
      ..where((o) => o.meetingSessionId).equalTo(meetingSessionId);

    return Response.ok(await query.fetch());
  }
}
