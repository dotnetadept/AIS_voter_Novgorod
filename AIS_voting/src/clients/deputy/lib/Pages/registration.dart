import 'dart:async';
import 'dart:convert' show json;
import 'package:ais_utils/time_util.dart';
import 'package:global_configuration/global_configuration.dart';

import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class RegistrationPage extends StatefulWidget {
  final startInterval;
  RegistrationPage({Key? key, this.startInterval}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var _interval = 0;
  late DateTime _startDate;
  var _secondRemain = 0;
  var _indicatorValue = 0.0;
  late Timer _registrationTimer;
  bool _isBigButtons = false;

  @override
  void initState() {
    super.initState();

    _isBigButtons =
        GlobalConfiguration().getValue('registration_view_use_flex_buttons') ==
            'true';

    _interval = AppState().getServerState().registrationSession!.interval;
    _startDate = DateTime.parse(
        json.decode(AppState().getServerState().params)['lastUpdated']);

    var secondsElapsed = getSecondElapsed();
    _indicatorValue = secondsElapsed / _interval;
    _secondRemain =
        _interval - secondsElapsed < 0 ? 0 : _interval - secondsElapsed;

    _registrationTimer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => setIndicatorValue());
  }

  @override
  void dispose() {
    _registrationTimer.cancel();

    super.dispose();
  }

  void setIndicatorValue() {
    setState(() {
      var secondsElapsed = getSecondElapsed();
      _indicatorValue = secondsElapsed / _interval;
      _secondRemain =
          _interval - secondsElapsed < 0 ? 0 : _interval - secondsElapsed;
    });
  }

  int getSecondElapsed() {
    return ((TimeUtil.getDateTimeNow(AppState().getTimeOffset())
                    .millisecondsSinceEpoch -
                _startDate.millisecondsSinceEpoch) /
            1000)
        .round();
  }

  void onRegistration(String value) {
    Provider.of<WebSocketConnection>(context, listen: false).sendMessage(value);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: true);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Text(AppState().getCurrentUser().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Text('Регистрация',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            ),
            _secondRemain <= 0
                ? Container()
                : Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    child: LinearProgressIndicator(
                      value: _indicatorValue,
                      minHeight: 10,
                    ),
                  ),
            _secondRemain <= 0
                ? Container()
                : Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      'Осталось ${_secondRemain ~/ 60} мин ${_secondRemain % 60} сек',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
            getRegistrationButton(),
            _isBigButtons
                ? Container()
                : Expanded(
                    flex: 3,
                    child: Container(),
                  ),
          ],
        ),
      ),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget getRegistrationButton() {
    return _isBigButtons
        ? getBigRegistrationButton()
        : getSmallRegistrationButton();
  }

  Widget getBigRegistrationButton() {
    return Expanded(
      flex: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(AppState()
                        .getSettings()
                        .palletteSettings
                        .buttonTextColor),
                    width: 5,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanDown: (DragDownDetails d) =>
                        AppState().getIsRegistred()
                            ? null
                            : {onRegistration('ЗАРЕГИСТРИРОВАТЬСЯ')},
                    child: TextButton(
                      autofocus: true,
                      style: TextButton.styleFrom(
                        foregroundColor: AppState().getIsRegistred()
                            ? Colors.green
                            : Colors.blue,
                        backgroundColor: AppState().getIsRegistred()
                            ? Colors.green
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero)),
                      ),
                      onPressed: () => null,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          AppState().getIsRegistred()
                              ? 'ЗАРЕГИСТРИРОВАН'
                              : 'ЗАРЕГИСТРИРОВАТЬСЯ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(AppState()
                                .getSettings()
                                .palletteSettings
                                .buttonTextColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSmallRegistrationButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(
                AppState().getSettings().palletteSettings.buttonTextColor),
            width: 5,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: (DragDownDetails d) => AppState().getIsRegistred()
              ? null
              : {onRegistration('ЗАРЕГИСТРИРОВАТЬСЯ')},
          child: TextButton(
            autofocus: true,
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(Size(350, 100)),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
            onPressed: () => null,
            child: Container(
              color: AppState().getIsRegistred() ? Colors.green : Colors.blue,
              height: 100,
              width: 350,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  AppState().getIsRegistred()
                      ? 'ВЫ ЗАРЕГИСТРИРОВАНЫ'
                      : 'ЗАРЕГИСТРИРОВАТЬСЯ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(AppState()
                        .getSettings()
                        .palletteSettings
                        .buttonTextColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
