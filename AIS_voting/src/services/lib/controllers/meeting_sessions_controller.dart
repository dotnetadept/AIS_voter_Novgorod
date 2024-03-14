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

  @Operation.put('id')
  Future<Response> updateMeetingSessions(@Bind.path('id') int id,
      @Bind.body() MeetingSession meetingSession) async {
    var query = Query<MeetingSession>(context)
      ..values.guestPlaces = meetingSession.guestPlaces
      ..values.startDate = meetingSession.startDate
      ..values.endDate = meetingSession.endDate
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('meeting_id')
  Future<Response> deleteMeetingSessions(
      @Bind.path('meeting_id') int id) async {
    final deleteMeetingSessions = Query<MeetingSession>(context)
      ..where((ms) => ms.meetingId).equalTo(id);

    return Response.ok(await deleteMeetingSessions.delete());
  }
}
