part of '../tree_node_tile.dart';

class _NodeTitle extends StatelessWidget {
  const _NodeTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      final appController = GroupsTreeController.of(context);
      final nodeScope = TreeNodeScope.of(context);

      return AnimatedBuilder(
          animation: appController,
          builder: (_, __) {
            return Text(
              nodeScope.node.label,
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            );
          });
    } catch (e) {
      final appController = QuestionsTreeController.of(context);
      final nodeScope = TreeNodeScope.of(context);

      return AnimatedBuilder(
          animation: appController,
          builder: (_, __) {
            return Text(
              nodeScope.node.label,
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            );
          });
    }
  }
}
