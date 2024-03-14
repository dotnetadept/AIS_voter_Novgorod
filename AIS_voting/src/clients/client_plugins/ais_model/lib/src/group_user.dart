import 'user.dart';

class GroupUser {
  int id;
  int groupId;
  User user;
  bool isManager;

  GroupUser({this.groupId, this.user, this.isManager});

  Map toJson() => {
        'id': id,
        'group': {'id': groupId},
        'user': user.toJson(),
        'isManager': isManager
      };

  GroupUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        groupId = json['group']['id'],
        user = User.fromJson(json['user']),
        isManager = json['isManager'];
}
