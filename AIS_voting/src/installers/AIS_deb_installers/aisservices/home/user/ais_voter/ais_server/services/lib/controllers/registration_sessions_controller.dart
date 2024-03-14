import 'package:aqueduct/aqueduct.dart';
import '../models/registration_session.dart';

class RegistrationSessionsController extends ResourceController {
  RegistrationSessionsController(this.context);

  final ManagedContext context;

  @Operation.get('meeting_id')
  Future<Response> getRegistrationSessions(
      @Bind.path('meeting_id') int meetingId) async {
    final query = Query<RegistrationSession>(context)
      ..join(set: (o) => o.registrations)
      ..where((o) => o.meetingId).equalTo(meetingId);
    return Response.ok(await query.fetch());
  }
}
