import 'package:ais_agenda/Model/agenda/file.dart';
import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:uuid/uuid.dart';

Future<void> showAddFileDialog(BuildContext context, [TreeNode? node]) async {
  final appController = QuestionsTreeController.of(context);
  final treeController = appController.treeController;

  final localNode = node ?? appController.rootNode;

  AisFile? formData = await showDialog<AisFile>(
    context: context,
    builder: (_) => const Dialog(
      child: AddFileDialog(),
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

class AddFileDialog extends StatefulWidget {
  const AddFileDialog({Key? key}) : super(key: key);

  @override
  State<AddFileDialog> createState() => _AddFileDialogState();
}

class _AddFileDialogState extends State<AddFileDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AisFile _file;

  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController commentController = TextEditingController();
  late final TextEditingController pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            const Padding(
              padding: EdgeInsets.only(left: 36, top: 8),
              child: Text('Описание'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextFormField(
                autofocus: true,
                controller: commentController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 36, top: 8),
              child: Text('Путь файла'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextFormField(
                autofocus: true,
                controller: pathController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Выберите  путь';
                  }
                  return null;
                },
              ),
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
    _file = AisFile();

    _file.id = const Uuid().v4();
    _file.name = nameController.text.trim();
    _file.comment = commentController.text.trim();
    _file.path = pathController.text.trim();

    Navigator.of(context).pop(_file);
  }

  @override
  void dispose() {
    nameController.dispose();
    commentController.dispose();
    pathController.dispose();

    super.dispose();
  }
}
