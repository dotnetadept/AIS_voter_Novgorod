import 'package:ais_agenda/Model/entity/aisform_field.dart';
import 'package:ais_agenda/Model/entity/aisform_item.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';
import 'package:ais_agenda/Model/entity/restricted_item.dart';
import 'package:ais_agenda/View/Utilities/rights_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../Utilities/group_utili.dart';

class FormViewHelper {
  Widget getFormWidget(
      BuildContext context, RestrictedItem parent, List<AisFormItem> items,
      {bool isVertical = true}) {
    return ListView.builder(
      scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          key: Key(items[index].id),
          constraints:
              BoxConstraints(maxWidth: isVertical ? double.infinity : 400),
          child: ListTile(
            contentPadding: const EdgeInsets.all(5),
            title: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: getFormItem(context, parent, items[index])),
          ),
        );
      },
    );
  }

  Widget getFormItem(
      BuildContext context, RestrictedItem parent, AisFormItem item) {
    var formField = item is AisFormField ? item : null;
    var formFieldGroup = item is AisFormFieldGroup ? item : null;

    if (formField != null) {
      return Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: getFormFieldView(formField),
            ),
            RightsHelper().getRightsButton(context, formField),
          ],
        ),
      );
    }

    if (formFieldGroup != null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
                  height: 40,
                  color: Colors.lightBlue,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(formFieldGroup.name),
                      ),
                      RightsHelper().getRightsButton(context, formFieldGroup),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
            constraints: BoxConstraints(
              minHeight: 0,
              minWidth: double.infinity,
              maxHeight: GroupUtility.calcGroupHeight(formFieldGroup),
            ),
            child: getFormWidget(context, formFieldGroup, formFieldGroup.fields,
                isVertical: formFieldGroup.isVertical),
          ),
        ],
      );
    }

    return Container();
  }

  Widget getFormFieldView(AisFormField field) {
    var validator = FormBuilderValidators.compose([
      FormBuilderValidators.required(),
    ]);

    switch (field.type.name) {
      case "text":
        return FormBuilderTextField(
          name: field.name,
          validator: validator,
          decoration: InputDecoration(
            labelText: field.name,
          ),
        );

      case "date":
        return FormBuilderDateTimePicker(
          name: field.name,
          validator: validator,
          decoration: InputDecoration(
            labelText: field.name,
          ),
        );

      case "int":
        return FormBuilderTextField(
          name: field.name,
          validator: validator,
          decoration: InputDecoration(
            labelText: field.name,
          ),
        );
      // case "user":
      //   return getDropDownForSubject();

      default:
        return Container();
    }
  }
}
