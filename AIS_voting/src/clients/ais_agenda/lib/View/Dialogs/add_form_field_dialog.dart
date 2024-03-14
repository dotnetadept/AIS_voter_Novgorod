import 'package:ais_agenda/Model/entity/aisform_field.dart';
import 'package:ais_agenda/Model/entity/aisform_item.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';
import 'package:ais_agenda/Model/entity/form_field_type.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddFormFieldDialog extends StatefulWidget {
  const AddFormFieldDialog({Key? key}) : super(key: key);

  @override
  State<AddFormFieldDialog> createState() => _AddFormFieldDialogState();
}

class _AddFormFieldDialogState extends State<AddFormFieldDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AisFormItem _formItem;
  late FormFieldType _selectedFieldType;
  late List<FormFieldType> _formFieldTypes;

  late final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _formFieldTypes = AppState().getFormFieldTypes();

    _selectedFieldType = _formFieldTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Добавить поле:'),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 36, top: 8),
              child: Text('Наименование'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextFormField(
                autofocus: true,
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите наименование';
                  }
                  return null;
                },
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 36, top: 8),
                  child: Text(
                    'Тип поля',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: DropdownButton<FormFieldType>(
                    value: _selectedFieldType,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (FormFieldType? value) {
                      if (value != null) {
                        setState(() {
                          _selectedFieldType = value;
                        });
                      }
                    },
                    items: _formFieldTypes.map<DropdownMenuItem<FormFieldType>>(
                        (FormFieldType value) {
                      return DropdownMenuItem<FormFieldType>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ButtonBar(
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: _submitted,
                    child: const Text('Добавить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitted() {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    if (_selectedFieldType.name == 'group' ||
        _selectedFieldType.name == 'row') {
      var fieldGroup = AisFormFieldGroup();
      fieldGroup.id = const Uuid().v4();
      fieldGroup.name = nameController.text.trim();
      fieldGroup.isVertical = _selectedFieldType.name == 'group';

      _formItem = fieldGroup;
    } else {
      var formField = AisFormField();
      formField.id = const Uuid().v4();
      formField.name = nameController.text.trim();
      formField.type = _selectedFieldType;

      _formItem = formField;
    }

    Navigator.of(context).pop(_formItem);
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
