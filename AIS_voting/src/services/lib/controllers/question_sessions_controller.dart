import 'package:conduit_core/conduit_core.dart';
import '../models/question_session.dart';

class QuestionSessionsController extends ResourceController {
  QuestionSessionsController(this.context);

  final ManagedContext context;

  @Operation.get('meeting_session_id')
  Future<Response> getQuestionSessions(
      @Bind.path('meeting_session_id') int meetingSessionId) async {
    final query = Query<QuestionSession>(context)
      ..join(set: (o) => o.results)
      ..where((o) => o.meetingSessionId).equalTo(meetingSessionId);

    return Response.ok(await query.fetch());
  }
}
