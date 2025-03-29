import 'package:conduit_core/conduit_core.dart';
import 'registration.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class RegistrationSession extends ManagedObject<_RegistrationSession>
    implements _RegistrationSession {
  client_models.RegistrationSession toClient() {
    var clientSession = client_models.RegistrationSession();

    clientSession.id = id!;
    clientSession.meetingId = meetingId!;
    clientSession.interval = interval!;
    clientSession.startDate = startDate;
    clientSession.endDate = endDate;

    return clientSession;
  }
}

class _RegistrationSession {
  @primaryKey
  late int? id;
  late int? meetingId;
  late int? interval;
  late DateTime? startDate;
  @Column(nullable: true)
  DateTime? endDate;

  late ManagedSet<Registration>? registrations;
}
