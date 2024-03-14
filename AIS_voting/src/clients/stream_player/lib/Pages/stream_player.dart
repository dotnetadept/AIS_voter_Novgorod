import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';

class StreamPlayerPage extends StatefulWidget {
  const StreamPlayerPage({Key key}) : super(key: key);

  @override
  State<StreamPlayerPage> createState() => _StreamPlayerPageState();
}

class _StreamPlayerPageState extends State<StreamPlayerPage> {
  WebSocket _webSocket;
  WebSocketChannel _channel;
  Settings _settings;
  bool _isLoadingComplete = false;
  bool _isOnline = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ServerState _serverState = null;
  bool _isStreamStarted = false;
  bool _isOperatorControl = false;
  bool _isUserControl = false;
  bool _showAskWordButton = false;
  int _selectedMeetingId = null;

  @override
  void initState() {
    super.initState();

    loadData();
    initNewChannel();
  }

  void loadData() {
    http
        .get(
            '${ServerConnection.getHttpServerUrl(GlobalConfiguration())}/settings')
        .then((response) => {
              setState(() {
                _settings = (json.decode(response.body) as List)
                    .map((data) => Settings.fromJson(data))
                    .toList()
                    .first;

                _isLoadingComplete = true;
              })
            });
  }

  /// Creates new instance of IOWebSocketChannel and initializes socket listening
  void initNewChannel() async {
    try {
      if (_webSocket != null) {
        _webSocket.close();
      }

      _webSocket = await WebSocket.connect(
          ServerConnection.getWebSocketServerUrl(GlobalConfiguration()),
          headers: {'type': 'stream_player'}).timeout(
        const Duration(seconds: 10),
      );
      _webSocket.pingInterval = Duration(
        seconds: int.parse(GlobalConfiguration().getValue('ping_interval')),
      );

      _channel = IOWebSocketChannel(_webSocket);

      _channel.stream.listen((data) => processMessage(data),
          onDone: reconnect, onError: wserror, cancelOnError: true);
    } catch (exc) {
      reconnect();
    }
  }

  processMessage(data) {
    _isOnline = true;

    _serverState = ServerState.fromJson(json.decode(data));
    _isStreamStarted = _serverState.isStreamStarted;
    _isUserControl = _serverState.streamControl == 'user';
    _isOperatorControl = _serverState.streamControl == 'operator';
    _showAskWordButton = _serverState.showAskWordButton;
    _selectedMeetingId = json.decode(_serverState.params)['selectedMeeting'];

    if (_isUserControl == false && _isOperatorControl == false) {
      _isOperatorControl = true;
    }
    setState(() {});
  }

  wserror(err) async {
    print('WebSocket error:${err.toString()}');
    await reconnect();
  }

  // reconnecting websocket
  reconnect() async {
    print('Reconnect to server ...');
    setState(() {
      _isOnline = false;
    });

    // add in a reconnect delay
    await Future.delayed(const Duration(seconds: 1));

    initNewChannel();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return getLoadingStub('Подключение');
    }

