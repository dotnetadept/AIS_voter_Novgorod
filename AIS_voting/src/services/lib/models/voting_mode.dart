import 'package:aqueduct/aqueduct.dart';

class VotingMode extends ManagedObject<_VotingMode> implements _VotingMode {}

class _VotingMode {
  @primaryKey
  int id;
  String name;
  String defaultDecision;
  int orderNum;
  String includedDecisions;
}
