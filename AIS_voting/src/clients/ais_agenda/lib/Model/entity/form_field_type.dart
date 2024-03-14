import '../base/base_item.dart';

class FormFieldType extends BaseItem {
  String name = '';

  FormFieldType();

  Map toJson() => {
        'id': id,
        'name': name,
      };

  FormFieldType.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        super.fromJson(json);
}
