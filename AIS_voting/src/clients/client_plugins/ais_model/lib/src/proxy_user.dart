import 'user.dart';

class ProxyUser {
  int id;
  int proxyId;
  User user;

  ProxyUser({this.proxyId, this.user});

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
