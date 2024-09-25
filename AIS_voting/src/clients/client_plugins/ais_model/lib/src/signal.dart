class Signal {
  int? id;
  int orderNum;
  String name;
  int duration;
  String soundPath;
  double volume;
  int color;

  Signal({
    this.id,
    this.orderNum = 0,
    this.name = '',
    this.duration = 10,
    this.soundPath = '',
    this.volume = 100,
    this.color = 0x00000000,
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
