import 'dart:convert';
import 'dart:io';

import 'package:ais_agenda/Model/entity/aisform.dart';
import 'package:ais_agenda/Model/entity/aisform_field.dart';
import 'package:ais_agenda/Model/entity/aisform_item.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';
import 'package:ais_agenda/Model/entity/restricted_item.dart';
import 'package:ais_agenda/View/Utilities/group_utili.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/add_form_field_dialog.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Utilities/rights_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FormPage extends StatefulWidget {
  final AisForm form;

  const FormPage(this.form, {Key? key}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  @override
  void initState() {
    super.initState();

    AppState().setPreviousNavPath('Формы > ${widget.form.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: Text(AppState().getPreviousNavPath()),
      actions: <Widget>[
        getAddButton(widget.form.fields),
        Container(
          width: 20,
        ),
        RightsHelper().getRightsButton(context, widget.form),
        Container(
          width: 20,
        ),
        Tooltip(
          message: 'Сохранить',
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: _save,
            child: const Icon(Icons.save),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
      body: getFormWidget(widget.form, widget.form.fields),
    );
  }

  Widget getFormWidget(RestrictedItem parent, List<AisFormItem> items,
      {bool isVertical = true}) {
    return ReorderableListView.builder(
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
                child: getFormItem(parent, items[index])),
          ),
        );
      },
      onReorder: (int start, int current) {
        if (start < current) {
          var startItem = items[start];

          items.remove(startItem);
          items.add(startItem);
        }
        // dragging from bottom to top
        else if (start > current) {
          var startItem = items[start];
          items.remove(startItem);
          items.insert(current, startItem);
        }
        setState(() {});
      },
    );
  }

  Widget getFormItem(RestrictedItem parent, AisFormItem item) {
    var formField = item is AisFormField ? item : null;
    var formFieldGroup = item is AisFormFieldGroup ? item : null;

    if (formField != null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  color: Colors.lightBlue[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Поле типа ${formField.type.name}'),
                      ),
                      getFieldRequeredheckBox(formField),
                      RightsHelper().getRightsButton(context, formField),
                      getDeleteButton(widget.form, formField),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
            child: TextField(
              controller: TextEditingController(
                text: formField.name,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Наименование поля',
              ),
            ),
          ),
          Container(height: 10),
        ],
      );
    }

    if (formFieldGroup != null) {
      var groupLabel = formFieldGroup.isVertical ? "Колонка" : "Строка";

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
                        child: Text('$groupLabel: ${formFieldGroup.name}'),
                      ),
                      getShowGroupCheckBox(formFieldGroup),
                      getAddButton(formFieldGroup.fields),
                      RightsHelper().getRightsButton(context, formFieldGroup),
                      getDeleteButton(parent, formFieldGroup),
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
            child: getFormWidget(formFieldGroup, formFieldGroup.fields,
                isVertical: formFieldGroup.isVertical),
          ),
        ],
      );
    }

    return Container();
  }

  Future<void> showAddFormFieldDialog(
      BuildContext context, List<AisFormItem> items) async {
    AisFormItem? formItem = await showDialog<AisFormItem>(
      context: context,
      builder: (_) => const Dialog(
        child: AddFormFieldDialog(),
      ),
    );

    if (formItem != null) {
      items.add(formItem);
    }

    setState(() {});
  }

  Widget getAddButton(List<AisFormItem> fields) {
    return Tooltip(
      message: 'Добавить',
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        onPressed: () {
          showAddFormFieldDialog(context, fields);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getShowGroupCheckBox(AisFormFieldGroup group) {
    return Tooltip(
      message: 'Отображать название и границы',
      child: Checkbox(
        value: group.isShowBorder,
        onChanged: (bool? value) {
          group.isShowBorder = value == true;

          setState(() {});
        },
      ),
    );
  }

  Widget getFieldRequeredheckBox(AisFormField field) {
    return Tooltip(
      message: 'Обязательный параметр',
      child: Checkbox(
        value: field.isRequered,
        onChanged: (bool? value) {
          field.isRequered = value == true;

          setState(() {});
        },
      ),
    );
  }

  Widget getDeleteButton(RestrictedItem parent, RestrictedItem item) {
    return Tooltip(
      message: 'Удалить',
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        onPressed: () {
          var form = parent is AisForm ? parent : null;
          var formFieldGroup = parent is AisFormFieldGroup ? parent : null;

          if (form != null) {
            form.fields.remove(item);
          }
          if (formFieldGroup != null) {
            formFieldGroup.fields.remove(item);
          }

          setState(() {});
        },
        child: const Icon(Icons.delete),
      ),
    );
  }

  bool _save() {
    if (widget.form.id == '') {
      widget.form.id = const Uuid().v4();
      AppState().getForms().add(widget.form);
    }

    File localFile = File('assets/cfg/forms.json');
    localFile.writeAsStringSync(jsonEncode(AppState().getForms()));

    Provider.of<AppState>(context, listen: false).navigateToPage('/forms');

    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
