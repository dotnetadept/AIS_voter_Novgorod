import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/ais_model.dart';

class Proxy extends ManagedObject<_Proxy> implements _Proxy {
  List<ProxyUser> getVotingSubjects() {
    return subjects.where((element) => element.user.isVoter).toList();
  }
}

class _Proxy {
  @primaryKey
  int id;
  ManagedSet<ProxyUser> subjects;
  bool isActive;
  DateTime createdDate;
  DateTime lastUpdated;

  @Relate(#proxys)
  User proxy;
}
