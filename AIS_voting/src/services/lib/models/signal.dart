import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/interval.dart';

class Signal extends ManagedObject<_Signal> implements _Signal {}

class _Signal {
  @primaryKey
  late int id;
  late int orderNum;
  late String name;
  late int duration;
  late String soundPath;
  late double volume;
  late int color;

  late Interval startSignalInterval;
  late Interval endSignalInterval;
}
