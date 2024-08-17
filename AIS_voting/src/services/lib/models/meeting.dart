import 'package:conduit_core/conduit_core.dart';
import 'agenda.dart';
import 'group.dart';

class Meeting extends ManagedObject<_Meeting> implements _Meeting {}

class _Meeting {
  @primaryKey
  late int id;
  late String name;
  late String description;
  late String status;
  @Relate(#meetingAgenda)
  Agenda? agenda;
  @Relate(#meetingGroup)
  Group? group;
  late DateTime lastUpdated;
}
