import 'package:ais_model/src/proxy_user.dart';

import 'user.dart';
import 'proxy_user.dart';

class Proxy {
  int id;
  User proxy;
  List<ProxyUser> subjects;
  bool isActive;
  DateTime createdDate;
  DateTime lastUpdated;

  Proxy(
      {this.id,
      this.proxy,
      this.subjects,
      this.isActive,
      this.createdDate,
      this.lastUpdated});

  Map toJson() => {
        'id': id,
        'proxy': proxy == null ? null : proxy.toJson(),
        'subjects': subjects,
        'isActive': isActive,
        'createdDate':
            lastUpdated == null ? null : createdDate.toIso8601String(),
        'lastUpdated':
            lastUpdated == null ? null : lastUpdated.toIso8601String(),
      };

  Proxy.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        isActive = json['isActive'],
        proxy = json['proxy'] == null ? null : User.fromJson(json['proxy']),
        createdDate = json['createdDate'] == null
            ? null
            : DateTime.parse(json['createdDate']),
        lastUpdated = json['lastUpdated'] == null
            ? null
            : DateTime.parse(json['lastUpdated']),
        subjects = json['subjects'] == null
            ? <ProxyUser>[]
            : json['subjects']
                .map<ProxyUser>((u) => ProxyUser.fromJson(u))
                .toList();

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return '${proxy.toString()}';
  }
}