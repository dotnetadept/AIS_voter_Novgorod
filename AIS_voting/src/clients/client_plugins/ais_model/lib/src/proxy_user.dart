import 'user.dart';

class ProxyUser {
  late int id;
  late int proxyId;
  late User user;

  ProxyUser({
    required this.proxyId,
    required this.user,
  });

  Map toJson() => {
        'id': id,
        'proxy': {'id': proxyId},
        'user': user.toJson()
      };

  ProxyUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        proxyId = json['proxy']['id'],
        user = User.fromJson(json['user']);
}
