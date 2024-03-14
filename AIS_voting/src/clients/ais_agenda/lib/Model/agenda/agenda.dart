import 'package:ais_agenda/Model/agenda/question.dart';
import 'package:ais_agenda/Model/entity/aisform.dart';

import '../entity/restricted_item.dart';

class Agenda extends RestrictedItem {
  String name = '';
  AisForm template = AisForm();
  List<Question> questions = <Question>[];

  Agenda();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'name': name,
        'template': template,
        'questions': questions,
      };

  Agenda.fromJson(Map<String, dynamic> json)
      : questions = json['questions']
            .map<Question>((i) => Question.fromJson(i))
            .toList(),
        template = json['tepmplate'] == null
            ? AisForm()
            : AisForm.fromJson(json['tepmplate']),
        name = json['name'],
        super.fromJson(json);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return name;
  }
}
