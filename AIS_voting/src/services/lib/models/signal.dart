import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/interval.dart';

class Signal extends ManagedObject<_Signal> implements _Signal {}

class _Signal {
  @primaryKey
  int id;
  int orderNum;
  String name;
  int duration;
  String soundPath;
  double volume;
  int color;

  Interval startSignalInterval;
  Interval endSignalInterval;
}
