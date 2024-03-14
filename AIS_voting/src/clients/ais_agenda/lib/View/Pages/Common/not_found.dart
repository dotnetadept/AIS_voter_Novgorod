import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Shell(
        title: Text('Страница не найдена'),
        body: Center(
          child: Text(
            'Страница не найдена',
            style: TextStyle(fontSize: 30),
          ),
        ));
  }
}
