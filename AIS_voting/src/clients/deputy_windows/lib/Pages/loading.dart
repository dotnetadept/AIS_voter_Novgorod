import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import '../State/AppState.dart';

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        toolbarHeight: AppState().getScaledSize(56),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Row(children: [
          Expanded(
            child: Text(
              'Загрузка',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.all(AppState().getHalfScaledSize(10)),
            child: Text(
              AppState().getIsLoadingComplete()
                  ? 'Ожидание заседания'
                  : 'Загрузка',
              style: TextStyle(fontSize: AppState().getScaledSize(24)),
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
        ],
      ),
    );
  }
}
