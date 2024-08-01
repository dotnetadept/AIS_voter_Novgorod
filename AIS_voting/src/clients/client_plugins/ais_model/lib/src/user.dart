class User {
  late int id;
  late String firstName;
  late String secondName;
  late String lastName;
  late String login;
  late String password;
  late String cardId;
  late DateTime? lastSession;
  late bool isVoter;

  User() {
    id = 0;
    firstName = '';
    secondName = '';
    lastName = '';
    login = '';
    password = '';
    cardId = '';
    lastSession = null;
    isVoter = false;
  }

  Map toJson() => {
        'id': id,
        'firstName': firstName,
        'secondName': secondName,
        'lastName': lastName,
        'login': login,
        'password': password,
        'cardId': cardId,
        'lastSession': lastSession,
        'isVoter': isVoter
      };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        secondName = json['secondName'],
        lastName = json['lastName'],
        login = json['login'],
        password = json['password'],
        cardId = json['cardId'],
        lastSession = json['lastSession'] == null
            ? null
            : DateTime.parse(json['lastSession']),
        isVoter = json['isVoter'];

  bool contains(String search) {
    return toJson().toString().toUpperCase().contains(search.toUpperCase());
  }

  @override
  String toString() {
    return getFullName();
  }

  String getFullName() {
    return '$secondName $firstName $lastName';
  }

  String getShortName({bool isInverted = false}) {
    var shortPart = '';

    if (firstName.isNotEmpty) {
      shortPart += firstName[0].toString() + '.';
    }

    if (lastName.isNotEmpty) {
      shortPart += lastName[0].toString() + '.';
    }

    return isInverted ? '$shortPart $secondName' : '$secondName $shortPart';
  }
}
