import 'package:aqueduct/aqueduct.dart';
import '../models/storeboard_template.dart';

class StoreboardTemplateController extends ResourceController {
  StoreboardTemplateController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getStoreboardTemplates() async {
    final query = Query<StoreboardTemplate>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addStoreboardTemplate(
      @Bind.body() StoreboardTemplate template) async {
    final query = Query<StoreboardTemplate>(context)
      ..values.name = template.name
      ..values.items = template.items;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateStoreboardTemplate(
      @Bind.path('id') int id, @Bind.body() StoreboardTemplate template) async {
    var query = Query<StoreboardTemplate>(context)
      ..values.name = template.name
      ..values.items = template.items
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteStoreboardTemplate(@Bind.path('id') int id) async {
    var query = Query<StoreboardTemplate>(context)
      ..where((t) => t.id).equalTo(id);

    var userTemplate = await query.delete();

    return Response.ok(userTemplate);
  }
}
