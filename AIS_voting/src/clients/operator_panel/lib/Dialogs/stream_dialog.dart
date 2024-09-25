import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:provider/provider.dart';
import '../Providers/WebSocketConnection.dart';

class StreamDialog {
  final void Function() onHymnStartSound;
  final void Function() onHymnEndSound;
  final void Function() onPlayerCancel;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  BuildContext _context;
  Settings _settings;
  late WebSocketConnection _connection;
  bool _isOperatorControl = false;
  bool _isUserControl = false;
  bool _showToManager = false;
  bool _showAskWordButton = false;

  int _currentTabIndex = 1;

  StreamDialog(
    this._context,
    this._settings,
    this.onHymnStartSound,
    this.onHymnEndSound,
    this.onPlayerCancel,
  ) {
    _connection = Provider.of<WebSocketConnection>(_context, listen: false);
    _currentTabIndex = _connection.getServerState.isStreamStarted ? 0 : 1;
    _isOperatorControl = _connection.getServerState.streamControl == 'operator';
    _isUserControl = _connection.getServerState.streamControl == 'user';
    _showToManager = _connection.getServerState.showToManager == true;
    _showAskWordButton = _connection.getServerState.showAskWordButton == true;

    // set _isOperatorControl = true by default
    if (!_isOperatorControl && !_isUserControl) {
      _isOperatorControl = true;
    }
  }

  Future<void> openDialog() async {
    return showDialog<void>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStateForDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                      color: Colors.lightBlue,
                      alignment: Alignment.center,
                      child: Text(
                        'Начать трансляцию',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 28),
                      ),
                    ),
                  ),
                ],
              ),
              content: DefaultTabController(
                length: 2,
                initialIndex: _currentTabIndex,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      width: 750,
                      color: Colors.lightBlueAccent,
                      child: TabBar(
                        onTap: (index) {
                          setStateForDialog(() {
                            _currentTabIndex = index;
                          });
                        },
                        tabs: [
                          Tab(
                            icon: Icon(
                              Icons.video_call,
                              color: _connection.getServerState.isStreamStarted
                                  ? Colors.greenAccent
                                  : Colors.white,
                              size: 42,
                            ),
                            text: 'Онлайн трансляция',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.video_call,
                              color: _connection.getServerState.playSound ==
                                          _settings.signalsSettings.hymnStart ||
                                      _connection.getServerState.playSound ==
                                          _settings.signalsSettings.hymnEnd
                                  ? Colors.greenAccent
                                  : Colors.white,
                              size: 42,
                            ),
                            text: 'Гимн',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 750,
                      height: 400,
                      padding: EdgeInsets.all(15),
                      child: TabBarView(
                        children: [
                          getOnlineSteamTab(context, setStateForDialog),
                          getHymnTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget getOnlineSteamTab(BuildContext context, Function setStateForDialog) {
    return Column(
      children: [
        Container(
          height: 20,
        ),
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Под управлением:'),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: RadioListTile<bool>(
                    title: Text('Оператора'),
                    value: true,
                    groupValue: _isOperatorControl,
                    onChanged: (bool? value) {
                      setStateForDialog(() {
                        _isOperatorControl = value == true;
                        _isUserControl = false;
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: RadioListTile<bool>(
                    title: Text('Пользователя'),
                    value: true,
                    groupValue: _isUserControl,
                    onChanged: (bool? value) {
                      setStateForDialog(() {
                        _isOperatorControl = false;
                        _isUserControl = value == true;
                      });
                    },
                  ),
                ),
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: _showToManager,
                        onChanged: (value) {
                          setStateForDialog(() {
                            _showToManager = value == true;
                          });
                        }),
                    Text('Показывать стрим на рабочем месте Председателя')
                  ],
                ),
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                        value: _showAskWordButton,
                        onChanged: (value) {
                          setStateForDialog(() {
                            _showAskWordButton = value == true;
                          });
                        }),
                    Text('Отображать кнопку прошу слово')
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(),
        ),
        Row(
          children: [
            Expanded(
              child: Container(),
            ),
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
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: TextButton(
                child: Row(children: [
                  Text(
                    'Остановить',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    width: 4,
                  ),
                  Icon(Icons.stop)
                ]),
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  _connection.getWsChannel.sink.add(json.encode({
                    'isStreamStarted': false,
                  }));

                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
              child: TextButton(
                child: Row(children: [
                  Text(
                    'Перезагрузить',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    width: 4,
                  ),
                  Icon(Icons.refresh)
                ]),
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  _connection.getWsChannel.sink.add(json.encode({
                    'refresh_stream': 'true',
                    'params': json.encode({
                      'stream_control':
                          _isOperatorControl ? 'operator' : 'user',
                      'show_to_manager': _showToManager,
                      'show_askword_button': _showAskWordButton,
                    })
                  }));

                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
              child: TextButton(
                child: Row(children: [
                  Text(
                    'Начать',
                    style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    width: 4,
                  ),
                  Icon(Icons.play_arrow)
                ]),
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  _connection.getWsChannel.sink.add(json.encode({
                    'isStreamStarted': true,
                    'params': json.encode({
                      'stream_control':
                          _isOperatorControl ? 'operator' : 'user',
                      'show_to_manager': _showToManager,
                      'show_askword_button': _showAskWordButton,
                    })
                  }));

                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget getHymnTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(),
        ),
        TextButton(
          child: Row(children: [
            Text('Гимн 1', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Container(
                  //width: 20,
                  ),
            ),
            Icon(
              Icons.volume_up,
              color: _connection.getServerState.playSound ==
                      _settings.signalsSettings.hymnStart
                  ? Colors.green
                  : Colors.white,
            ),
          ]),
          onPressed: () {
            onHymnStartSound();
            Navigator.of(context).pop();
          },
        ),
        Container(
          height: 20,
        ),
        TextButton(
          child: Row(children: [
            Text('Гимн 2', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Container(),
            ),
            Icon(
              Icons.volume_up,
              color: _connection.getServerState.playSound ==
                      _settings.signalsSettings.hymnEnd
                  ? Colors.green
                  : Colors.white,
            ),
          ]),
          onPressed: () {
            onHymnEndSound();
            Navigator.of(context).pop();
          },
        ),
        Container(
          height: 20,
        ),
        TextButton(
          child: Row(children: [
            Text('Отмена', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Container(),
            ),
            Icon(Icons.volume_off),
          ]),
          onPressed: () {
            onPlayerCancel();
            Navigator.of(context).pop();
          },
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
