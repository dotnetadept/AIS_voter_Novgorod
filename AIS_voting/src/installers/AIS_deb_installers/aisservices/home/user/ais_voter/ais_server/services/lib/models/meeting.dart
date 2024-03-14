import 'package:aqueduct/aqueduct.dart';
import 'agenda.dart';
import 'group.dart';

class Meeting extends ManagedObject<_Meeting> implements _Meeting {}

class _Meeting {
  @primaryKey
  int id;
  String name;
  String description;
  String status;
  @Relate(#meetingAgenda)
  Agenda agenda;
  @Relate(#meetingGroup)
  Group group;
  DateTime lastUpdated;
}
