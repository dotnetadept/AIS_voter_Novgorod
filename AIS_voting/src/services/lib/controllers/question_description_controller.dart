import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/ais_model.dart';

class QuestionDescriptionController extends ResourceController {
  QuestionDescriptionController(this.context);

  final ManagedContext context;

  @Operation.put('id')
  Future<Response> updateQuestion(
      @Bind.path('id') int id, @Bind.body() Question question) async {
    // Update question description
    var query = Query<Question>(context)
      ..values.description = question.description
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }
}
