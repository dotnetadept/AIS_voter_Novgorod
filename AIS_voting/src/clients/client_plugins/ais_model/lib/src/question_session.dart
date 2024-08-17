import 'package:collection/collection.dart';

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
  late DateTime? endDate;
  late List<Result> results;
  late int? managerId;

  QuestionSession();

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
        'startDate': startDate.toIso8601String(),
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
        usersCountVoted = json['usersCountVoted'] ?? 0,
        usersCountVotedYes = json['usersCountVotedYes'] ?? 0,
        usersCountVotedNo = json['usersCountVotedNo'] ?? 0,
        usersCountVotedIndiffirent = json['usersCountVotedIndiffirent'] ?? 0,
        startDate = DateTime.parse(json['startDate']),
        endDate =
            json['endDate'] == null ? null : DateTime.parse(json['endDate']),
        results = json['results'] == null
            ? <Result>[]
            : json['results'].map<Result>((f) => Result.fromJson(f)).toList(),
        managerId = json['managerId'];

  List<String> toCsv(Meeting meeting) {
    var question = meeting.agenda?.questions
        .firstWhereOrNull((element) => element.id == questionId);
    return [
      question?.name ?? '',
      DateFormat('HH:mm').format(endDate?.toLocal() ?? startDate.toLocal()),
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
