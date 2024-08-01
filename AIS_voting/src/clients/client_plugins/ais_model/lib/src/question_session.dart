import 'meeting.dart';
import 'package:intl/intl.dart';

import 'result.dart';

class QuestionSession {
  late int id;
  late int meetingSessionId;
  late int questionId;
  late int votingModeId;
  late String votingRegim;
  late String decision;
  late int interval;
  late int usersCountRegistred;
  late int usersCountForSuccess;
  late int usersCountForSuccessDisplay;

  late int usersCountVoted;
  late int usersCountVotedYes;
  late int usersCountVotedNo;
  late int usersCountVotedIndiffirent;
  late DateTime startDate;
  late DateTime endDate;
  late List<Result> results;
  late int managerId;

  QuestionSession({
    required this.id,
    required this.meetingSessionId,
    required this.questionId,
    required this.votingModeId,
    required this.votingRegim,
    required this.decision,
    required this.interval,
    required this.usersCountRegistred,
    required this.usersCountForSuccess,
    required this.usersCountForSuccessDisplay,
    required this.startDate,
    required this.endDate,
    required this.managerId,
  });

  Map toJson() => {
        'id': id,
        'meetingSessionId': meetingSessionId,
        'questionId': questionId,
        'votingModeId': votingModeId,
        'votingRegim': votingRegim,
        'decision': decision,
        'interval': interval,
        'usersCountRegistred': usersCountRegistred,
        'usersCountForSuccess': usersCountForSuccess,
        'usersCountForSuccessDisplay': usersCountForSuccessDisplay,
        'usersCountVoted': usersCountVoted,
        'usersCountVotedYes': usersCountVotedYes,
        'usersCountVotedNo': usersCountVotedNo,
        'usersCountVotedIndiffirent': usersCountVotedIndiffirent,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'managerId': managerId
      };

  QuestionSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meetingSessionId = json['meetingSessionId'],
        questionId = json['questionId'],
        votingModeId = json['votingModeId'],
        votingRegim = json['votingRegim'],
        decision = json['decision'],
        interval = json['interval'],
        usersCountRegistred = json['usersCountRegistred'],
        usersCountForSuccess = json['usersCountForSuccess'],
        usersCountForSuccessDisplay = json['usersCountForSuccessDisplay'],
        usersCountVoted = json['usersCountVoted'],
        usersCountVotedYes = json['usersCountVotedYes'],
        usersCountVotedNo = json['usersCountVotedNo'],
        usersCountVotedIndiffirent = json['usersCountVotedIndiffirent'],
        startDate = DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']),
        results = json['results'] == null
            ? <Result>[]
            : json['results'].map<Result>((f) => Result.fromJson(f)).toList(),
        managerId = json['managerId'];

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

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }
}
