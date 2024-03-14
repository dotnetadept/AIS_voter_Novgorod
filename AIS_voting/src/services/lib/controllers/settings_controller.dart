import 'package:aqueduct/aqueduct.dart';
import '../models/settings.dart';

class SettingsController extends ResourceController {
  SettingsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getSettings() async {
    final query = Query<Settings>(context);

    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addSettings(@Bind.body() Settings settings) async {
    final query = Query<Settings>(context)
      ..values.name = settings.name
      ..values.isSelected = settings.isSelected
      ..values.createdDate = settings.createdDate
      ..values.palletteSettings = settings.palletteSettings
      ..values.operatorSchemeSettings = settings.operatorSchemeSettings
      ..values.managerSchemeSettings = settings.managerSchemeSettings
      ..values.tableViewSettings = settings.tableViewSettings
      ..values.deputySettings = settings.deputySettings
      ..values.votingSettings = settings.votingSettings
      ..values.reportSettings = settings.reportSettings
      ..values.questionListSettings = settings.questionListSettings
      ..values.fileSettings = settings.fileSettings
      ..values.storeboardSettings = settings.storeboardSettings
      ..values.signalsSettings = settings.signalsSettings
      ..values.intervalsSettings = settings.intervalsSettings
      ..values.licenseSettings = settings.licenseSettings;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateSettings(
      @Bind.path('id') int id, @Bind.body() Settings settings) async {
    var query = Query<Settings>(context)
      ..values.name = settings.name
      ..values.isSelected = settings.isSelected
      ..values.createdDate = settings.createdDate
      ..values.palletteSettings = settings.palletteSettings
      ..values.operatorSchemeSettings = settings.operatorSchemeSettings
      ..values.managerSchemeSettings = settings.managerSchemeSettings
      ..values.tableViewSettings = settings.tableViewSettings
      ..values.deputySettings = settings.deputySettings
      ..values.votingSettings = settings.votingSettings
      ..values.reportSettings = settings.reportSettings
      ..values.questionListSettings = settings.questionListSettings
      ..values.fileSettings = settings.fileSettings
      ..values.storeboardSettings = settings.storeboardSettings
      ..values.signalsSettings = settings.signalsSettings
      ..values.intervalsSettings = settings.intervalsSettings
      ..values.licenseSettings = settings.licenseSettings
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteSettings(@Bind.path('id') int id) async {
    var query = Query<Settings>(context)..where((t) => t.id).equalTo(id);

    var userTemplate = await query.delete();

    return Response.ok(userTemplate);
  }
}
