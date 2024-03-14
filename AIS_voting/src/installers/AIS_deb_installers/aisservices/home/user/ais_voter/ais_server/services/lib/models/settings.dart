import 'package:aqueduct/aqueduct.dart';

class Settings extends ManagedObject<_Settings> implements _Settings {}

class _Settings {
  @primaryKey
  int id;
  @Column(nullable: true)
  String palletteSettings;
  @Column(nullable: true)
  String operatorSchemeSettings;
  @Column(nullable: true)
  String managerSchemeSettings;
  @Column(nullable: true)
  String votingSettings;
  @Column(nullable: true)
  String storeboardSettings;
  @Column(nullable: true)
  String soundSettings;
  @Column(nullable: true)
  String licenseSettings;
}
