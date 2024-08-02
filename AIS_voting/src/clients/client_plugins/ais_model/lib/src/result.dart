import 'package:ais_model/src/question_session.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'group.dart';

class Result {
  late int id;
  late int userId;
  late int proxyId;
  late int questionSessionId;
  late String result;

  Result({
    required this.id,
    required this.userId,
    required this.questionSessionId,
  });

  Result.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        questionSessionId = json['questionSession']['id'],
        result = json['result'];

  List<String> toCsv(Group group, QuestionSession questionSession) {
    var user = group.groupUsers
        .firstWhereOrNull((element) => element.user.id == userId);
    return [
      user?.user?.toString() ?? '',
      DateFormat('HH:mm').format(questionSession.endDate?.toLocal() ??
          questionSession.startDate.toLocal()),
      result == 'ЗА' ? 'Х' : '',
      result == 'ПРОТИВ' ? 'Х' : '',
      result == 'ВОЗДЕРЖАЛСЯ' ? 'Х' : '',
      ''
    ];
  }
}
