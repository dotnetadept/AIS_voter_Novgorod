import 'package:ais_agenda/Model/subject/group.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Widgets/treeview/common/utility/unfocus.dart';
import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_controller.dart';
import 'package:ais_agenda/View/Widgets/treeview/groups_treeview/group_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final GroupsTreeController treeController = GroupsTreeController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupAppControllerScope(
      controller: treeController,
      child: Shell(
        title: const Text('Группы'),
        actions: <Widget>[
          Tooltip(
            message: "Добавить",
            child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const CircleBorder(
                      side: BorderSide(color: Colors.transparent)),
                ),
              ),
              onPressed: () {
                _navigateGroupPage(Group());
              },
              child: const Icon(Icons.add),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
        body: FutureBuilder<void>(
          future: treeController.init(),
          builder: (_, __) {
            if (treeController.isInitialized) {
              return const Unfocus(
                child: GroupTreeView(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _navigateGroupPage(Group group) {
    Provider.of<AppState>(context, listen: false)
        .navigateToPage('/group', args: group);
  }
}
