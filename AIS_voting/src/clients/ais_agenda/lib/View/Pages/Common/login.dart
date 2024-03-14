import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/main.dart';
import 'package:provider/provider.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tecPassword = TextEditingController(text: 'admin');
  final _globalKey = GlobalKey<ScaffoldState>();
  late Widget _currentView;

  @override
  void initState() {
    _currentView = loginView();
    super.initState();
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

  Widget header() {
    return Container();
  }

  Widget body() {
    var manualLogin = <Widget>[
      Padding(
        padding: const EdgeInsets.all(30),
        child: TextField(
          controller: _tecPassword,
          style: const TextStyle(fontSize: 30),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Пароль',
          ),
        ),
      ),
      TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(300, 100)),
        ),
        onPressed: onLogin,
        child: const Text(
          'Войти',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: manualLogin,
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
          defaultLayouts: const [VirtualKeyboardDefaultLayouts.English],
          type: VirtualKeyboardType.Numeric,
          onKeyPress: _onKeyPress),
    );
  }

  Widget loginConfirmView(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Войти как:",
            style: TextStyle(fontSize: 34),
          ),
          Container(
            height: 10,
          ),
          Text(
            user.toString(),
            style: const TextStyle(fontSize: 34),
          ),
          Container(
            height: 40,
          ),
          Row(
            children: [
              Expanded(child: Container()),
              TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(300, 100)),
                ),
                onPressed: () {
                  setState(() {
                    _currentView = loginView();
                  });
                },
                child: const Text(
                  'Отмена',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              Expanded(child: Container()),
              TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(300, 100)),
                ),
                onPressed: () async {
                  AppState().setCurrentUser(user);
                  Provider.of<AppState>(context, listen: false)
                      .navigateToPage('/calendar');
                  AppState().navigateToPage('/calendar');
                },
                child: const Text(
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

  void onLogin() async {
    var users = AppState().getUsers();

    var user = users
        .firstWhereOrNull((element) => element.password == _tecPassword.text);

    if (user != null) {
      setState(() {
        _currentView = loginConfirmView(user);
      });
    } else {
      rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Неверно введен пароль"),
        ),
      );
    }
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
