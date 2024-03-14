import 'package:ais_agenda/Model/entity/aisform_field.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';

class GroupUtility {
  static double calcGroupHeight(AisFormFieldGroup group) {
    var height = 0.0;

    var items = group.fields.toList();

    if (!group.isVertical && group.fields.isNotEmpty) {
      height = 110.0;
      for (int i = 0; i < items.length; i++) {
        if (items[i] is AisFormFieldGroup) {
          var groupSize = calcGroupHeight(items[i] as AisFormFieldGroup) + 70;

          if (groupSize > height) {
            height = groupSize;
          }
        }
      }

      return height;
    }

    while (items.isNotEmpty) {
      var item = items.first;
      var formField = item is AisFormField ? item : null;
      var formFieldGroup = item is AisFormFieldGroup ? item : null;

      if (formField != null) {
        height += 120;
      }
      if (formFieldGroup != null) {
        height += 60;
        items.addAll(formFieldGroup.fields);
      }

      items.remove(item);
    }

    return height;
  }
}
