import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Utilities/table_helper.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';

import '../../Shell/shell.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static const int sortName = 0;
  bool isAscending = true;
  int sortType = sortName;

  final _tecSearch = TextEditingController();
  final _fnSearch = FocusNode();
  String _searchExpression = '';
  late List<User> _users;

  @override
  void initState() {
    super.initState();

    _users = Provider.of<AppState>(context, listen: false).getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: const Text('Пользователи'),
      actions: <Widget>[
        Tooltip(
          message: "Добавить",
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () {
              _navigateUserPage(User());
            },
            child: const Icon(Icons.add),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tecSearch,
                    focusNode: _fnSearch,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Поиск',
                      suffixIcon: _tecSearch.text.isEmpty
                          ? null
                          : Tooltip(
                              message: 'Очистить поиск',
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _tecSearch.clear();
                                    processSearch(_tecSearch.text);
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                    ),
                    onSubmitted: (value) {
                      _fnSearch.requestFocus();
                      processSearch(value);
                    },
                  ),
                ),
                Container(
                  width: 20,
                ),
                Tooltip(
                  message: 'Поиск',
                  child: IconButton(
                    onPressed: () {
                      processSearch(_tecSearch.text);
                    },
                    icon: const Icon(Icons.search),
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 20,
                ),
              ],
            ),
          ),
          _getUsersTable(),
        ],
      ),
    );
  }

  Widget _getUsersTable() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: HorizontalDataTable(
        verticalScrollbarStyle: const ScrollbarStyle(
          isAlwaysShown: true,
        ),
        leftHandSideColumnWidth: 0,
        rightHandSideColumnWidth: MediaQuery.of(context).size.width,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: TableHelper().generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: _users.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: const Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      Container(
        width: 165,
        height: 56,
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width - 165,
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                ),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ф.И.О.${sortType == sortName ? (isAscending ? '  ↓' : '  ↑') : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  sortUsers();
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Логин', 4),
            TableHelper().getTitleItemWidget('Пароль', 4),
          ],
        ),
      ),
      Container(
        width: 165,
        height: 56,
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            height: 52,
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(_users[index].toString()),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: 300,
            height: 52,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(_users[index].login),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: 300,
            height: 52,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Text(_users[index].password),
          ),
        ),
        Container(
            width: 165,
            height: 52,
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(child: Container()),
              Tooltip(
                message: 'Редактировать',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.black12),
                    shape: MaterialStateProperty.all(
                      const CircleBorder(
                          side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _navigateUserPage(_users[index]);
                  },
                ),
              ),
              Container(
                width: 20,
              ),
            ])),
      ],
    );
  }

  void _navigateUserPage(User user) {
    Provider.of<AppState>(context, listen: false)
        .navigateToPage('/user', args: user);
  }

  void sortUsers() {
    sortType = sortName;
    isAscending = !isAscending;

    _users.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _users = AppState()
          .getUsers()
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }
}
