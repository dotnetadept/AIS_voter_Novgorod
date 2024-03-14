import 'package:aqueduct/aqueduct.dart';
import 'registration_session.dart';

class Registration extends ManagedObject<_Registration>
    implements _Registration {}

class _Registration {
  @primaryKey
  int id;
  int userId;
  int proxyId;

  @Relate(#registrations, onDelete: DeleteRule.cascade)
  RegistrationSession registrationSession;
}
