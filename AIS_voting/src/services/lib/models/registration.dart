import 'package:conduit_core/conduit_core.dart';
import 'registration_session.dart';

class Registration extends ManagedObject<_Registration>
    implements _Registration {}

class _Registration {
  @primaryKey
  late int id;
  late int userId;
  late int proxyId;

  @Relate(#registrations, onDelete: DeleteRule.cascade)
  late RegistrationSession registrationSession;
}
