import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/WebSocketConnection.dart';
import '../Providers/AppState.dart';

class ReconnectPage extends StatefulWidget {
  ReconnectPage({Key? key}) : super(key: key);

  @override
  _ReconnectPageState createState() => _ReconnectPageState();
}

class _ReconnectPageState extends State<ReconnectPage> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WebSocketConnection.onConnect = onConnect;
    WebSocketConnection.onFail = onFail;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Отсутствует подключение'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Подключиться',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            _isConnecting
                ? Container(
                    child: CircularProgressIndicator(),
                  )
                : TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isConnecting = true;
                      });

                      await Provider.of<WebSocketConnection>(context,
                              listen: false)
                          .initNewChannel();
                      if (AppState().refreshDialog != null) {
                        AppState().refreshDialog!(() {});
                      }
                    },
                    child: Icon(Icons.replay_rounded),
                  ),
          ],
        ),
      ),
    );
  }

  void onConnect() {
    WebSocketConnection.onConnect = null;
    WebSocketConnection.onFail = null;
    if (AppState().getIsLoadingComplete()) {
      Navigator.of(context).pop();
    } else {
      AppState().navigateMainPage();
    }
  }

  void onFail(String message) {
    setState(() {
      _isConnecting = false;
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("В ходе подключения возникла ошибка: $message"),
      ),
    );
  }
}
