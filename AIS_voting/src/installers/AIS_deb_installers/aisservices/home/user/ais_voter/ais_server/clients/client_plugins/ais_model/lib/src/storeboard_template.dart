import 'storeboard_template_item.dart';
import 'dart:convert';

class StoreboardTemplate {
  int id;
  String name = '';
  List<StoreboardTemplateItem> items = <StoreboardTemplateItem>[];

  StoreboardTemplate() {}

  Map toJson() =>
      {'id': id, 'name': name, 'items': jsonEncode(items).toString()};

  StoreboardTemplate.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        items = json['items'] == null
            ? <StoreboardTemplateItem>[]
            : jsonDecode(json['items'])
                .map<StoreboardTemplateItem>(
                    (i) => StoreboardTemplateItem.fromJson(i))
                .toList();
}
