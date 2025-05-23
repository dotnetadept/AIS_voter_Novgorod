class AskWordQueueSession {
  late int id;
  late int meetingSessionId;
  late int questionId;
  late int votingModeId;
  late String decision;
  late int interval;
  late DateTime startDate;
  late DateTime? endDate;
  late List<int> users;

  AskWordQueueSession({
    required this.id,
    required this.meetingSessionId,
    required this.questionId,
    required this.votingModeId,
    required this.decision,
    required this.interval,
    required this.startDate,
    required this.endDate,
    required this.users,
  });

  Map toJson() => {
        'id': id,
        'meetingSessionId': meetingSessionId,
        'questionId': questionId,
        'votingModeId': votingModeId,
        'decision': decision,
        'interval': interval,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'users': users,
      };

  AskWordQueueSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingSessionId = json['meetingSessionId'],
        questionId = json['questionId'],
        votingModeId = json['votingModeId'],
        decision = json['decision'],
        interval = json['interval'],
        startDate = DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']),
        users = json['users'] == null
            ? <int>[]
            : json['users'].toList().cast<int>();

  // List<String> toCsv(Meeting meeting) {
  //   var question = meeting.agenda.questions
  //       .firstWhere((element) => element.id == questionId, orElse: () => null);
  //   return [
  //     question?.name ?? '',
  //     DateFormat('HH:mm').format(endDate.toLocal() ?? startDate.toLocal()),
  //     (usersCountVotedYes ?? 0).toString(),
  //     (usersCountVotedNo ?? 0).toString(),
  //     (usersCountVotedIndiffirent ?? 0).toString(),
  //     (usersCountVotedYes ?? 0) >= usersCountForSuccess
  //         ? 'Принято'
  //         : 'Не принято',
  //   ];
  // }

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }
}
