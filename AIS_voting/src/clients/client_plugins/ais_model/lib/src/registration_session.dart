import 'registration.dart';

class RegistrationSession {
  late int id;
  late int meetingId;
  late int interval;
  late DateTime startDate;
  late DateTime? endDate;
  late List<Registration> registrations;

  RegistrationSession({
    required this.id,
    required this.meetingId,
    required this.interval,
    required this.startDate,
    required this.endDate,
  });

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
