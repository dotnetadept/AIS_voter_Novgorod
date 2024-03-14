import 'package:aqueduct/aqueduct.dart';
import 'question.dart';
import 'meeting.dart';

class Agenda extends ManagedObject<_Agenda> implements _Agenda {}

class _Agenda {
  @primaryKey
  int id;
  String name;
  String folder;
  DateTime createdDate;
  DateTime lastUpdated;
  ManagedSet<Question> questions;
  Meeting meetingAgenda;
}
