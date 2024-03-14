import 'question.dart';

class Agenda {
  int id;
  String name;
  String folder;
  DateTime createdDate;
  DateTime lastUpdated;
  List<Question> questions;

  Agenda(
      {this.id,
      this.name,
      this.createdDate,
      this.lastUpdated,
      this.questions,
      this.folder});

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
