class SpeakerSession {
  int id;
  int meetingId;
  int userId;
  String terminalId;
  String name;
  String type;
  int interval;
  bool autoEnd;
  DateTime startDate;
  DateTime endDate;

  SpeakerSession();

  Map toJson() => {
        'id': id,
        'meetingId': meetingId,
        'userId': userId,
        'terminalId': terminalId,
        'name': name,
        'type': type,
        'interval': interval,
        'autoEnd': autoEnd,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String()
      };

  SpeakerSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingId = json['meetingId'],
        userId = json['userId'],
        terminalId = json['terminalId'],
        name = json['name'],
        type = json['type'],
        interval = json['interval'],
        autoEnd = json['autoEnd'],
        startDate = json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']);
}
