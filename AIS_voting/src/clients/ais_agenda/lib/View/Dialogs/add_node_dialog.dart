import 'package:ais_agenda/Model/subject/group.dart';
import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:uuid/uuid.dart';

const _kDarkBlue = Color(0xFF1565C0);

Future<void> showAddNodeDialog(BuildContext context, [TreeNode? node]) async {
  final appController = GroupsTreeController.of(context);
  final treeController = appController.treeController;

  final localNode = node ?? appController.rootNode;

  Group? formData = await showDialog<Group>(
    context: context,
    builder: (_) => Dialog(
      child: AddNodeDialog(parentLabel: localNode.data.toString()),
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

class AddNodeDialog extends StatefulWidget {
  const AddNodeDialog({Key? key, required this.parentLabel}) : super(key: key);

  final String parentLabel;

  @override
  State<AddNodeDialog> createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends State<AddNodeDialog> {
  static const TextStyle textFieldLabelStyle = TextStyle(
    color: Colors.blueGrey,
    fontWeight: FontWeight.bold,
  );

  late final TextEditingController labelController = TextEditingController();

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Добавить подгруппу для: '),
                  TextSpan(
                    text: widget.parentLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          const Divider(
            color: Colors.black26,
            height: 10,
            thickness: 2,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 36, top: 8),
            child: Text('Наименование', style: textFieldLabelStyle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _TextField(
              controller: labelController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ButtonBar(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: _kDarkBlue),
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: _kDarkBlue),
                  onPressed: _submitted,
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitted() {
    final label = labelController.text.trim();

    final group = Group();
    group.id = const Uuid().v4();
    group.name = label;

    Navigator.of(context).pop(group);
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: _kDarkBlue),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: _kDarkBlue,
      style: const TextStyle(
        color: _kDarkBlue,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(16, 2, 16, 2),
        focusColor: _kDarkBlue,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: InputBorder.none,
        fillColor: Color(0x551565C0),
        filled: true,
      ),
    );
  }
}
