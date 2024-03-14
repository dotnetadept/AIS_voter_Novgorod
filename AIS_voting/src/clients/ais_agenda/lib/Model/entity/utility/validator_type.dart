import '../../base/base_item.dart';

class ValidatorType extends BaseItem {
  String name = '';
  String regex = '';

  ValidatorType();

  Map toJson() => {'id': id, 'name': name, 'regex': regex};

  ValidatorType.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        regex = json['regex'],
        super.fromJson(json);
}
