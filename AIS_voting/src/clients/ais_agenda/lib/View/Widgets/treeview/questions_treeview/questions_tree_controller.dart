import 'package:ais_agenda/Model/agenda/agenda.dart';
import 'package:ais_agenda/Model/agenda/file.dart';
import 'package:ais_agenda/Model/agenda/question.dart';

import 'package:flutter/widgets.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:uuid/uuid.dart';

const String kRootId = '';

class QuestionsTreeController with ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static QuestionsTreeController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<QuestionsAppControllerScope>()!
        .controller;
  }

  Future<void> init(Agenda agenda) async {
    if (_isInitialized) {
      return;
    }
    _agenda = agenda;
    final rootNode = TreeNode(id: kRootId);

    generateQuestionsTree(rootNode, _agenda.questions);

    treeController = TreeViewController(
      rootNode: rootNode,
    );

    treeController.expandAll();

    _isInitialized = true;
  }

  //* == == == == == TreeView == == == == ==

  late Agenda _agenda;

  Agenda getAgenda() {
    return _agenda;
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

class QuestionsAppControllerScope extends InheritedWidget {
  const QuestionsAppControllerScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final QuestionsTreeController controller;

  @override
  bool updateShouldNotify(QuestionsAppControllerScope oldWidget) => false;
}

void generateQuestionsTree(TreeNode parent, List<Question> questions) {
  var childQuestions =
      questions.where((element) => element.parentId == parent.id).toList();
  parent.addChildren(
    childQuestions.map((Question child) {
      return TreeNode(id: child.id, label: child.toString(), data: child);
    }),
  );

  var nodeData = parent.data;

  if (nodeData is Question) {
    var childFiles = nodeData.files.toList();
    parent.addChildren(
      childFiles.map((AisFile file) {
        return TreeNode(
            id: const Uuid().v4(), label: file.toString(), data: file);
      }),
    );
  }

  for (var childNode in parent.children) {
    generateQuestionsTree(childNode, questions);
  }
}
