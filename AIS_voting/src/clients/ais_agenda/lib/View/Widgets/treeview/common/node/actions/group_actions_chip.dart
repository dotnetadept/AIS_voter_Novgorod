part of '../tree_node_tile.dart';

class GroupActionsChip extends StatefulWidget {
  const GroupActionsChip({Key? key}) : super(key: key);

  @override
  State<GroupActionsChip> createState() => _GroupActionsChipState();
}

class _GroupActionsChipState extends State<GroupActionsChip> {
  final GlobalKey<PopupMenuButtonState> _popupMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final nodeScope = TreeNodeScope.of(context);

    return PopupMenuButton<int>(
      key: _popupMenuKey,
      tooltip: 'Показать действия',
      offset: const Offset(0, 32),
      color: Colors.blueGrey.shade100,
      shape: kRoundedRectangleBorder,
      elevation: 6,
      itemBuilder: (_) => groupPopupMenuItems,
      onSelected: (int selected) {
        if (selected == 0) {
          showAddUserDialog(context, nodeScope.node);
        }
        if (selected == 1) {
          showAddNodeDialog(context, nodeScope.node);
        }
        if (selected == 2) {
          // edit
        }
        if (selected == 3) {
          // move right
        }
        if (selected == 4) {
          // move left
        }
        if (selected == 5) {
          _delete(context, deleteSubtree: true);
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

const groupPopupMenuItems = <PopupMenuEntry<int>>[
  PopupMenuItem(
    value: 0,
    child: ListTile(
      dense: true,
      title: Text('Добавить пользователя'),
      subtitle: Text('Добавить пользователя'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.account_box),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 1,
    child: ListTile(
      dense: true,
      title: Text('Добавить подгруппу'),
      subtitle: Text('Добавить дочернюю группу'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.add_circle_rounded),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 2,
    child: ListTile(
      dense: true,
      title: Text('Редактировать'),
      subtitle: Text('Открыть редактор группы'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.edit),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 3,
    child: ListTile(
      dense: true,
      title: Text('Сместить вправо'),
      subtitle: Text('Сместить группу вправо'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.arrow_right),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 4,
    child: ListTile(
      dense: true,
      title: Text('Сместить влево'),
      subtitle: Text('Сместить группу влево'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.arrow_left),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 5,
    child: ListTile(
      dense: true,
      title: Text('Удалить группу'),
      subtitle: Text('Удалить группу включая дочерние элементы'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_forever_rounded),
    ),
  ),
];
