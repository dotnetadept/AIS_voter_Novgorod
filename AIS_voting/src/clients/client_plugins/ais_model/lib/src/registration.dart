class Registration {
  late int id;
  late int userId;
  late int proxyId;
  late int registrationSessionId;

  Registration({
    required this.id,
    required this.userId,
    required this.registrationSessionId,
  });

  Registration.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        registrationSessionId = json['registrationSession']['id'];
}
