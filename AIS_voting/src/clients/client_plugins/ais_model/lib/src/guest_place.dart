class GuestPlace {
  late String name = '';
  late String terminalId = '';

  GuestPlace({
    required this.name,
    required this.terminalId,
  });

  Map toJson() => {'name': name, 'terminalId': terminalId};

  GuestPlace.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        terminalId = json['terminalId'];
}
