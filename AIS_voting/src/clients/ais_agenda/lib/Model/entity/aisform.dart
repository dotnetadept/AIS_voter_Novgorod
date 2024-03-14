import 'package:ais_agenda/Model/entity/aisform_item.dart';
import 'package:ais_agenda/Model/entity/aisform_type.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';

import 'aisform_field.dart';
import 'restricted_item.dart';

class AisForm extends RestrictedItem {
  String name = '';
  AisFormType type = AisFormType();
  List<AisFormItem> fields = <AisFormItem>[];

  AisForm();

  @override
  Map toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'permissions': permissions,
        'fields': fields,
      };

  AisForm.fromJson(Map<String, dynamic> json)
      : fields = json['fields'].map<AisFormItem>((i) {
          dynamic item;
          try {
            item = AisFormField.fromJson(i);
          } catch (e) {
            item = AisFormFieldGroup.fromJson(i);
          }

          return item as AisFormItem;
        }).toList(),
        type = AisFormType.fromJson(json['type']),
        name = json['name'],
        super.fromJson(json);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return name;
  }
}
