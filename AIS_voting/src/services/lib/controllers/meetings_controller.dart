import 'package:collection/collection.dart';
import 'package:conduit_core/conduit_core.dart';
import '../models/meeting.dart';
import '../models/group.dart';
import '../models/agenda.dart';
import '../models/meeting_session.dart';

class MeetingsController extends ResourceController {
  MeetingsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getMeetings() async {
    final query = Query<Meeting>(context);
    var allMeetings = await query.fetch();

    final queryGroups = Query<Group>(context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user);
    var allGroups = await queryGroups.fetch();

    final queryAgenda = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files);
    var allAgendas = await queryAgenda.fetch();

    for (var i = 0; i < allMeetings.length; i++) {
      var meeting = allMeetings[i];

      var group = allGroups
          .firstWhereOrNull((element) => element.id == meeting.group?.id);
      meeting.group = group;
      var agenda = allAgendas
          .firstWhereOrNull((element) => element.id == meeting.agenda?.id);
      meeting.agenda = agenda;
    }
    return Response.ok(allMeetings);
  }

  @Operation.get('id')
  Future<Response> getMeetingById(@Bind.path('id') int id) async {
    final q = Query<Meeting>(context)..where((o) => o.id).equalTo(id);
    final meeting = await q.fetchOne();

    if (meeting == null) {
      return Response.notFound();
    }

    final queryGroup = Query<Group>(context)
      ..join(set: (g) => g.groupUsers).join(object: (gu) => gu.user)
      ..where((g) => g.id).equalTo(meeting.group?.id ?? 0);
    var group = await queryGroup.fetchOne();
    meeting.group = group;

    final queryAgenda = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files)
      ..where((a) => a.id).equalTo(meeting.agenda?.id ?? 0);
    var agenda = await queryAgenda.fetchOne();
    meeting.agenda = agenda;

    return Response.ok(meeting);
  }

  @Operation.post()
  Future<Response> addMeeting(@Bind.body() Meeting meeting) async {
    final query = Query<Meeting>(context)
      ..values.name = meeting.name
      ..values.description = meeting.description
      ..values.status = meeting.status
      ..values.group = meeting.group
      ..values.agenda = meeting.agenda
      ..values.lastUpdated = meeting.lastUpdated;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateMeeting(
      @Bind.path('id') int id, @Bind.body() Meeting meeting) async {
    var query = Query<Meeting>(context)
      ..values.name = meeting.name
      ..values.description = meeting.description
      ..values.status = meeting.status
      ..values.group = meeting.group
      ..values.agenda = meeting.agenda
      ..values.lastUpdated = meeting.lastUpdated
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteMeeting(@Bind.path('id') int id) async {
    // delete meeting sessions
    final deleteMeetingSessions = Query<MeetingSession>(context)
      ..where((ms) => ms.meetingId).equalTo(id);
    await deleteMeetingSessions.delete();

    // delete meeting
    var query = Query<Meeting>(context)..where((u) => u.id).equalTo(id);
    var meetingDeleted = await query.delete();

    return Response.ok(meetingDeleted);
  }
}
