import 'package:ais_agenda/Model/entity/aisform_type.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../Model/entity/aisform.dart';

class AddFormDialog extends StatefulWidget {
  const AddFormDialog({Key? key}) : super(key: key);

  @override
  State<AddFormDialog> createState() => _AddFormDialogState();
}

class _AddFormDialogState extends State<AddFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AisForm _form;
  late final TextEditingController nameController = TextEditingController();
  late AisFormType _selectedFormType;
  late List<AisFormType> _formTypes;

  @override
  void initState() {
    super.initState();

    _formTypes = AppState().getFormTypes();
    _selectedFormType = _formTypes.first;
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
                    TextSpan(text: 'Добавить форму:'),
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
                    'Тип формы',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: DropdownButton<AisFormType>(
                    value: _selectedFormType,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (AisFormType? value) {
                      if (value != null) {
                        setState(() {
                          _selectedFormType = value;
                        });
                      }
                    },
                    items: _formTypes.map<DropdownMenuItem<AisFormType>>(
                        (AisFormType value) {
                      return DropdownMenuItem<AisFormType>(
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
    _form = AisForm();

    _form.id = const Uuid().v4();
    _form.name = nameController.text.trim();
    _form.type = _selectedFormType;

    Navigator.of(context).pop(_form);
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
