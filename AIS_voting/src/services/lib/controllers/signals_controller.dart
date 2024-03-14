import 'package:aqueduct/aqueduct.dart';
import '../models/signal.dart';

class SignalsController extends ResourceController {
  SignalsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getSignals() async {
    final query = Query<Signal>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addSignal(@Bind.body() Signal signal) async {
    final query = Query<Signal>(context)
      ..values.orderNum = signal.orderNum
      ..values.name = signal.name
      ..values.duration = signal.duration
      ..values.color = signal.color
      ..values.volume = signal.volume
      ..values.soundPath = signal.soundPath;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateSignal(
      @Bind.path('id') int id, @Bind.body() Signal signal) async {
    var query = Query<Signal>(context)
      ..values.orderNum = signal.orderNum
      ..values.name = signal.name
      ..values.duration = signal.duration
      ..values.color = signal.color
      ..values.volume = signal.volume
      ..values.soundPath = signal.soundPath
      ..where((i) => i.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteSignal(@Bind.path('id') int id) async {
    var query = Query<Signal>(context)..where((i) => i.id).equalTo(id);

    var signalDeleted = await query.delete();

    return Response.ok(signalDeleted);
  }
}
