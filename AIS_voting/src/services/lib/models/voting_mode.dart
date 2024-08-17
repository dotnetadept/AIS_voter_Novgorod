import 'package:conduit_core/conduit_core.dart';

class VotingMode extends ManagedObject<_VotingMode> implements _VotingMode {}

class _VotingMode {
  @primaryKey
  late int id;
  late String name;
  late String defaultDecision;
  late int orderNum;
  late String includedDecisions;
}
