import 'package:ais_agenda/Model/agenda/file.dart';
import 'package:ais_agenda/Model/agenda/question.dart';
import 'package:ais_agenda/Model/base/base_item.dart';
import 'package:ais_agenda/Model/subject/group.dart';
import 'package:ais_agenda/Model/subject/subject.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/add_file_dialog.dart';
import 'package:ais_agenda/View/Dialogs/add_node_dialog.dart';
import 'package:ais_agenda/View/Dialogs/add_question_dialog.dart';
import 'package:ais_agenda/View/Dialogs/add_user_dialog.dart';
import 'package:ais_agenda/View/Widgets/treeview/common/utility/snackbar.dart';

import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_controller.dart';
import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:provider/provider.dart';

part 'actions/group_actions_chip.dart';
part 'actions/user_actions_chip.dart';
part 'actions/subject_actions_chip.dart';
part 'actions/file_actions_chip.dart';
part 'actions/question_actions_chip.dart';
part 'views/_title.dart';

const RoundedRectangleBorder kRoundedRectangleBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

class TreeNodeTile extends StatefulWidget {
  const TreeNodeTile({Key? key, this.isSelectMode = false}) : super(key: key);

  final bool isSelectMode;

  @override
  State<TreeNodeTile> createState() => _TreeNodeTileState();
}

class _TreeNodeTileState extends State<TreeNodeTile> {
  @override
  Widget build(BuildContext context) {
    final nodeScope = TreeNodeScope.of(context);

    Widget icon = const Icon(Icons.account_box);
    Widget actions = const UserActionsChip();

    if (nodeScope.node.data is Group) {
      actions = const GroupActionsChip();
      icon = const NodeWidgetLeadingIcon(useFoldersOnly: true);
    }

    if (widget.isSelectMode) {
      actions = const SubjectActionsChip();
    }

    if (nodeScope.node.data is AisFile) {
      actions = const FileActionsChip();
      icon = const Icon(Icons.file_present);
    }

    if (nodeScope.node.data is Question) {
      actions = const QuestionActionsChip();
      icon = const NodeWidgetLeadingIcon(useFoldersOnly: true);
    }

    return InkWell(
      onTap: () => _describeAncestors(nodeScope.node),
      child: Row(children: [
        const LinesWidget(),
        icon,
        const Expanded(child: _NodeTitle()),
        const SizedBox(width: 8),
        actions
      ]),
    );
  }

  void _describeAncestors(TreeNode node) {
    final ancestors = node.ancestors.map((ancestor) => ancestor.id).join('/');

    showSnackBar(
      context,
      'Path of "${node.label}": /$ancestors/${node.id}',
      duration: const Duration(seconds: 3),
    );
  }
}
