import 'package:conduit_core/conduit_core.dart';
import 'question_session.dart';

class Result extends ManagedObject<_Result> implements _Result {}

class _Result {
  @primaryKey
  late int id;
  late int userId;
  @Column(nullable: true)
  int? proxyId;
  late String result;

  @Relate(#results, onDelete: DeleteRule.cascade)
  late QuestionSession questionSession;
}
