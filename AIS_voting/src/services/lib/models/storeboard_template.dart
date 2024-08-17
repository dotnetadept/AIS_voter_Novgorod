import 'package:conduit_core/conduit_core.dart';

class StoreboardTemplate extends ManagedObject<_StoreboardTemplate>
    implements _StoreboardTemplate {}

class _StoreboardTemplate {
  @primaryKey
  late int id;
  late String name;
  late String items;
}
