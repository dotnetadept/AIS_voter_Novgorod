class SystemLog {
  int id;
  String type;
  String message;
  DateTime time;

  SystemLog({
    this.id,
    this.type,
    this.message,
    this.time,
  });

  Map toJson() => {
        'id': id,
        'type': type,
        'message': message,
        'time': time?.toIso8601String(),
      };

  SystemLog.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        message = json['message'],
        time = DateTime.parse(json['time']);
}
