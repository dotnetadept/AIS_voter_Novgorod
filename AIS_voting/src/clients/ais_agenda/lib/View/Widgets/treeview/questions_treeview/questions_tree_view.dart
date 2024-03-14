import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_controller.dart';
import 'package:ais_agenda/View/Widgets/treeview/common/node/tree_node_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class QuestionsTreeView extends StatefulWidget {
  const QuestionsTreeView({Key? key}) : super(key: key);

  @override
  State<QuestionsTreeView> createState() => _QuestionsTreeViewState();
}

class _QuestionsTreeViewState extends State<QuestionsTreeView> {
  @override
  Widget build(BuildContext context) {
    final appController = QuestionsTreeController.of(context);

    return ValueListenableBuilder<TreeViewTheme>(
      valueListenable: appController.treeViewTheme,
      builder: (_, treeViewTheme, __) {
        return Scrollbar(
          thumbVisibility: false,
          controller: appController.scrollController,
          child: TreeView(
            controller: appController.treeController,
            theme: treeViewTheme,
            scrollController: appController.scrollController,
            nodeBuilder: (_, __) => const TreeNodeTile(),
          ),
        );
      },
    );
  }
}
