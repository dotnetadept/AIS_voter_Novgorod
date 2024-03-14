import 'package:aqueduct/aqueduct.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class AskWordQueueSession extends ManagedObject<_AskWordQueueSession>
    implements _AskWordQueueSession {
  client_models.AskWordQueueSession toClient() {
    var clientSession = client_models.AskWordQueueSession();

    clientSession.id = id;
    clientSession.meetingSessionId = meetingSessionId;
    clientSession.questionId = questionId;
    clientSession.votingModeId = votingModeId;
    clientSession.decision = decision;
    clientSession.interval = interval;
    clientSession.startDate = startDate;
    clientSession.endDate = endDate;
    clientSession.users = (users == null || users.isEmpty)
        ? <int>[]
        : users.split(',').map((i) => int.parse(i)).toList();

    return clientSession;
  }
}

class _AskWordQueueSession {
  @primaryKey
  int id;
  int meetingSessionId;
  int questionId;
  int votingModeId;
  String decision;
  int interval;
  DateTime startDate;
  @Column(nullable: true)
  DateTime endDate;
  String users;
}
