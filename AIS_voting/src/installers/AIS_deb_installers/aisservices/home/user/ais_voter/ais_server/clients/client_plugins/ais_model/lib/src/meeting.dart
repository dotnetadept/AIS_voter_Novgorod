import 'agenda.dart';
import 'group.dart';

class Meeting {
  int id;
  String name;
  String description;
  String status;
  DateTime lastUpdated;
  Agenda agenda;
  Group group;

  Meeting(
      {this.id,
      this.name,
      this.description,
      this.status,
      this.agenda,
      this.group,
      this.lastUpdated});

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'agenda': agenda == null ? null : agenda.toJson(),
        'group': group == null ? null : group.toJson(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  Meeting.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        status = json['status'],
        agenda =
            json['agenda'] == null ? null : Agenda.fromJson(json['agenda']),
        group = json['group'] == null ? null : Group.fromJson(json['group']),
        lastUpdated = DateTime.parse(json['lastUpdated']);

  bool contains(String search) {
    return toJson()
        .toString()
        .toUpperCase()
        .contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '$name';
  }
}
