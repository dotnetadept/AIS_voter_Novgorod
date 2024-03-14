import 'question_file.dart';
import 'question_description_item.dart';
import 'dart:convert';
import 'settings.dart';

class Question {
  int id;
  String name;
  String folder;
  int orderNum;
  List<int> accessRights;
  List<QuestionDescriptionItem> descriptions;
  List<QuestionFile> files;

  int agendaId;

  Question(
      {this.id,
      this.name,
      this.orderNum,
      this.accessRights,
      this.descriptions,
      this.files,
      this.folder,
      this.agendaId});

  Map toJson() => {
        'id': id,
        'name': name,
        'folder': folder,
        'orderNum': orderNum,
        'accessRights': jsonEncode(accessRights),
        'description': '\'' + jsonEncode(descriptions).toString() + '\'',
        'files': files,
        'agenda': {'id': agendaId},
      };

  Question.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        agendaId = json['agenda']['id'],
        name = json['name'],
        folder = json['folder'],
        orderNum = json['orderNum'],
        accessRights = json['accessRights'] == null ||
                !jsonDecode(json['accessRights']).any((e) => e != null)
            ? <int>[]
            : jsonDecode(json['accessRights'])
                .map<int>((e) => int.parse(e.toString()))
                .toList(),
        descriptions = jsonDecode(json['description']
                .substring(1, json['description'].length - 1))
            .map<QuestionDescriptionItem>(
                (di) => QuestionDescriptionItem.fromJson(di))
            .toList(),
        files = json['files'] == null
            ? <QuestionFile>[]
            : json['files']
                .map<QuestionFile>((f) => QuestionFile.fromJson(f))
                .toList();
  @override
  String toString() {
    return '$name';
  }

  String getReportDescription() {
    var joinedDescription = '';
    for (var desc in descriptions) {
      var descItem = desc.showInReports ? desc.toString() : '';

      joinedDescription += descItem == '' ? descItem : descItem + '\r\n';
    }

    return joinedDescription.trim();
  }
}

class QuestionListUtil {
  static void insert(Settings settings, List<Question> _questions,
      Question newQuestion, int index) {
    QuestionGroupSettings groupSettings =
        getQuestionGroup(settings, newQuestion);

    if (groupSettings == null) {
      _questions.insert(index, newQuestion);
      for (int i = index + 1; i < _questions.length; i++) {
        _questions[i].orderNum = i;
      }

      return;
    }

    var questionNames = _questions.map((e) => e.toString()).toList();

    var groupNumbers = List<int>();
    for (int i = 0; i < _questions.length; i++) {
      var itemOderInGroup = questionNames[i]
          .replaceFirst(groupSettings.defaultGroupName, '')
          .trim();

      groupNumbers.add(int.tryParse(itemOderInGroup));
    }

    var prevElement = groupNumbers.getRange(0, index).lastWhere(
          (element) => element != null,
          orElse: () => null,
        );

    var nextElement =
        groupNumbers.getRange(index, groupNumbers.length).firstWhere(
              (element) => element != null,
              orElse: () => null,
            );

    int orderNum = nextElement;

    if (orderNum == null && prevElement != null) {
      orderNum = prevElement + 1;
    }
    if (orderNum == null) {
      orderNum = 1;
    }

    if (groupSettings.isUseNumber) {
      if (groupSettings.showNumberBeforeName) {
        newQuestion.name = '$orderNum ${groupSettings.defaultGroupName}';
      } else {
        newQuestion.name = '${groupSettings.defaultGroupName} $orderNum';
      }
    }

    _questions.insert(index, newQuestion);
    groupNumbers.insert(index, orderNum);

    for (int i = index + 1; i < _questions.length; i++) {
      _questions[i].orderNum = i;
      if (groupNumbers[i] != null) {
        _questions[i].name = _questions[i].name.replaceAll(
            groupNumbers[i].toString(), (groupNumbers[i] + 1).toString());
      }
    }
  }

  static QuestionGroupSettings getQuestionGroup(
      Settings settings, Question question) {
    QuestionGroupSettings groupSettings = null;

    if (settings != null) {
      if (question.toString() ==
              settings.questionListSettings.firstQuestion.defaultGroupName ||
          int.tryParse(question
                  .toString()
                  .replaceFirst(
                      settings
                          .questionListSettings.firstQuestion.defaultGroupName,
                      '')
                  .trim()) !=
              null) {
        groupSettings = settings.questionListSettings.firstQuestion;
      }
      if (question.toString() ==
              settings.questionListSettings.mainQuestion.defaultGroupName ||
          int.tryParse(question
                  .toString()
                  .replaceFirst(
                      settings
                          .questionListSettings.mainQuestion.defaultGroupName,
                      '')
                  .trim()) !=
              null) {
        groupSettings = settings.questionListSettings.mainQuestion;
      }
      if (question.toString() ==
              settings
                  .questionListSettings.additionalQiestion.defaultGroupName ||
          int.tryParse(question
                  .toString()
                  .replaceFirst(
                      settings.questionListSettings.additionalQiestion
                          .defaultGroupName,
                      '')
                  .trim()) !=
              null) {
        groupSettings = settings.questionListSettings.additionalQiestion;
      }
    }

    return groupSettings;
  }

  static void removeQuestionAndUpdate(
      Settings _settings, List<Question> _questions, Question question) {
    int indexOfQuestion = _questions.indexOf(question);
    _questions.remove(question);

    var type = getQuestionGroup(_settings, question);

    for (int i = indexOfQuestion; i < _questions.length; i++) {
      _questions[i].orderNum = i;

      if (type != null && getQuestionGroup(_settings, _questions[i]) == type) {
        var number = int.tryParse(
            _questions[i].name.replaceAll(type.defaultGroupName, '').trim());

        if (number != null) {
          _questions[i].name = _questions[i]
              .name
              .replaceFirst(number.toString(), (number - 1).toString());
        }
      }
    }
  }

  static void removeQuestion(List<Question> _questions, Question question) {
    int indexOfQuestion = _questions.indexOf(question);
    _questions.remove(question);

    for (int i = indexOfQuestion; i < _questions.length; i++) {
      _questions[i].orderNum = i;
    }
  }
}
