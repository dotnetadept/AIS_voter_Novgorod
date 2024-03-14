import 'package:aqueduct/aqueduct.dart';
import '../models/meeting_session.dart';

class MeetingSessionsController extends ResourceController {
  MeetingSessionsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getMeetingSessions() async {
    final query = Query<MeetingSession>(context);
    return Response.ok(await query.fetch());
  }
}
