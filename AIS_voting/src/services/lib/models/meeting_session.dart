import 'package:conduit_core/conduit_core.dart';

class MeetingSession extends ManagedObject<_MeetingSession>
    implements _MeetingSession {}

class _MeetingSession {
  @primaryKey
  late int id;
  late int meetingId;
  @Column(nullable: true)
  String? guestPlaces;
  @Column(nullable: true)
  DateTime? startDate;
  @Column(nullable: true)
  DateTime? endDate;
}
