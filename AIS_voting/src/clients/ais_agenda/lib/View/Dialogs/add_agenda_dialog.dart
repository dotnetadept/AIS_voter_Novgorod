import 'package:ais_agenda/Model/entity/aisform.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../Model/agenda/agenda.dart';

class AddAgendaDialog extends StatefulWidget {
  const AddAgendaDialog({Key? key}) : super(key: key);

  @override
  State<AddAgendaDialog> createState() => _AddAgendaDialogState();
}

class _AddAgendaDialogState extends State<AddAgendaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Agenda _agenda;
  late final TextEditingController nameController = TextEditingController();
  late AisForm _selectedForm;
  late List<AisForm> _forms;

  @override
  void initState() {
    super.initState();

    _forms = AppState()
        .getForms()
        .where((element) => element.type.name == 'agenda')
        .toList();

    _selectedForm = _forms.first;
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
                    TextSpan(text: 'Добавить повестку:'),
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
                    'Шаблон повестки',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: DropdownButton<AisForm>(
                    value: _selectedForm,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (AisForm? value) {
                      if (value != null) {
                        setState(() {
                          _selectedForm = value;
                        });
                      }
                    },
                    items:
                        _forms.map<DropdownMenuItem<AisForm>>((AisForm value) {
                      return DropdownMenuItem<AisForm>(
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
    _agenda = Agenda();

    _agenda.id = const Uuid().v4();
    _agenda.name = nameController.text.trim();
    _agenda.template = _selectedForm;

    Navigator.of(context).pop(_agenda);
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
