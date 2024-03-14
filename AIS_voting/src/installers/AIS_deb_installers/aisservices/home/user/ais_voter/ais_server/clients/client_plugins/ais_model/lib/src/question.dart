import 'question_file.dart';
import 'question_description_item.dart';
import 'dart:convert';
import 'settings.dart';

class Question {
  int id;
  String name;
  String folder;
  int orderNum;
  List<QuestionDescriptionItem> descriptions;
  List<QuestionFile> files;
  int agendaId;

  Question(
      {this.id,
      this.name,
      this.orderNum,
      this.descriptions,
      this.files,
      this.folder,
      this.agendaId});

  Map toJson() => {
        'id': id,
        'name': name,
        'folder': folder,
        'orderNum': orderNum,
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
  String toString({Settings settings}) {
    if (settings == null) {
      return '$name $orderNum';
    }
    if (orderNum == 0) {
      if (!settings.votingSettings.isFirstQuestionUseNumber) {
        return '$name';
      }
    }

    return '$name ${settings.votingSettings.defaultQuestionNumberPrefix}$orderNum';
  }
}
