import 'agenda.dart';
import 'group.dart';

class Meeting {
  late int id;
  late String name;
  late String description;
  late String status;
  late DateTime lastUpdated;
  late Agenda? agenda;
  late Group? group;

  Meeting({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.agenda,
    required this.group,
    required this.lastUpdated,
  });

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'agenda': agenda == null ? null : agenda?.toJson(),
        'group': group == null ? null : group?.toJson(),
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
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '$name';
  }
}
