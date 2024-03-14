class Signal {
  int id;
  int orderNum;
  String name = '';
  int duration = 10;
  String soundPath = '';
  double volume = 100;
  int color = 0x00000000;

  Signal(
      {this.id,
      this.orderNum,
      this.name,
      this.duration,
      this.soundPath,
      this.volume,
      this.color});

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
        soundPath = json['soundPath'],
        volume = json['volume'],
        color = json['color'];
}
