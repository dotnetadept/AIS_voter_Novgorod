import 'subject.dart';

class User extends Subject {
  String login = '';
  String password = '';
  String firstName = '';
  String secondName = '';
  String lastName = '';

  User();

  Map toJson() => {
        'id': id,
        'login': login,
        'password': password,
        'firstName': firstName,
        'secondName': secondName,
        'lastName': lastName,
      };

  User.fromJson(Map<String, dynamic> json)
      : login = json['login'],
        password = json['password'],
        firstName = json['firstName'],
        secondName = json['secondName'],
        lastName = json['lastName'],
        super.fromJson(json);

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  String getShortName() {
    var shortPart = '';

    if (firstName.isNotEmpty) {
      shortPart += '${firstName[0]}.';
    }

    if (lastName.isNotEmpty) {
      shortPart += '${lastName[0]}.';
    }

    return '$secondName $shortPart';
  }

  @override
  String toString() {
    return getShortName();
  }
}
