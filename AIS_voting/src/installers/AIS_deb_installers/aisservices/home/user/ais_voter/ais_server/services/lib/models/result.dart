import 'package:aqueduct/aqueduct.dart';
import 'question_session.dart';

class Result extends ManagedObject<_Result> implements _Result {}

class _Result {
  @primaryKey
  int id;
  //int questionSessionId;
  int userId;
  String result;

  @Relate(#results, onDelete: DeleteRule.cascade)
  QuestionSession questionSession;
}
