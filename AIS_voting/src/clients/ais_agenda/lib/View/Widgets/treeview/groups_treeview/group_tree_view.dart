import 'package:ais_agenda/View/Widgets/treeview/common/node/tree_node_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'group_tree_controller.dart';

class GroupTreeView extends StatefulWidget {
  const GroupTreeView({Key? key}) : super(key: key);

  @override
  State<GroupTreeView> createState() => _GroupTreeViewState();
}

class _GroupTreeViewState extends State<GroupTreeView> {
  @override
  Widget build(BuildContext context) {
    final appController = GroupsTreeController.of(context);

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
            nodeBuilder: (_, __) => TreeNodeTile(
              isSelectMode: appController.getIsSelectMode(),
            ),
          ),
        );
      },
    );
  }
}
