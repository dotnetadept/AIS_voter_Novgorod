import 'package:aqueduct/aqueduct.dart';
import 'question.dart';

class File extends ManagedObject<_File> implements _File {}

class _File {
  @primaryKey
  int id;
  String path;
  String fileName;
  String version;
  String description;
  @Relate(#files, onDelete: DeleteRule.cascade)
  Question question;
}
