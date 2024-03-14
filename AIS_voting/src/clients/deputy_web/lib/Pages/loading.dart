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

    AppState.getInstance().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text('Загрузка'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  AppState().getIsLoadingComplete()
                      ? 'Ожидание заседания'
                      : 'Загрузка',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                child: CircularProgressIndicator(),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
