import 'package:aqueduct/aqueduct.dart';
import 'registration.dart';

class RegistrationSession extends ManagedObject<_RegistrationSession>
    implements _RegistrationSession {}

class _RegistrationSession {
  @primaryKey
  int id;
  int meetingId;
  int interval;
  @Column(nullable: true)
  DateTime startDate;
  @Column(nullable: true)
  DateTime endDate;

  ManagedSet<Registration> registrations;
}
