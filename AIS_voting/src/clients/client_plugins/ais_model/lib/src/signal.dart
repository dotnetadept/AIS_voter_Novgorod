class Signal {
  late int id;
  late int orderNum;
  late String name = '';
  late int duration = 10;
  late String soundPath = '';
  late double volume = 100;
  late int color = 0x00000000;

  Signal({
    required this.id,
    required this.orderNum,
    required this.name,
    required this.duration,
    required this.soundPath,
    required this.volume,
    required this.color,
  });

  Map toJson() => {
        'id': id,
        'orderNum': orderNum,
        'name': name,
        'duration': duration,
        'soundPath': soundPath,
        'volume': volume,
        'color': color
      };

  Signal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        orderNum = json['orderNum'],
        duration = json['duration'],
        soundPath = json['soundPath'] ?? '',
        volume = json['volume'] ?? 0,
        color = json['color'];
}
