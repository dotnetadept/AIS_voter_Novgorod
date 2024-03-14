import 'package:ais_agenda/Model/subject/permission.dart';

import 'aisaction.dart';
import 'subject.dart';

import '../base/base_item.dart';

class SubjectAction extends BaseItem {
  Subject subject = Subject();
  AisAction action = AisAction();
  Permission permission = Permission();

  SubjectAction();

  Map toJson() => {
        'id': id,
        'subject': subject,
        'action': action,
        'permission': permission,
      };

  SubjectAction.fromJson(Map<String, dynamic> json)
      : subject = Subject.fromJson(json['subject']),
        action = AisAction.fromJson(json['action']),
        permission = Permission.fromJson(json['permission']),
        super.fromJson(json);
}
