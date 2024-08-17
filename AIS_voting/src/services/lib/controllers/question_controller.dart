import 'dart:io';
import 'package:conduit_core/conduit_core.dart';
import 'package:services/models/ais_model.dart';

class QuestionController extends ResourceController {
  QuestionController(this.context);

  final ManagedContext context;

  @Operation.post()
  Future<Response> addQuestion(@Bind.body() Question question) async {
    final query = Query<Question>(context)
      ..values.name = question.name
      ..values.folder = question.folder
      ..values.orderNum = question.orderNum
      ..values.accessRights = question.accessRights
      ..values.agenda = question.agenda
      ..values.description = question.description;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateQuestion(
      @Bind.path('id') int id, @Bind.body() Question question) async {
    final query = Query<Question>(context)
      ..values.name = question.name
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteQuestion(@Bind.path('id') int id) async {
    // select question
    final q = Query<Question>(context)..where((o) => o.id).equalTo(id);
    final question = await q.fetchOne();

    if (question == null) {
      return Response.notFound();
    }

    final a = Query<Agenda>(context)
      ..where((o) => o.id).equalTo(question.agenda.id);
    final agenda = await a.fetchOne();

    if (agenda == null) {
      return Response.notFound();
    }

    // remove documents folder
    await Directory('documents/' + agenda.folder + '/' + question.folder)
        .delete(recursive: true)
        .catchError((err) {});

    // delete agenda
    var query = Query<Question>(context)..where((u) => u.id).equalTo(id);

    return Response.ok(await query.delete());
  }
}
