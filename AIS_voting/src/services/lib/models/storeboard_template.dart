import 'package:aqueduct/aqueduct.dart';

class StoreboardTemplate extends ManagedObject<_StoreboardTemplate>
    implements _StoreboardTemplate {}

class _StoreboardTemplate {
  @primaryKey
  int id;
  String name;
  String items;
}
