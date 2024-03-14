import 'aisform_field.dart';
import 'restricted_item.dart';

class FormFieldValue extends RestrictedItem {
  AisFormField formField = AisFormField();
  dynamic value;

  FormFieldValue();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'formField': formField,
        'value': value
      };

  FormFieldValue.fromJson(Map<String, dynamic> json)
      : formField = json['formField'],
        value = json['value'],
        super.fromJson(json);
}
