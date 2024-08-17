import 'package:conduit_core/conduit_core.dart';
import 'agenda.dart';
import 'file.dart';

class Question extends ManagedObject<_Question> implements _Question {}

class _Question {
  @primaryKey
  late int id;
  late String name;
  late int orderNum;
  @Column(nullable: true)
  String? accessRights;
  late String description;
  late String folder;
  @Relate(#questions, onDelete: DeleteRule.cascade)
  late Agenda agenda;
  late ManagedSet<File> files;
}
