import 'subject.dart';
import 'user.dart';

class Group extends Subject {
  String parentId = '';
  String name = '';

  List<User> users = <User>[];

  Group();

  Map toJson() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'users': users,
      };

  Group.fromJson(Map<String, dynamic> json)
      : users = json['users'] == null
            ? <User>[]
            : json['users'].map<User>((i) {
                return User.fromJson(i);
              }).toList(),
        parentId = json['parentId'],
        name = json['name'],
        super.fromJson(json);

  @override
  String toString() {
    return name;
  }
}
