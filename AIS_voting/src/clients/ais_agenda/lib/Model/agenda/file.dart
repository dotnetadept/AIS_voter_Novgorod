import 'agenda_item.dart';

class AisFile extends AgendaItem {
  String comment = '';
  String path = '';

  AisFile();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'parentId': parentId,
        'name': name,
        'comment': comment,
      };

  AisFile.fromJson(Map<String, dynamic> json)
      : comment = json['comment'],
        super.fromJson(json);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return name;
  }
}
