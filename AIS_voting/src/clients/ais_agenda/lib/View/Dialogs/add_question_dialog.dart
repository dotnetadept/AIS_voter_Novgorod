import 'package:ais_agenda/Model/agenda/question.dart';
import 'package:ais_agenda/Model/entity/aisform.dart';

import 'package:ais_agenda/State/app_state.dart';

import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:uuid/uuid.dart';

Future<void> showAddQuestionDialog(BuildContext context, TreeNode? parent,
    QuestionsTreeController controller) async {
  final treeController = controller.treeController;
  final localNode = parent ?? controller.rootNode;

  Question? formData = await showDialog<Question>(
    context: context,
    builder: (_) => const Dialog(
      child: AddQuestionDialog(),
    ),
  );

  if (formData != null) {
    localNode.addChild(
        TreeNode(id: formData.id, label: formData.toString(), data: formData));

    if (localNode.isRoot) {
      treeController.reset(keepExpandedNodes: true);
    } else if (treeController.isExpanded(localNode.id)) {
      treeController.refreshNode(localNode);
    } else {
      treeController.expandNode(localNode);
    }
  }
}

class AddQuestionDialog extends StatefulWidget {
  const AddQuestionDialog({Key? key}) : super(key: key);

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Question _question;

  late AisForm _selectedForm;
  late List<AisForm> _forms;

  late final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _forms = AppState()
        .getForms()
        .where((element) => element.type.name == 'question')
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
                    TextSpan(text: 'Добавить вопрос:'),
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
                    'Шаблон вопроса',
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
    _question = Question();

    _question.id = const Uuid().v4();
    _question.name = nameController.text.trim();
    _question.template = _selectedForm;

    Navigator.of(context).pop(_question);
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
