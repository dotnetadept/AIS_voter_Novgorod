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

  @Operation.put()
  Future<Response> updateSettings(@Bind.body() Settings settings) async {
    var query = Query<Settings>(context)
      ..values.palletteSettings = settings.palletteSettings
      ..values.operatorSchemeSettings = settings.operatorSchemeSettings
      ..values.managerSchemeSettings = settings.managerSchemeSettings
      ..values.votingSettings = settings.votingSettings
      ..values.storeboardSettings = settings.storeboardSettings
      ..values.soundSettings = settings.soundSettings
      ..values.licenseSettings = settings.licenseSettings
      ..where((u) => u.id).isNotNull();

    return Response.ok(await query.update());
  }
}
