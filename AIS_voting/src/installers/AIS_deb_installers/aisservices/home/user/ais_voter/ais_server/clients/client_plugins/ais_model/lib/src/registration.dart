class Registration {
  int id;
  int userId;
  int registrationSessionId;

  Registration({this.id, this.userId, this.registrationSessionId});

  Registration.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        registrationSessionId = json['registrationSession']['id'];
}
