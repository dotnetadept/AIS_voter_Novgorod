import 'package:conduit_core/conduit_core.dart';
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
    interval = session.interval ?? 0;
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
  late int id;
  @Column(nullable: true)
  int? meetingId;
  @Column(nullable: true)
  int? userId;
  late String terminalId;
  late String name;
  late String type;
  late int interval;
  late bool autoEnd;
  late DateTime startDate;
  @Column(nullable: true)
  DateTime? endDate;
}
