import 'registration.dart';

class RegistrationSession {
  int id;
  int meetingId;
  int interval;
  DateTime startDate;
  DateTime endDate;
  List<Registration> registrations;

  RegistrationSession(
      {this.id, this.meetingId, this.interval, this.startDate, this.endDate});

  RegistrationSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingId = json['meetingId'],
        interval = json['interval'],
        startDate = DateTime.parse(json['startDate']),
        endDate = DateTime.parse(json['endDate']),
        registrations = json['registrations'] == null
            ? <Registration>[]
            : json['registrations']
                .map<Registration>((f) => Registration.fromJson(f))
                .toList();
}
