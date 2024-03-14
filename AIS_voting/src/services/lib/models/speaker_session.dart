import 'package:aqueduct/aqueduct.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class SpeakerSession extends ManagedObject<_SpeakerSession>
    implements _SpeakerSession {
  SpeakerSession();

  SpeakerSession.fromClient(client_models.SpeakerSession session) {
    id = session.id;
    meetingId = session.meetingId;
    userId = session.userId;
    terminalId = session.terminalId;
    name = session.name;
    type = session.type;
    interval = session.interval;
    startDate = session.startDate;
    endDate = session.endDate;
  }

  client_models.SpeakerSession toClient() {
    var clientSession = client_models.SpeakerSession();

    clientSession.id = id;
    clientSession.meetingId = meetingId;
    clientSession.userId = userId;
    clientSession.terminalId = terminalId;
    clientSession.name = name;
    clientSession.type = type;
    clientSession.interval = interval;
    clientSession.startDate = startDate;
    clientSession.endDate = endDate;

    return clientSession;
  }
}

class _SpeakerSession {
  @primaryKey
  int id;
  @Column(nullable: true)
  int meetingId;
  @Column(nullable: true)
  int userId;
  String terminalId;
  String name;
  String type;
  int interval;
  bool autoEnd;
  DateTime startDate;
  @Column(nullable: true)
  DateTime endDate;
}
