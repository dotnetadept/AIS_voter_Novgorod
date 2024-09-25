import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'user.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../Controls/controls.dart';

class UsersPage extends StatefulWidget {
  UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> _users = <User>[];
  bool _isLoadingComplete = false;
  bool _isAscending = true;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';
  List<User> _filteredUsers = <User>[];

  void _navigateNewUserPage() {
    _navigateUserPage(-1);
  }

  void _navigateUserPage(int index) {
    var user = index == -1 ? User() : _filteredUsers[index];
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserPage(user: user, users: _users)))
        .then((value) {
      _tecSearch.text = '';
      loadUsers();
    });
  }

  @override
  void initState() {
    super.initState();

    loadUsers();
  }

  void loadUsers() {
    http
        .get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"))
        .then((response) => {
              setState(() {
                _users = (json.decode(response.body) as List)
                    .map((data) => User.fromJson(data))
                    .toList();
                processSearch('');
              })
            })
        .then((value) {
      sortUsers();
      _isLoadingComplete = true;
    });
  }

  void sortUsers() {
    _users.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (_isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingComplete
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Назад',
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text("Пользователи"),
              centerTitle: true,
              actions: <Widget>[
                Tooltip(
                  message: "Добавить",
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: _navigateNewUserPage,
                    child: Icon(Icons.add),
                  ),
                ),
                Container(
                  width: 20,
                ),
              ],
            ),
            body: _isLoadingComplete
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tecSearch,
                                focusNode: _fnSearch,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
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
                                            icon: Icon(Icons.clear),
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
                                icon: Icon(Icons.search),
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
                  )
                : CommonWidgets().getLoadingStub(),
          )
        : Container();
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _filteredUsers = _users
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Widget _getUsersTable() {
    return Container(
      child: HorizontalDataTable(
        verticalScrollbarStyle: ScrollbarStyle(
          isAlwaysShown: true,
        ),
        leftHandSideColumnWidth: 0,
        rightHandSideColumnWidth: MediaQuery.of(context).size.width,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: TableHelper().generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: _filteredUsers.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
      ),
      height: MediaQuery.of(context).size.height - 126,
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      Container(
        height: 0.0,
        width: 0,
      ),
      Container(
        color: Colors.grey[350],
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  overlayColor: WidgetStateProperty.all(Colors.black12),
                  padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                ),
                child: Container(
                  child: Text(
                    (_isAscending ? '  ↓' : '  ↑') + 'Ф.И.О.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  height: 56,
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  _isAscending = !_isAscending;
                  sortUsers();
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Логин', 4),
            TableHelper().getTitleItemWidget('Пароль', 4),
            TableHelper().getTitleItemWidget('Ключ карты', 4),
            TableHelper()
                .getTitleItemWidget('Голосует', 2, aligment: Alignment.center),
            Container(
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
              width: 165,
              height: 56,
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              alignment: Alignment.centerLeft,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            child: Text(_filteredUsers[index].toString()),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            child: Text(_filteredUsers[index].login),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            child: Text(_filteredUsers[index].password),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            child: Text(_filteredUsers[index].cardId),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Icon(
                _filteredUsers[index].isVoter ? Icons.done : Icons.close,
                color:
                    _filteredUsers[index].isVoter ? Colors.green : Colors.red),
            width: 100,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.center,
          ),
        ),
        Container(
            width: 165,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(child: Container()),
              Tooltip(
                message: 'Редактировать',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.black12),
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  child: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _navigateUserPage(index);
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
}
