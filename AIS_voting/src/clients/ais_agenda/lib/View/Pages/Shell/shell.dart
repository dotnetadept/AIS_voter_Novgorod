import 'package:ais_agenda/View/Pages/Shell/menu.dart';
import 'package:flutter/material.dart';

class Shell extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  const Shell(
      {Key? key, required this.body, this.title, this.actions, this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
        leading: leading,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: body,
      ),
    );
  }

  //
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: MenuWidget(),
      ),
    );
  }
}
