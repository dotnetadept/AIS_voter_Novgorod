import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _tecPassword = TextEditingController(text: AppState().getSavedPassword());
  final _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void onLogin() async {
    ScaffoldMessenger.of(_globalKey.currentContext).removeCurrentSnackBar();

    final connection = Provider.of<WebSocketConnection>(context, listen: false);
    connection.onLogin(_tecPassword.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            header(),
            body(),
            footer(),
          ],
        ),
      ),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget header() {
    return Container();
  }

  Widget body() {
    var manualLogin = <Widget>[
      Padding(
        padding: EdgeInsets.all(AppState().getHalfScaledSize(30)),
        child: TextField(
          controller: _tecPassword,
          style: TextStyle(fontSize: AppState().getScaledSize(30)),
          decoration: InputDecoration(
            labelText: 'Пароль',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(AppState().getHalfScaledSize(10)),
          ),
        ),
      ),
      TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(
              AppState().getScaledSize(300), AppState().getScaledSize(100))),
        ),
        onPressed: onLogin,
        child: Text(
          'Войти',
          style: TextStyle(
            fontSize: AppState().getScaledSize(30),
          ),
        ),
      ),
    ];

    var loginControls = <Widget>[
      Container(
        padding: EdgeInsets.all(AppState().getHalfScaledSize(20)),
        child: Text(
          AppState().getCurrentMeeting()?.group?.name ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppState().getScaledSize(34),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(AppState().getHalfScaledSize(20)),
        child: Text(
          AppState().getCurrentMeeting()?.name ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppState().getScaledSize(30),
          ),
        ),
      ),
    ];
    loginControls.addAll(manualLogin);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: loginControls,
    );
  }

  Widget footer() {
    return Container();
  }

  @override
  void dispose() {
    _tecPassword.dispose();

    super.dispose();
  }
}
