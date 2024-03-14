import 'package:aqueduct/aqueduct.dart';
import 'package:ais_model/ais_model.dart' as client_models;

class SystemLog extends ManagedObject<_SystemLog> implements _SystemLog {
  client_models.SystemLog toClient() {
    var clientSession = client_models.SystemLog();

    clientSession.id = id;
    clientSession.type = type;
    clientSession.message = message;
    clientSession.time = time;

    return clientSession;
  }
}

class _SystemLog {
  @primaryKey
  int id;
  String type;
  String message;
  @Column(nullable: false)
  DateTime time;
}