    if (!_isLoadingComplete) {
      return getLoadingStub('Загрузка');
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: _isStreamStarted
              ? Text(
                  'Трансляция запущена',
                  style: TextStyle(color: Colors.greenAccent),
                )
              : Text('Трансляция остановлена'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Container(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                  value: _isOperatorControl,
                                  onChanged: (value) {
                                    if (value == true) {
                                      _isOperatorControl = true;
                                      _isUserControl = false;
                                    } else {
                                      _isOperatorControl = false;
                                      _isUserControl = true;
                                    }

                                    setState(() {});
                                  },
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              const Text(
                                'Под управлением оператора',
                                style: TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                          Container(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                    value: _isUserControl,
                                    onChanged: (value) {
                                      if (value == true) {
                                        _isUserControl = true;
                                        _isOperatorControl = false;
                                      } else {
                                        _isUserControl = false;
                                        _isOperatorControl = true;
                                      }

                                      setState(() {});
                                    }),
                              ),
                              Container(
                                width: 10,
                              ),
                              const Text(
                                'Под управлением пользователя',
                                style: TextStyle(fontSize: 22),
                              )
                            ],
                          ),
                          Container(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                    value: _showAskWordButton,
                                    onChanged: (value) {
                                      setState(() {
                                        _showAskWordButton = value == true;
                                      });
                                    }),
                              ),
                              Container(
                                width: 10,
                              ),
                              const Text(
                                'Отображать кнопку прошу слово',
                                style: TextStyle(fontSize: 22),
                              )
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
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextButton(
                          child: Row(children: [
                            const Text(
                              'Остановить',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              width: 4,
                            ),
                            const Icon(Icons.stop)
                          ]),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _channel.sink.add(json.encode({
                              'isStreamStarted': false,
                            }));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: TextButton(
                          child: Row(children: [
                            const Text(
                              'Перезагрузить',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              width: 4,
                            ),
                            const Icon(Icons.refresh)
                          ]),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _channel.sink.add(json.encode({
                              'refresh_stream': 'true',
                              'params': json.encode({
                                'stream_control':
                                    _isOperatorControl ? 'operator' : 'user',
                                'show_askword_button': _showAskWordButton,
                              })
                            }));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextButton(
                          child: Row(children: [
                            const Text(
                              'Начать',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              width: 4,
                            ),
                            const Icon(Icons.play_arrow)
                          ]),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _channel.sink.add(json.encode({
                              'isStreamStarted': true,
                              'params': json.encode({
                                'stream_control':
                                    _isOperatorControl ? 'operator' : 'user',
                                'show_askword_button': _showAskWordButton,
                              })
                            }));
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 00),
                        child: TextButton(
                          child: Row(
                            children: [
                              const Text(
                                'Выход',
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(
                                width: 4,
                              ),
                              const Icon(Icons.exit_to_app),
                            ],
                          ),
                          onPressed: () {
                            exit(0);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                        child: TextButton(
                          child: Row(children: [
                            const Text(
                              'Завершить заседание',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              width: 4,
                            ),
                            const Icon(Icons.stop)
                          ]),
                          onPressed: () async {
                            if (_selectedMeetingId == null) {
                              Utility().showMessageOkDialog(context,
                                  title: 'Отсутвует начатое заседание',
                                  message: TextSpan(
                                    text: 'Отсутвует начатое заседание',
                                  ),
                                  okButtonText: 'Ок');
                              return;
                            }

                            var noButtonPressed = false;

                            await Utility().showYesNoDialog(
                              context,
                              title: 'Завершить заседание',
                              message: TextSpan(
                                text:
                                    'Вы уверены, что хотите завершить заседание?',
                              ),
                              yesButtonText: 'Да',
                              yesCallBack: () {
                                Navigator.of(context).pop();
                              },
                              noButtonText: 'Нет',
                              noCallBack: () {
                                noButtonPressed = true;
                                Navigator.of(context).pop();
                              },
                            );

                            if (noButtonPressed) {
                              return;
                            }

                            if (SystemStateHelper.isStarted(
                                _serverState.systemState)) {
                              _channel.sink.add(json.encode({
                                'systemState': EnumToString.convertToString(
                                  SystemState.MeetingCompleted,
                                ),
                                'params': json.encode({
                                  'meeting_id': _selectedMeetingId,
                                }),
                              }));
                            }

                            if (SystemStateHelper.isPreparation(
                                _serverState.systemState)) {
                              _channel.sink.add(json.encode({
                                'systemState': EnumToString.convertToString(
                                  SystemState.MeetingPreparationComplete,
                                ),
                                'params': json.encode({
                                  'meeting_id': _selectedMeetingId,
                                }),
                              }));
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                        child: TextButton(
                          child: Row(children: [
                            const Text(
                              'Выключить все терминалы',
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              width: 4,
                            ),
                            const Icon(Icons.power_off)
                          ]),
                          onPressed: () async {
                            var noButtonPressed = false;

                            await Utility().showYesNoDialog(
                              context,
                              title: 'Выключить все терминалы',
                              message: TextSpan(
                                text:
                                    'Вы уверены, что хотите выключить все терминалы?',
                              ),
                              yesButtonText: 'Да',
                              yesCallBack: () {
                                Navigator.of(context).pop();
                              },
                              noButtonText: 'Нет',
                              noCallBack: () {
                                noButtonPressed = true;
                                Navigator.of(context).pop();
                              },
                            );

                            if (noButtonPressed) {
                              return;
                            }
                            _channel.sink.add(json.encode({
                              'shutdown_all': 'true',
                            }));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          getStatePanel(),
        ],
      ),
    );
  }

  Widget getStatePanel() {
    return Container(
      height: 50,
      color: Colors.lightBlueAccent.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 10,
          ),
          Tooltip(
            message: 'Сервер онлайн',
            child: Icon(
              Icons.circle,
              color: Colors.green,
            ),
          ),
          Container(
            width: 20,
          ),
          LicenseWidget(
            serverState: _serverState,
            settings: _settings,
            navigateLicenseTab: null,
          ),
          Container(
            width: 20,
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget getLoadingStub(String caption) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container()),
          Row(
            children: [
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(
                  caption,
                  style: const TextStyle(
                    fontSize: 40.0,
                  ),
                ),
              ),
              const CircularProgressIndicator(),
              Expanded(child: Container()),
            ],
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
