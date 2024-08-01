class MeetingSession {
  late int id;
  late int meetingId;
  late DateTime? startDate;
  late DateTime? endDate;

  MeetingSession({
    required this.id,
    required this.meetingId,
    required this.startDate,
    required this.endDate,
  });

  Map toJson() => {
        'id': id,
        'meetingId': meetingId,
        'startDate': startDate == null ? null : startDate?.toIso8601String(),
        'endDate': endDate == null ? null : endDate?.toIso8601String(),
      };

  MeetingSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingId = json['meetingId'],
        startDate = json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }
}
