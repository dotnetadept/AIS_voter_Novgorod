import 'aisform_field.dart';
import 'aisform_item.dart';

class AisFormFieldGroup extends AisFormItem {
  bool isVertical = true;
  bool isShowBorder = true;
  List<AisFormItem> fields = <AisFormItem>[];

  AisFormFieldGroup();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'name': name,
        'isVertical': isVertical,
        'isShowBorder': isShowBorder,
        'fields': fields,
      };

  AisFormFieldGroup.fromJson(Map<String, dynamic> json)
      : fields = json['fields'].map<AisFormItem>((i) {
          dynamic item;
          try {
            item = AisFormField.fromJson(i);
          } catch (e) {
            item = AisFormFieldGroup.fromJson(i);
          }

          return item as AisFormItem;
        }).toList(),
        isVertical = json['isVertical'],
        isShowBorder = json['isShowBorder'],
        super.fromJson(json);
}
