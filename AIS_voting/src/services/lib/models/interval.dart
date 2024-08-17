import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/signal.dart';

class Interval extends ManagedObject<_Interval> implements _Interval {}

class _Interval {
  @primaryKey
  late int id;
  late int orderNum;
  late String name;
  late int duration;
  @Relate(#startSignalInterval)
  Signal? startSignal;
  @Relate(#endSignalInterval)
  Signal? endSignal;
  late bool isActive;
  late bool isAutoEnd;
}
