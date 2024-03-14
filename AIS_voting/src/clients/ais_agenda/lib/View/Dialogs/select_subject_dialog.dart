import 'package:ais_agenda/Model/subject/subject.dart';
import 'package:ais_agenda/View/Widgets/treeview/common/utility/unfocus.dart';

import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_controller.dart';
import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_view.dart';

import 'package:flutter/material.dart';

class SelectSubjectDialog extends StatefulWidget {
  const SelectSubjectDialog({Key? key}) : super(key: key);

  @override
  State<SelectSubjectDialog> createState() => _SelectSubjectDialogState();
}

class _SelectSubjectDialogState extends State<SelectSubjectDialog> {
  late final GroupsTreeController treeController = GroupsTreeController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupAppControllerScope(
      controller: treeController,
      child: FutureBuilder<void>(
        future: treeController.init(isSelectMode: true),
        builder: (_, __) {
          if (treeController.isInitialized) {
            return Column(
              children: [
                const Expanded(
                  child: Unfocus(
                    child: GroupTreeView(),
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
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _submitted() {
    Subject subject = treeController.getSelectedNode();

    Navigator.of(context).pop(subject);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
