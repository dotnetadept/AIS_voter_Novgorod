class GuestPlace {
  String name = '';
  String terminalId = '';

  GuestPlace({this.name, this.terminalId});

  Map toJson() => {'name': name, 'terminalId': terminalId};

  GuestPlace.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        terminalId = json['terminalId'];
}
