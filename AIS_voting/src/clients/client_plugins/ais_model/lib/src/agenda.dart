import 'question.dart';

class Agenda {
  late int id;
  late String name;
  late String folder;
  late DateTime createdDate;
  late DateTime lastUpdated;
  late List<Question> questions;

  Agenda({
    required this.id,
    required this.name,
    required this.createdDate,
    required this.lastUpdated,
    required this.questions,
    required this.folder,
  });

  Map toJson() => {
        'id': id,
        'name': name,
        'folder': folder,
        'createdDate': createdDate.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'questions': questions,
      };

  Agenda.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        folder = json['folder'],
        createdDate = DateTime.parse(json['createdDate']),
        lastUpdated = DateTime.parse(json['lastUpdated']),
        questions = json['questions'] == null
            ? <Question>[]
            : json['questions']
                .map<Question>((q) => Question.fromJson(q))
                .toList();

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '$name';
  }
}
