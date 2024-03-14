import 'aisform_item.dart';
import 'form_field_type.dart';

class AisFormField extends AisFormItem {
  FormFieldType type = FormFieldType();
  bool isRequered = true;
  String settings = '';

  AisFormField();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'type': type,
        'name': name,
        'isRequered': isRequered,
        'settings': settings
      };

  AisFormField.fromJson(Map<String, dynamic> json)
      : type = FormFieldType.fromJson(json['type']),
        isRequered = json['isRequered'],
        settings = json['settings'],
        super.fromJson(json);
}
