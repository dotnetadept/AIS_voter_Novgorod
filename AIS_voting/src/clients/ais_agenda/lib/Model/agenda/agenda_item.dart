import '../entity/restricted_item.dart';

class AgendaItem extends RestrictedItem {
  String parentId = '';
  String name = '';

  AgendaItem();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'parentId': parentId,
        'name': name,
      };

  AgendaItem.fromJson(Map<String, dynamic> json)
      : parentId = json['parentId'],
        name = json['name'],
        super.fromJson(json);

  @override
  String toString() {
    return name;
  }
}
