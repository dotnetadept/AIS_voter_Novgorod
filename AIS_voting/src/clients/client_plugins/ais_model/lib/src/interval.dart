import '../ais_model.dart';

class Interval {
  int id;
  int orderNum;
  String name = '';
  int duration = 0;
  Signal startSignal;
  Signal endSignal;
  bool isAutoEnd = false;
  bool isActive = true;

  Interval() {
    name = '';
    duration = 0;
    isActive = true;
    isAutoEnd = false;
  }

  Map toJson() => {
        'id': id,
        'orderNum': orderNum,
        'name': name,
        'duration': duration,
        'startSignal': startSignal?.toJson(),
        'endSignal': endSignal?.toJson(),
        'isActive': isActive,
        'isAutoEnd': isAutoEnd,
      };

  Interval.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        orderNum = json['orderNum'],
        duration = json['duration'],
        endSignal = json['endSignal'] == null
            ? null
            : Signal.fromJson(json['endSignal']),
        startSignal = json['startSignal'] == null
            ? null
            : Signal.fromJson(json['startSignal']),
        isActive = json['isActive'],
        isAutoEnd = json['isAutoEnd'];
}
