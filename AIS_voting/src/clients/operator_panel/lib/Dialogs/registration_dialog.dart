import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:provider/provider.dart';
import '../Providers/AppState.dart';
import '../Providers/WebSocketConnection.dart';
import 'package:ais_model/ais_model.dart' as ais;

class RegistrationDialog {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tecInterval;

  BuildContext _context;
  Settings _settings;
  late WebSocketConnection _connection;
  late ais.Interval _interval;

  RegistrationDialog(
    this._context,
    this._settings,
  ) {
    _connection = Provider.of<WebSocketConnection>(_context, listen: false);
    _interval = AppState().getIntervals().firstWhere((element) =>
        element.id ==
        _settings.intervalsSettings.defaultRegistrationIntervalId);
    _tecInterval = TextEditingController(text: _interval.duration.toString());
  }

  Future<void> openDialog() async {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                  color: Colors.lightBlue,
                  alignment: Alignment.center,
                  child: Text(
                    'Регистрация',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 28),
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecInterval,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Время регистрации, с:',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите время регистрации';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Введите целое число';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 20, 20),
              child: TextButton(
                child: Text('Отмена', style: TextStyle(fontSize: 20)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: TextButton(
                child:
                    Text('Начать регистрацию', style: TextStyle(fontSize: 20)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }

                  var interval = int.tryParse(_tecInterval.text);

                  _connection.getWsChannel.sink.add(json.encode({
                    'systemState':
                        EnumToString.convertToString(SystemState.Registration),
                    'params': json.encode({
                      'registration_interval': interval,
                      'startSignal': json.encode(_interval.startSignal),
                      'endSignal': json.encode(_interval.endSignal),
                      'autoEnd': _interval.isAutoEnd,
                    })
                  }));

                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
