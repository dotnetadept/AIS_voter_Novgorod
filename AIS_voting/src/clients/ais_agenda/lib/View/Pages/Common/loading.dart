import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
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
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text('Загрузка'),
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
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Загрузка',
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
              const CircularProgressIndicator(),
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
