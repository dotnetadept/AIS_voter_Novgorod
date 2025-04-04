class SystemLog {
  late int id;
  late String type;
  late String message;
  late DateTime time;

  SystemLog();

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
