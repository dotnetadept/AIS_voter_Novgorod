import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Shell(
      title: Text('Журнал операций'),
      body: Text('Журнал операций'),
    );
  }
}
