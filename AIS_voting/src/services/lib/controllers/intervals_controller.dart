import 'package:aqueduct/aqueduct.dart';
import 'package:services/models/signal.dart';
import '../models/interval.dart';

class IntervalsController extends ResourceController {
  IntervalsController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIntervals() async {
    final query = Query<Interval>(context);

    var allIntervals = await query.fetch();

    final querySignals = Query<Signal>(context);
    var allSignals = await querySignals.fetch();

    for (var i = 0; i < allIntervals.length; i++) {
      var interval = allIntervals[i];

      var signalStart = allSignals.firstWhere(
          (element) => element.id == interval.startSignal?.id,
          orElse: () => null);
      interval.startSignal = signalStart;

      var endSignal = allSignals.firstWhere(
          (element) => element.id == interval.endSignal?.id,
          orElse: () => null);
      interval.endSignal = endSignal;
    }
    return Response.ok(allIntervals);
  }

  @Operation.post()
  Future<Response> addInterval(@Bind.body() Interval interval) async {
    final query = Query<Interval>(context)
      ..values.orderNum = interval.orderNum
      ..values.name = interval.name
      ..values.duration = interval.duration
      ..values.startSignal = interval.startSignal
      ..values.endSignal = interval.endSignal
      ..values.isActive = interval.isActive
      ..values.isAutoEnd = interval.isAutoEnd;

    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateInterval(
      @Bind.path('id') int id, @Bind.body() Interval interval) async {
    var query = Query<Interval>(context)
      ..values.orderNum = interval.orderNum
      ..values.name = interval.name
      ..values.duration = interval.duration
      ..values.startSignal = interval.startSignal
      ..values.endSignal = interval.endSignal
      ..values.isActive = interval.isActive
      ..values.isAutoEnd = interval.isAutoEnd
      ..where((i) => i.id).equalTo(id);

    return Response.ok(await query.update());
  }

  @Operation.delete('id')
  Future<Response> deleteInterval(@Bind.path('id') int id) async {
    var query = Query<Interval>(context)..where((i) => i.id).equalTo(id);

    var intervalDeleted = await query.delete();

    return Response.ok(intervalDeleted);
  }
}
