import 'package:aqueduct/aqueduct.dart';
import '../models/meeting.dart';
import '../models/group.dart';
import '../models/agenda.dart';

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

      var group = allGroups.firstWhere(
          (element) => element.id == meeting.group.id,
          orElse: () => null);
      meeting.group = group;
      var agenda = allAgendas.firstWhere(
          (element) => element.id == meeting.agenda.id,
          orElse: () => null);
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
      ..where((g) => g.id).equalTo(meeting.group.id);
    var group = await queryGroup.fetchOne();
    meeting.group = group;

    final queryAgenda = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files)
      ..where((a) => a.id).equalTo(meeting.agenda.id);
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
    var query = Query<Meeting>(context)..where((u) => u.id).equalTo(id);

    var meetingDeleted = await query.delete();

    return Response.ok(meetingDeleted);
  }
}
