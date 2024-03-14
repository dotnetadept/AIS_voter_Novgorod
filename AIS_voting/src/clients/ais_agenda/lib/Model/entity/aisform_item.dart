import 'restricted_item.dart';

class AisFormItem extends RestrictedItem {
  String name = '';

  AisFormItem();

  @override
  Map toJson() => {'id': id, 'permissions': permissions, 'name': name};

  AisFormItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        super.fromJson(json);
}
