import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReconnectPage extends StatefulWidget {
  ReconnectPage({Key key}) : super(key: key);

  @override
  _ReconnectPageState createState() => _ReconnectPageState();
}

class _ReconnectPageState extends State<ReconnectPage> {
  bool _isConnecting = false;

  @override
  void initState() {
    _isConnecting = GlobalConfiguration().getValue('auto_reconnect') == 'true';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text('Отсутствует подключение'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                _isConnecting ? 'Подключение' : 'Подключиться',
                style: TextStyle(
                  fontSize: 32.0,
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
                      minimumSize: MaterialStateProperty.all(Size(75, 75)),
                      shape: MaterialStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isConnecting = true;
                      });

                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    },
                    child: Icon(
                      Icons.replay_rounded,
                      size: 68,
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
                    SystemNavigator.pop();
                  },
                  child: Row(
                    children: [
                      Text(
                        'Выход',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                        width: 5,
                      ),
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                ),
              ],
            ),
            Container(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
