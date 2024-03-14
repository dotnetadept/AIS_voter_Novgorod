part of '../tree_node_tile.dart';

class UserActionsChip extends StatefulWidget {
  const UserActionsChip({Key? key}) : super(key: key);

  @override
  State<UserActionsChip> createState() => _UserActionsChipState();
}

class _UserActionsChipState extends State<UserActionsChip> {
  final GlobalKey<PopupMenuButtonState> _popupMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      key: _popupMenuKey,
      tooltip: 'Показать действия',
      offset: const Offset(0, 32),
      color: Colors.blueGrey.shade100,
      shape: kRoundedRectangleBorder,
      elevation: 6,
      itemBuilder: (_) => userPopupMenuItems,
      onSelected: (int selected) {
        if (selected == 0) {
          _delete(context, deleteSubtree: false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: const Icon(
          Icons.settings_rounded,
          color: Colors.blue,
          size: 32,
        ),
      ),
    );
  }

  void _delete(
    BuildContext context, {
    required bool deleteSubtree,
  }) {
    final treeController = GroupsTreeController.of(context).treeController;
    final treeNode = TreeNodeScope.of(context).node;
    final parent = treeNode.parent ?? treeController.rootNode;

    treeNode.delete(recursive: deleteSubtree);

    treeController.refreshNode(parent, keepExpandedNodes: true);
  }
}

const userPopupMenuItems = <PopupMenuEntry<int>>[
  PopupMenuItem(
    value: 0,
    child: ListTile(
      dense: true,
      title: Text('Удалить пользователя'),
      subtitle: Text('Удалить пользователя'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_forever_rounded),
    ),
  ),
];
