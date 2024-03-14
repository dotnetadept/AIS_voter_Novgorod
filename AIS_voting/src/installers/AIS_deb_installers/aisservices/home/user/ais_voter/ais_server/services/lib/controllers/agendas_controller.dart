import 'dart:io';
import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/ais_model.dart';
import '../models/agenda.dart';

class AgendasController extends ResourceController {
  AgendasController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAgendas() async {
    final query = Query<Agenda>(context)
      ..join(set: (a) => a.questions).join(set: (q) => q.files);
    return Response.ok(await query.fetch());
  }

  @Operation.get('id')
  Future<Response> getAgendaById(@Bind.path('id') int id) async {
    final q = Query<Agenda>(context)..where((o) => o.id).equalTo(id);
    final agenda = await q.fetchOne();

    if (agenda == null) {
      return Response.notFound();
    }

    return Response.ok(agenda);
  }

  @Operation.post()
  Future<Response> addAgenda(@Bind.body() Agenda agenda) async {
    final query = Query<Agenda>(context)
      ..values.name = agenda.name
      ..values.folder = agenda.folder
      ..values.lastUpdated = agenda.lastUpdated
      ..values.createdDate = agenda.createdDate;

    var insertedAgenda = await query.insert();

    await Future.forEach(agenda.questions, (Question q) async {
      var question = Query<Question>(context)
        ..values.name = q.name
        ..values.folder = q.folder
        ..values.description = q.description
        ..values.orderNum = q.orderNum
        ..values.agenda = insertedAgenda;

      var insertedQuestion = await question.insert();

      await Future.forEach(q.files, (File f) async {
        var file = Query<File>(context)
          ..values.path = f.path
          ..values.fileName = f.fileName
          ..values.version = f.version
          ..values.description = f.description
          ..values.question = insertedQuestion;

        await file.insert();
      });
    });

    var insertedAgendaQuery = Query<Agenda>(context)
      ..where((o) => o.id).equalTo(insertedAgenda.id);

    return Response.ok(await insertedAgendaQuery.fetchOne());
  }

  @Operation.put('id')
  Future<Response> updateAgenda(
      @Bind.path('id') int id, @Bind.body() Agenda agenda) async {
    var query = Query<Agenda>(context)
      ..values.name = agenda.name
      ..values.lastUpdated = agenda.lastUpdated
      ..where((u) => u.id).equalTo(id);

    // update question's order
    await Future.forEach(agenda.questions, (Question q) async {
      var question = Query<Question>(context)
        ..values.orderNum = q.orderNum
        ..where((u) => u.id).equalTo(q.id);
      await question.update();
    });

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteAgenda(@Bind.path('id') int id) async {
    // select agenda
    final q = Query<Agenda>(context)..where((o) => o.id).equalTo(id);
    final agenda = await q.fetchOne();

    if (agenda == null) {
      return Response.notFound();
    }

    // delete agenda
    var query = Query<Agenda>(context)..where((u) => u.id).equalTo(id);
    var agendaDeleted = await query.delete();

    // remove documents folder
    await Directory('documents/' + agenda.folder).delete(recursive: true);

    return Response.ok(agendaDeleted);
  }
}
