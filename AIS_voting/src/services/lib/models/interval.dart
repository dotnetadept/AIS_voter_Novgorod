import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/signal.dart';

class Interval extends ManagedObject<_Interval> implements _Interval {}

class _Interval {
  @primaryKey
  int id;
  int orderNum;
  String name;
  int duration;
  @Relate(#startSignalInterval)
  Signal startSignal;
  @Relate(#endSignalInterval)
  Signal endSignal;
  bool isActive;
  bool isAutoEnd;
}
