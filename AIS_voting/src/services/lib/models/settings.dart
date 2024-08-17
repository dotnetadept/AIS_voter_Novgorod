import 'package:conduit_core/conduit_core.dart';

class Settings extends ManagedObject<_Settings> implements _Settings {}

class _Settings {
  @primaryKey
  late int id;
  late String name;
  late DateTime createdDate;
  late bool isSelected;
  @Column(nullable: true)
  String? palletteSettings;
  @Column(nullable: true)
  String? operatorSchemeSettings;
  @Column(nullable: true)
  String? managerSchemeSettings;
  @Column(nullable: true)
  String? tableViewSettings;
  @Column(nullable: true)
  String? deputySettings;
  @Column(nullable: true)
  String? votingSettings;
  @Column(nullable: true)
  String? reportSettings;
  @Column(nullable: true)
  String? questionListSettings;
  @Column(nullable: true)
  String? fileSettings;
  @Column(nullable: true)
  String? storeboardSettings;
  @Column(nullable: true)
  String? signalsSettings;
  @Column(nullable: true)
  String? intervalsSettings;
  @Column(nullable: true)
  String? licenseSettings;
}
