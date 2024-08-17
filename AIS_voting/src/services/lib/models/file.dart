import 'package:conduit_core/conduit_core.dart';
import 'question.dart';

class File extends ManagedObject<_File> implements _File {}

class _File {
  @primaryKey
  late int id;
  late String path;
  late String fileName;
  late String version;
  late String description;
  @Relate(#files, onDelete: DeleteRule.cascade)
  late Question question;
}
