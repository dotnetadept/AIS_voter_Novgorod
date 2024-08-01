import 'user.dart';

class GroupUser {
  late int id;
  late int groupId;
  late User user;
  late bool isManager;

  GroupUser({
    required this.groupId,
    required this.user,
    required this.isManager,
  });

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
