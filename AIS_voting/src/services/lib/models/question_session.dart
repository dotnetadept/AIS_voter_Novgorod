import 'package:aqueduct/aqueduct.dart';
import 'result.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class QuestionSession extends ManagedObject<_QuestionSession>
    implements _QuestionSession {
  client_models.QuestionSession toClient() {
    var clientSession = client_models.QuestionSession();

    clientSession.id = id;
    clientSession.meetingSessionId = meetingSessionId;
    clientSession.questionId = questionId;
    clientSession.votingModeId = votingModeId;
    clientSession.votingRegim = votingRegim;
    clientSession.decision = decision;
    clientSession.interval = interval;
    clientSession.usersCountRegistred = usersCountRegistred;
    clientSession.usersCountForSuccess = usersCountForSuccess;
    clientSession.usersCountForSuccessDisplay = usersCountForSuccessDisplay;
    clientSession.usersCountVoted = usersCountVoted;
    clientSession.usersCountVotedYes = usersCountVotedYes;
    clientSession.usersCountVotedNo = usersCountVotedNo;
    clientSession.usersCountVotedIndiffirent = usersCountVotedIndiffirent;
    clientSession.startDate = startDate;
    clientSession.endDate = endDate;
    clientSession.managerId = managerId;

    return clientSession;
  }
}

class _QuestionSession {
  @primaryKey
  int id;
  int meetingSessionId;
  int questionId;
  int votingModeId;
  String votingRegim;
  String decision;
  int interval;
  int usersCountRegistred;
  int usersCountForSuccess;
  int usersCountForSuccessDisplay;
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
  @Column(nullable: true)
  int managerId;

  ManagedSet<Result> results;
}
