import 'package:ais_agenda/Model/subject/group.dart';
import 'package:ais_agenda/Model/subject/subject.dart';
import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:uuid/uuid.dart';

const String kRootId = '';

class GroupsTreeController with ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static GroupsTreeController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupAppControllerScope>()!
        .controller;
  }

  Future<void> init({bool isSelectMode = false}) async {
    if (_isInitialized) {
      return;
    }
    _isSelectMode = isSelectMode;

    final rootNode = TreeNode(id: kRootId);

    var groups = AppState().getGroups();

    if (isSelectMode) {
      var allUsers = Group();
      allUsers.id = const Uuid().v4();
      allUsers.name = 'Все пользователи';
      allUsers.users.addAll(AppState().getUsers());

      groups.add(allUsers);
    }
    generateGroupsTree(rootNode, groups);

    treeController = TreeViewController(
      rootNode: rootNode,
    );

    treeController.expandAll();

    _isInitialized = true;
  }

  //* == == == == == TreeView == == == == ==

  late bool _isSelectMode;

  bool getIsSelectMode() {
    return _isSelectMode;
  }

  void setIsSelectMode(bool mode) {
    _isSelectMode = mode;
  }

  late Subject _selectedNode;

  Subject getSelectedNode() {
    return _selectedNode;
  }

  void setSelectedNode(Subject node) {
    _selectedNode = node;
  }

  TreeNode get rootNode => treeController.rootNode;

  late final TreeViewController treeController;

  //* == == == == == Scroll == == == == ==

  late final scrollController = ScrollController();

  //* == == == == == General == == == == ==

  final treeViewTheme = ValueNotifier(const TreeViewTheme());

  void updateTheme(TreeViewTheme theme) {
    treeViewTheme.value = theme;
  }

  @override
  void dispose() {
    treeController.dispose();

    scrollController.dispose();
    treeViewTheme.dispose();
    super.dispose();
  }
}

class GroupAppControllerScope extends InheritedWidget {
  const GroupAppControllerScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final GroupsTreeController controller;

  @override
  bool updateShouldNotify(GroupAppControllerScope oldWidget) => false;
}

void generateGroupsTree(TreeNode parent, List<Group> groups) {
  var childGroups =
      groups.where((element) => element.parentId == parent.id).toList();
  parent.addChildren(
    childGroups.map((Group child) {
      return TreeNode(id: child.id, label: child.toString(), data: child);
    }),
  );

  var nodeData = parent.data;

  if (nodeData is Group) {
    var childUsers = AppState()
        .getUsers()
        .where((user) => nodeData.users.any((element) => element.id == user.id))
        .toList();
    parent.addChildren(
      childUsers.map((User user) {
        return TreeNode(
            id: const Uuid().v4(), label: user.toString(), data: user);
      }),
    );
  }

  for (var childNode in parent.children) {
    generateGroupsTree(childNode, groups);
  }
}
