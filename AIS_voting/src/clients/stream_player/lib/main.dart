import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'Pages/stream_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(StreamPlayerApp()));
}

class StreamPlayerApp extends StatelessWidget {
  const StreamPlayerApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'АИС Стрим',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(EdgeInsets.all(20)),
            overlayColor: MaterialStateProperty.all(Colors.blueAccent),
          ),
        ),
      ),
      home: const StreamPlayerPage(),
    );
  }
}
