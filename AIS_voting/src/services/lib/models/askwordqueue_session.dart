import 'package:conduit_core/conduit_core.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class AskWordQueueSession extends ManagedObject<_AskWordQueueSession>
    implements _AskWordQueueSession {
  client_models.AskWordQueueSession toClient() {
    var clientSession = client_models.AskWordQueueSession(
      id: id,
      meetingSessionId: meetingSessionId,
      questionId: questionId,
      votingModeId: votingModeId,
      decision: decision,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      users: users.isEmpty
          ? <int>[]
          : users.split(',').map((i) => int.parse(i)).toList(),
    );

    clientSession.id = id;
    clientSession.meetingSessionId = meetingSessionId;
    clientSession.questionId = questionId;
    clientSession.votingModeId = votingModeId;
    clientSession.decision = decision;
    clientSession.interval = interval;
    clientSession.startDate = startDate;
    clientSession.endDate = endDate;
    clientSession.users = users.isEmpty
        ? <int>[]
        : users.split(',').map((i) => int.parse(i)).toList();

    return clientSession;
  }
}

class _AskWordQueueSession {
  @primaryKey
  late int id;
  late int meetingSessionId;
  late int questionId;
  late int votingModeId;
  late String decision;
  late int interval;
  late DateTime startDate;
  @Column(nullable: true)
  late DateTime endDate;
  late String users;
}
