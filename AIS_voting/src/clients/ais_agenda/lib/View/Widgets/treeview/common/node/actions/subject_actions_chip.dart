part of '../tree_node_tile.dart';

class SubjectActionsChip extends StatefulWidget {
  const SubjectActionsChip({Key? key}) : super(key: key);

  @override
  State<SubjectActionsChip> createState() => _SubjectActionsChipState();
}

class _SubjectActionsChipState extends State<SubjectActionsChip> {
  @override
  Widget build(BuildContext context) {
    final appController = GroupsTreeController.of(context);
    final nodeScope = TreeNodeScope.of(context);

    return Tooltip(
      message: "Выбрать",
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        onPressed: () {
          appController.setSelectedNode(nodeScope.node.data as Subject);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
