import 'package:ais_model/src/question_session.dart';
import 'package:intl/intl.dart';

import 'group.dart';

class Result {
  int id;
  int userId;
  int questionSessionId;
  String result;

  Result({this.id, this.userId, this.questionSessionId});

  Result.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        questionSessionId = json['questionSession']['id'],
        result = json['result'];

  List<String> toCsv(Group group, QuestionSession questionSession) {
    var user = group.groupUsers
        .firstWhere((element) => element.user.id == userId, orElse: () => null);
    return [
      user?.user?.toString() ?? '',
      DateFormat('HH:mm').format(questionSession.endDate.toLocal() ??
          questionSession.startDate.toLocal()),
      result == 'ЗА' ? 'Х' : '',
      result == 'ПРОТИВ' ? 'Х' : '',
      result == 'ВОЗДЕРЖАЛСЯ' ? 'Х' : '',
      ''
    ];
  }
}
