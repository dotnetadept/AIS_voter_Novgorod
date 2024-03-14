import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

const _kDarkBlue = Color(0xFF1565C0);

Future<void> showAddUserDialog(BuildContext context, [TreeNode? node]) async {
  final appController = GroupsTreeController.of(context);
  final treeController = appController.treeController;

  final localNode = node ?? appController.rootNode;

  User? formData = await showDialog<User>(
    context: context,
    builder: (_) => Dialog(
      child: AddUserDialog(parentLabel: localNode.data.toString()),
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

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({Key? key, required this.parentLabel}) : super(key: key);

  final String parentLabel;

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  User? _selectedUser;
  @override
  void dispose() {
    super.dispose();
  }

  static const TextStyle textFieldLabelStyle = TextStyle(
    color: Colors.blueGrey,
    fontWeight: FontWeight.bold,
  );

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
                  const TextSpan(text: 'Добавить пользователя для: '),
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
            padding: const EdgeInsets.only(left: 36, top: 8),
            child: DropdownButton<User>(
              value: _selectedUser,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedUser = value;
                });
              },
              items: AppState()
                  .getUsers()
                  .map<DropdownMenuItem<User>>((User value) {
                return DropdownMenuItem<User>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
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
    Navigator.of(context).pop(_selectedUser);
  }
}
