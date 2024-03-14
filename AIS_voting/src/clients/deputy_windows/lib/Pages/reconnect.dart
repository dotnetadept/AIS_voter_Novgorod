import 'dart:io';
import '/State/AppState.dart';
import 'package:global_configuration/global_configuration.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';

class ReconnectPage extends StatefulWidget {
  ReconnectPage({Key key}) : super(key: key);

  @override
  _ReconnectPageState createState() => _ReconnectPageState();
}

class _ReconnectPageState extends State<ReconnectPage> {
  Widget _body;
  var _tecPassword = TextEditingController(text: AppState().getSavedPassword());
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _isConnecting = GlobalConfiguration().getValue('auto_reconnect') == 'true';
    _body = _isConnecting ? connectingView() : reconnectView();
  }

  @override
  Widget build(BuildContext context) {
    WebSocketConnection.onConnect = onConnect;
    WebSocketConnection.onFail = onFail;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        titleSpacing: 0.0,
        toolbarHeight: AppState().getScaledSize(56),
        title: Row(children: [
          Expanded(
            child: Text(
              'Отсутствует подключение',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppState().getScaledSize(22)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (WebSocketConnection.onHide != null) {
                WebSocketConnection.onHide();
              }
            },
            child: Tooltip(
              message: 'Свернуть',
              child: Icon(
                Icons.minimize,
                size: AppState().getScaledSize(24),
              ),
            ),
          ),
          Container(
            width: AppState().getScaledSize(15),
          ),
        ]),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        child: _body,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget reconnectView() {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.all(AppState().getHalfScaledSize(10)),
            child: Text(
              'Подключиться',
              style: TextStyle(
                fontSize: AppState().getScaledSize(32),
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(
                  AppState().getScaledSize(75), AppState().getScaledSize(75))),
              shape: MaterialStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () async {
              setState(() {
                _body = connectingView();
              });

              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              WebSocketConnection.resumeConnect();
              WebSocketConnection.connect();
            },
            child: Icon(
              Icons.replay_rounded,
              size: AppState().getScaledSize(45),
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _body = settingsView();
                  });
                },
                child: Row(
                  children: [
                    Text(
                      'Настройки',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppState().getScaledSize(16)),
                    ),
                    Container(
                      width: AppState().getScaledSize(5),
                    ),
                    Icon(
                      Icons.settings,
                      size: AppState().getScaledSize(24),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Container(
            height: AppState().getScaledSize(20),
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: Row(
                  children: [
                    Text(
                      'Выход',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: AppState().getScaledSize(16)),
                    ),
                    Container(
                      width: AppState().getScaledSize(5),
                    ),
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.redAccent,
                      size: AppState().getScaledSize(24),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget connectingView() {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.all(AppState().getHalfScaledSize(10)),
            child: Text(
              'Подключение',
              style: TextStyle(
                fontSize: AppState().getScaledSize(32.0),
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Container(
            height: AppState().getScaledSize(43),
            width: AppState().getScaledSize(43),
            child: CircularProgressIndicator(),
          ),
          Expanded(
            child: Container(),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                WebSocketConnection.cancelConnect();
                _body = reconnectView();
              });
            },
            child: Text(
              'Отмена',
              style: TextStyle(
                fontSize: AppState().getScaledSize(20.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: AppState().getScaledSize(40.0),
          ),
        ],
      ),
    );
  }

  Widget settingsView() {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.all(AppState().getHalfScaledSize(20)),
            child: TextField(
              controller: _tecPassword,
              style: TextStyle(fontSize: AppState().getScaledSize(30)),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.all(AppState().getHalfScaledSize(10)),
                labelText: 'Пароль',
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _body = reconnectView();
                  });
                },
                child: Row(
                  children: [
                    Text(
                      'Отмена',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppState().getScaledSize(16)),
                    ),
                    Container(
                      width: AppState().getScaledSize(5),
                    ),
                    Icon(
                      Icons.settings,
                      size: AppState().getScaledSize(24),
                    ),
                  ],
                ),
              ),
              Container(
                width: AppState().getScaledSize(20),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  if (_tecPassword.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Пароль не должен быть пустым"),
                        duration: Duration(days: 1),
                      ),
                    );
                  } else {
                    AppState().setSavedPassword(_tecPassword.text);

                    setState(() {
                      _body = reconnectView();
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      'Сохранить',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: AppState().getScaledSize(16)),
                    ),
                    Container(
                      width: AppState().getScaledSize(5),
                    ),
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.redAccent,
                      size: AppState().getScaledSize(24),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  void onConnect() {
    WebSocketConnection.onConnect = null;
    WebSocketConnection.onFail = null;
  }

  void onFail(String message) {
    setState(() {
      _body = reconnectView();
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("В ходе подключения возникла ошибка: $message"),
        duration: Duration(days: 1),
      ),
    );
  }
}
