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

  Map toJson() => {
        'id': id,
        'meetingId': meetingId,
        'interval': interval,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String()
      };

  RegistrationSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingId = json['meetingId'],
        interval = json['interval'],
        startDate = DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']),
        registrations = json['registrations'] == null
            ? <Registration>[]
            : json['registrations']
                .map<Registration>((f) => Registration.fromJson(f))
                .toList();
}
