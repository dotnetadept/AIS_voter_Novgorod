import 'dart:io' as io;
import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/ais_model.dart';
import '../models/question.dart';

class QuestionFileController extends ResourceController {
  QuestionFileController(this.context);

  final ManagedContext context;

  @Operation.post()
  Future<Response> addQuestionFile(@Bind.body() File file) async {
    final query = Query<File>(context)
      ..values.path = file.path
      ..values.fileName = file.fileName
      ..values.version = file.version
      ..values.description = file.description
      ..values.question = file.question;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateQuestionFile(
      @Bind.path('id') int id, @Bind.body() File file) async {
    var query = Query<File>(context)
      ..values.path = file.path
      ..values.fileName = file.fileName
      ..values.version = file.version
      ..values.description = file.description
      ..values.question = file.question
      ..where((u) => u.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteQuestionFile(@Bind.path('id') int id) async {
    // select items chain
    final f = Query<File>(context)..where((o) => o.id).equalTo(id);
    final file = await f.fetchOne();

    final q = Query<Question>(context)
      ..where((o) => o.id).equalTo(file.question.id);
    final question = await q.fetchOne();

    final a = Query<Agenda>(context)
      ..where((o) => o.id).equalTo(question.agenda.id);
    final agenda = await a.fetchOne();

    if (question == null || agenda == null) {
      return Response.notFound();
    }

    // remove documents folder
    await io.File('documents/' +
            agenda.folder +
            '/' +
            question.folder +
            '/' +
            file.fileName)
        .delete(recursive: true);

    // delete file
    var query = Query<File>(context)..where((u) => u.id).equalTo(id);
    return Response.ok(await query.delete());
  }
}
