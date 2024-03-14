part of '../tree_node_tile.dart';

class QuestionActionsChip extends StatefulWidget {
  const QuestionActionsChip({Key? key}) : super(key: key);

  @override
  State<QuestionActionsChip> createState() => _QuestionActionsChipState();
}

class _QuestionActionsChipState extends State<QuestionActionsChip> {
  final GlobalKey<PopupMenuButtonState> _popupMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final treeController = QuestionsTreeController.of(context);
    final nodeScope = TreeNodeScope.of(context);

    return PopupMenuButton<int>(
      key: _popupMenuKey,
      tooltip: 'Показать действия',
      offset: const Offset(0, 32),
      color: Colors.blueGrey.shade100,
      shape: kRoundedRectangleBorder,
      elevation: 6,
      itemBuilder: (_) => questionsPopupMenuItems,
      onSelected: (int selected) {
        if (selected == 0) {
          showAddFileDialog(context, nodeScope.node);
        }
        if (selected == 1) {
          showAddQuestionDialog(context, nodeScope.node, treeController);
        }
        if (selected == 2) {
          // edit
          Provider.of<AppState>(context, listen: false)
              .navigateToPage('/agendaItem',
                  args: <BaseItem>{
                    treeController.getAgenda(),
                    (nodeScope.node.data ?? Question()) as Question,
                  }.toList());
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
    final treeController = QuestionsTreeController.of(context).treeController;
    final treeNode = TreeNodeScope.of(context).node;
    final parent = treeNode.parent ?? treeController.rootNode;

    treeNode.delete(recursive: deleteSubtree);

    treeController.refreshNode(parent, keepExpandedNodes: true);
  }
}

const questionsPopupMenuItems = <PopupMenuEntry<int>>[
  PopupMenuItem(
    value: 0,
    child: ListTile(
      dense: true,
      title: Text('Добавить файл'),
      subtitle: Text('Добавить файл'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.account_box),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 1,
    child: ListTile(
      dense: true,
      title: Text('Добавить вопрос'),
      subtitle: Text('Добавить дочерний вопрос'),
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
      subtitle: Text('Открыть редактор вопроса'),
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
      subtitle: Text('Сместить вопрос вправо'),
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
      subtitle: Text('Сместить вопрос влево'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.arrow_left),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 5,
    child: ListTile(
      dense: true,
      title: Text('Удалить вопрос'),
      subtitle: Text('Удалить вопрос включая дочерние элементы'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_forever_rounded),
    ),
  ),
];
