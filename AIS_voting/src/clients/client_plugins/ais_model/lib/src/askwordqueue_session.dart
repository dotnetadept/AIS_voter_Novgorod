class AskWordQueueSession {
  int id;
  int meetingSessionId;
  int questionId;
  int votingModeId;
  String decision;
  int interval;
  DateTime startDate;
  DateTime endDate;
  List<int> users;

  AskWordQueueSession(
      {this.id,
      this.meetingSessionId,
      this.questionId,
      this.votingModeId,
      this.decision,
      this.interval,
      this.startDate,
      this.endDate});

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
