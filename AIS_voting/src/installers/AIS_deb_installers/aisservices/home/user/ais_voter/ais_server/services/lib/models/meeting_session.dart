import 'package:aqueduct/aqueduct.dart';

class MeetingSession extends ManagedObject<_MeetingSession>
    implements _MeetingSession {}

class _MeetingSession {
  @primaryKey
  int id;
  int meetingId;
  @Column(nullable: true)
  DateTime startDate;
  @Column(nullable: true)
  DateTime endDate;
}
