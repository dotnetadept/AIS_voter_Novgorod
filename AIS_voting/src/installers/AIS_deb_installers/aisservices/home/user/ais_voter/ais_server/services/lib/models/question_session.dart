import 'package:aqueduct/aqueduct.dart';
import 'result.dart';

class QuestionSession extends ManagedObject<_QuestionSession>
    implements _QuestionSession {}

class _QuestionSession {
  @primaryKey
  int id;
  int meetingSessionId;
  int questionId;
  int votingModeId;
  String desicion;
  int interval;
  int usersCountRegistred;
  int usersCountForSuccess;
  @Column(nullable: true)
  int usersCountVoted;
  @Column(nullable: true)
  int usersCountVotedYes;
  @Column(nullable: true)
  int usersCountVotedNo;
  @Column(nullable: true)
  int usersCountVotedIndiffirent;
  DateTime startDate;
  @Column(nullable: true)
  DateTime endDate;

  ManagedSet<Result> results;
}
