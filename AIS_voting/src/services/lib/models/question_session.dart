import 'package:conduit_core/conduit_core.dart';
import 'result.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class QuestionSession extends ManagedObject<_QuestionSession>
    implements _QuestionSession {
  client_models.QuestionSession toClient() {
    var clientSession = client_models.QuestionSession();

    clientSession.id = id!;
    clientSession.meetingSessionId = meetingSessionId!;
    clientSession.questionId = questionId!;
    clientSession.votingModeId = votingModeId!;
    clientSession.votingRegim = votingRegim!;
    clientSession.decision = decision!;
    clientSession.interval = interval!;
    clientSession.usersCountRegistred = usersCountRegistred!;
    clientSession.usersCountForSuccess = usersCountForSuccess!;
    clientSession.usersCountForSuccessDisplay = usersCountForSuccessDisplay!;
    clientSession.usersCountVoted = usersCountVoted!;
    clientSession.usersCountVotedYes = usersCountVotedYes!;
    clientSession.usersCountVotedNo = usersCountVotedNo!;
    clientSession.usersCountVotedIndiffirent = usersCountVotedIndiffirent!;
    clientSession.startDate = startDate!;
    clientSession.endDate = endDate;
    clientSession.managerId = managerId;

    return clientSession;
  }
}

class _QuestionSession {
  @primaryKey
  late int? id;
  late int? meetingSessionId;
  late int? questionId;
  late int? votingModeId;
  late String? votingRegim;
  late String? decision;
  late int? interval;
  late int? usersCountRegistred;
  late int? usersCountForSuccess;
  late int? usersCountForSuccessDisplay;
  late int? usersCountVoted;
  late int? usersCountVotedYes;
  late int? usersCountVotedNo;
  late int? usersCountVotedIndiffirent;
  late DateTime? startDate;
  @Column(nullable: true)
  DateTime? endDate;
  @Column(nullable: true)
  int? managerId;

  late ManagedSet<Result> results;
}
