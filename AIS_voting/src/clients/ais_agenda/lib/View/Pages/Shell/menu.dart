import 'package:ais_agenda/State/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({Key? key}) : super(key: key);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: getMenuItems(),
        ),
      ),
    );
    // return Container(
    //   margin: const EdgeInsets.all(10),
    //   child: Column(
    //     children: [
    //       Row(
    //         children: [
    //           Expanded(
    //             child: Container(),
    //           ),
    //           const Text(
    //             'АИС Повестка',
    //             style: TextStyle(fontSize: 28),
    //           ),
    //           Expanded(
    //             child: Container(),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(
    //         height: 10,
    //       ),
    //       Row(
    //         children: getMenuItems(),
    //       ),
    //     ],
    //   ),
    // );
  }

  List<Widget> getMenuItems() {
    var menuItems = <Widget>[];

    menuItems.add(getMenuItem('Пользователи', '/users'));
    menuItems.add(getMenuItem('Группы', '/groups'));
    menuItems.add(getMenuItem('Формы', '/forms'));
    menuItems.add(getMenuItem('Повестки', '/agendas'));
    menuItems.add(getMenuItem('Календарь', '/calendar'));
    menuItems.add(getMenuItem('Журнал операций', '/journal'));
    menuItems.add(getMenuItem('Настройки', '/settings'));

    return menuItems;
  }

  Widget getMenuItem(String name, String path) {
    var isCurrentPage = AppState()
        .getCurrentPage()
        .contains(path.substring(2, path.length - 2));
    if (AppState().getCurrentPage() == '/rights') {
      isCurrentPage = AppState()
          .getPreviousPage()
          .contains(path.substring(2, path.length - 2));
    }

    return ListTile(
      title: TextButton(
        onPressed: () {
          Provider.of<AppState>(context, listen: false).navigateToPage(path);
        },
        child: Text(
          name,
          style: TextStyle(
              color: isCurrentPage ? Colors.greenAccent : Colors.white),
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
