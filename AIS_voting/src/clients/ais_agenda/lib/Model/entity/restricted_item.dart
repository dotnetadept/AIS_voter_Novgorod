import '../subject/subject_action.dart';
import '../base/base_item.dart';

class RestrictedItem extends BaseItem {
  List<SubjectAction> permissions = <SubjectAction>[];

  RestrictedItem();

  Map toJson() => {
        'id': id,
        'permissions': permissions,
      };

  RestrictedItem.fromJson(Map<String, dynamic> json)
      : permissions = json['permissions']
            .map<SubjectAction>((i) => SubjectAction.fromJson(i))
            .toList(),
        super.fromJson(json);
}
