import 'package:aqueduct/aqueduct.dart';
import 'agenda.dart';
import 'file.dart';

class Question extends ManagedObject<_Question> implements _Question {}

class _Question {
  @primaryKey
  int id;
  String name;
  int orderNum;
  @Column(nullable: true)
  String accessRights;
  String description;
  String folder;
  @Relate(#questions, onDelete: DeleteRule.cascade)
  Agenda agenda;
  ManagedSet<File> files;
}
