import 'dart:convert';
import '/State/CurrentUser.dart';
import '/State/WebSocketConnection.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _tecPassword = TextEditingController();
  final _globalKey = GlobalKey<ScaffoldState>();
  Widget _currentView;

  @override
  void initState() {
    _currentView = loginView();
    super.initState();
  }

  void onLogin() async {
    await http
        .get(Uri.parse(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                "/settings"))
        .then((response) {
      var settings = (json.decode(response.body) as List)
          .map((data) => Settings.fromJson(data))
          .toList()
          .first;
      AppState().setSettings(settings);
    });

    var users = <User>[];
    await http
        .get(Uri.parse(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
                "/users"))
        .then((response) {
      users = (json.decode(response.body) as List)
          .map((data) => User.fromJson(data))
          .toList();
      AppState().setUsers(users);
    });

    var user = users.firstWhere(
        (element) =>
            AppState()
                .getCurrentMeeting()
                .group
                .groupUsers
                .any((gu) => gu.user.id == element.id) &&
            element.password == _tecPassword.text,
        orElse: () => null);

    if (user != null) {
      setState(() {
        _currentView = loginConfirmView(user);
      });
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(_globalKey.currentContext).showSnackBar(
        SnackBar(
          content: Text("Неверно введен пароль"),
        ),
      );
    }
  }

  void onLoginAsGuest() async {
    AppState().setCurrentUser(null);
    AppState().setCurrentQuestion(null);
    AppState().setCurrentDocument(null);
    AppState().setAgendaDocument(null);
    AppState().setAgendaScrollPosition(0.0);

    final wsConnection =
        Provider.of<WebSocketConnection>(context, listen: false);
    wsConnection.updateClientType('guest', null, isManualLogin: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Stack(
        children: [
          _currentView,
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'v 1.34',
                    style: TextStyle(
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget loginView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          header(),
          body(),
          footer(),
        ],
      ),
    );
  }

  Widget loginConfirmView(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Войти как:",
            style: TextStyle(fontSize: 34),
          ),
          Container(
            height: 10,
          ),
          Text(
            user.toString(),
            style: TextStyle(fontSize: 34),
          ),
          Container(
            height: 40,
          ),
          Row(
            children: [
              Expanded(child: Container()),
              TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(300, 100)),
                ),
                onPressed: () {
                  setState(() {
                    _currentView = loginView();
                  });
                },
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              Expanded(child: Container()),
              TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(300, 100)),
                ),
                onPressed: () {
                  final currentUser =
                      Provider.of<CurrentUser>(context, listen: false);
                  currentUser.setCurrentUser(user);
                  final wsConnection =
                      Provider.of<WebSocketConnection>(context, listen: false);
                  wsConnection.updateClientType(
                      AppState().isCurrentUserManager() ? 'manager' : 'deputy',
                      user.id,
                      isManualLogin: true);
                },
                child: Text(
                  'Подтвердить',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container();
  }

  Widget body() {
    var manualLogin = <Widget>[
      Padding(
        padding: EdgeInsets.all(30),
        child: TextField(
          controller: _tecPassword,
          style: TextStyle(fontSize: 30),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Пароль',
          ),
        ),
      ),
      TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(300, 100)),
        ),
        onPressed: onLogin,
        child: Text(
          'Войти',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    ];

    var loginAsGustButton = Container(
      padding: EdgeInsets.all(10),
      child: TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(300, 100)),
        ),
        onPressed: onLoginAsGuest,
        child: Text(
          'Войти как гость',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );

    var loginControls = <Widget>[
      Container(
        child: Text(
          AppState().getCurrentMeeting()?.group?.name ?? '',
          style: TextStyle(
            fontSize: 34,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(20),
        child: Text(
          AppState().getCurrentMeeting()?.name ?? '',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    ];
    loginControls.addAll(manualLogin);
    loginControls.add(loginAsGustButton);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: loginControls,
    );
  }

  Widget footer() {
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.blue,
      child: VirtualKeyboard(
          height: 300,
          textColor: Colors.white,
          textController: _tecPassword,
          fontSize: 24,
          defaultLayouts: [VirtualKeyboardDefaultLayouts.English],
          type: VirtualKeyboardType.Numeric,
          onKeyPress: _onKeyPress),
    );
  }

  /// Fired when the virtual keyboard key is pressed.
  void _onKeyPress(VirtualKeyboardKey key) {
    // Update the screen
    setState(() {});
  }

  @override
  void dispose() {
    _tecPassword.dispose();

    super.dispose();
  }
}
