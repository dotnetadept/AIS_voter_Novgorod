import 'package:conduit_core/conduit_core.dart';
import 'question.dart';
import 'meeting.dart';

class Agenda extends ManagedObject<_Agenda> implements _Agenda {}

class _Agenda {
  @primaryKey
  late int id;
  late String name;
  late String folder;
  late DateTime createdDate;
  late DateTime lastUpdated;
  late ManagedSet<Question> questions;
  late Meeting meetingAgenda;
}
