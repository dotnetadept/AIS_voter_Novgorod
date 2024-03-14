class MeetingSession {
  int id;
  int meetingId;
  DateTime startDate;
  DateTime endDate;

  MeetingSession({this.id, this.meetingId, this.startDate, this.endDate});

  Map toJson() => {
        'id': id,
        'meetingId': meetingId,
        'startDate': startDate == null ? null : startDate.toIso8601String(),
        'endDate': endDate == null ? null : endDate.toIso8601String(),
      };

  MeetingSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingId = json['meetingId'],
        startDate = json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']);
}
