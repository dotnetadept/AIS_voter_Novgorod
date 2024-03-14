import 'package:ais_agenda/Model/base/base_item.dart';

class AisFormType extends BaseItem {
  String name = '';

  AisFormType();

  Map toJson() => {
        'id': id,
        'name': name,
      };

  AisFormType.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        super.fromJson(json);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return name;
  }
}
