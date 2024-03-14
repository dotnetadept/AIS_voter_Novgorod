import '../base/base_item.dart';

class AisAction extends BaseItem {
  String name = '';

  AisAction();

  Map toJson() => {
        'id': id,
        'name': name,
      };

  AisAction.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        super.fromJson(json);
}
