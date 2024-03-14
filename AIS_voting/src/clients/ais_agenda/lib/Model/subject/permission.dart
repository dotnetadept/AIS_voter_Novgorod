import '../base/base_item.dart';

class Permission extends BaseItem {
  String name = '';

  Permission();

  Map toJson() => {
        'id': id,
        'name': name,
      };

  Permission.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        super.fromJson(json);
}
