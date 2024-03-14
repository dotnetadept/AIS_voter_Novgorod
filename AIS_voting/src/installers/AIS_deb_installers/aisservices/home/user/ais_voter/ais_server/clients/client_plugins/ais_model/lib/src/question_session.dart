import 'meeting.dart';
import 'package:intl/intl.dart';

import 'result.dart';

class QuestionSession {
  int id;
  int meetingSessionId;
  int questionId;
  int votingModeId;
  String desicion;
  int interval;
  int usersCountRegistred;
  int usersCountForSuccess;
  int usersCountVoted;
  int usersCountVotedYes;
  int usersCountVotedNo;
  int usersCountVotedIndiffirent;
  DateTime startDate;
  DateTime endDate;
  List<Result> results;

  QuestionSession(
      {this.id,
      this.meetingSessionId,
      this.questionId,
      this.votingModeId,
      this.desicion,
      this.interval,
      this.usersCountRegistred,
      this.usersCountForSuccess,
      this.startDate,
      this.endDate});

  QuestionSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingSessionId = json['meetingSessionId'],
        questionId = json['questionId'],
        votingModeId = json['votingModeId'],
        desicion = json['desicion'],
        interval = json['interval'],
        usersCountRegistred = json['usersCountRegistred'],
        usersCountForSuccess = json['usersCountForSuccess'],
        usersCountVoted = json['usersCountVoted'],
        usersCountVotedYes = json['usersCountVotedYes'],
        usersCountVotedNo = json['usersCountVotedNo'],
        usersCountVotedIndiffirent = json['usersCountVotedIndiffirent'],
        startDate = DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']),
        results = json['results'] == null
            ? <Result>[]
            : json['results'].map<Result>((f) => Result.fromJson(f)).toList();

  List<String> toCsv(Meeting meeting) {
    var question = meeting.agenda.questions
        .firstWhere((element) => element.id == questionId, orElse: () => null);
    return [
      question?.name ?? '',
      DateFormat('HH:mm').format(endDate.toLocal() ?? startDate.toLocal()),
      (usersCountVotedYes ?? 0).toString(),
      (usersCountVotedNo ?? 0).toString(),
      (usersCountVotedIndiffirent ?? 0).toString(),
      (usersCountVotedYes ?? 0) >= usersCountForSuccess
          ? 'Принято'
          : 'Не принято',
    ];
  }
}
