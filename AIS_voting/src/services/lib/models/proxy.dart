import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/ais_model.dart';

class Proxy extends ManagedObject<_Proxy> implements _Proxy {
  List<ProxyUser> getVotingSubjects() {
    return subjects.where((element) => element.user.isVoter).toList();
  }
}

class _Proxy {
  @primaryKey
  late int id;
  late ManagedSet<ProxyUser> subjects;
  late bool isActive;
  late DateTime createdDate;
  late DateTime lastUpdated;

  @Relate(#proxys)
  User? proxy;
}
