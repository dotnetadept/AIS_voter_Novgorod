import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'group.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../Controls/controls.dart';

class GroupsPage extends StatefulWidget {
  GroupsPage({Key key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<Group> _groups = <Group>[];
  List<Meeting> _meetings;
  List<MeetingSession> _meetingSessions;
  bool _isLoadingComplete = false;
  bool _isAscending = true;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';
  List<Group> _filteredGroups = <Group>[];

  void _navigateNewGroupPage() {
    _navigateGroupPage(-1, false);
  }

  void _navigateGroupPage(int index, bool isReadOnly) {
    var group = index == -1 ? Group() : _filteredGroups[index];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GroupPage(group: group, isReadOnly: isReadOnly))).then((value) {
      _tecSearch.text = '';
      loadGroups();
    });
  }

  void _copyGroup(int index) {
    var group = index == -1 ? Group() : _filteredGroups[index];
    var copiedGroup = Group.fromJson(jsonDecode(jsonEncode(group)));
    copiedGroup.id = 0;
    copiedGroup.name += '_копия';

    http
        .post(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/groups'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(copiedGroup.toJson()))
        .then((value) => loadGroups());
  }

  @override
  void initState() {
    super.initState();

    loadGroups();
  }

  void loadGroups() {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/groups"))
        .then((response) => {
              setState(() {
                _groups = (json.decode(response.body) as List)
                    .map((data) => Group.fromJson(data))
                    .toList();
                processSearch('');
              })
            })
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/meetings"))
            .then((response) => {
                  setState(() {
                    _meetings = (json.decode(response.body) as List)
                        .map((data) => Meeting.fromJson(data))
                        .toList();
                  })
                }))
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/meeting_sessions"))
            .then((response) => {
                  setState(() {
                    _meetingSessions = (json.decode(response.body) as List)
                        .map((data) => MeetingSession.fromJson(data))
                        .toList();
                  })
                }))
        .then((value) {
      sortGroups();
      _isLoadingComplete = true;
    });
  }

  void sortGroups() {
    _groups.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (_isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  void removeGroup(int index) {
    var group = _filteredGroups[index];
    var groupId = group.id;

    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/groups/$groupId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((value) => loadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Назад',
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Группы"),
          centerTitle: true,
          actions: <Widget>[
            Tooltip(
              message: "Добавить",
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                ),
                onPressed: _navigateNewGroupPage,
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
                  _getGroupsTable(),
                ],
              )
            : CommonWidgets().getLoadingStub());
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _filteredGroups = _groups
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Widget _getGroupsTable() {
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
        itemCount: _filteredGroups.length,
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
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[350],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                ),
                child: Container(
                  child: TableHelper().getTitleItemWidget(
                      (_isAscending ? '↓' : '↑') + 'Название', null),
                  height: 56,
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  _isAscending = !_isAscending;
                  sortGroups();
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Заполнено мест', 2),
            TableHelper().getTitleItemWidget('Активность', 2,
                aligment: Alignment.center),
            Container(
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
              width: 217,
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
            child: Text(_filteredGroups[index].toString()),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Column(
              children: [
                Container(
                  child: LinearProgressIndicator(
                    value: _filteredGroups[index]
                                .workplaces
                                .getTotalPlacesCount() ==
                            0
                        ? 0
                        : _filteredGroups[index]
                                .workplaces
                                .getTotalUsersCount() /
                            _filteredGroups[index]
                                .workplaces
                                .getTotalPlacesCount(),
                  ),
                ),
                Text(
                    "${_filteredGroups[index].workplaces.getTotalUsersCount()} из ${_filteredGroups[index].workplaces.getTotalPlacesCount()}")
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Icon(
                _filteredGroups[index].isActive ? Icons.done : Icons.close,
                color: _filteredGroups[index].isActive
                    ? Colors.green
                    : Colors.red),
            width: 100,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.center,
          ),
        ),
        Container(
            width: 217,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: _meetings.any((element) =>
                    element.group?.id == _filteredGroups[index].id &&
                    _meetingSessions
                        .any((element) => element.meetingId == element.id))
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Tooltip(
                        message: 'Копировать',
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            overlayColor:
                                MaterialStateProperty.all(Colors.black12),
                            shape: MaterialStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          child: Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            _copyGroup(index);
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Редактировать',
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            overlayColor:
                                MaterialStateProperty.all(Colors.black12),
                            shape: MaterialStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          child: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _navigateGroupPage(index, false);
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        width: 20,
                      ),
                    ],
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Tooltip(
                      message: 'Копировать',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.copy, color: Colors.blue),
                        onPressed: () {
                          _copyGroup(index);
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Редактировать',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _navigateGroupPage(index, false);
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Удалить',
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          shape: MaterialStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        child: Icon(Icons.delete, color: Colors.black87),
                        onPressed: () async {
                          var noButtonPressed = false;
                          var title = 'Удалить группу';

                          await Utility().showYesNoDialog(
                            context,
                            title: title,
                            message: TextSpan(
                              text:
                                  'Вы уверены, что хотите ${title.toLowerCase()}?',
                            ),
                            yesButtonText: 'Да',
                            yesCallBack: () {
                              Navigator.of(context).pop();
                            },
                            noButtonText: 'Нет',
                            noCallBack: () {
                              noButtonPressed = true;
                              Navigator.of(context).pop();
                            },
                          );

                          if (noButtonPressed) {
                            return;
                          }

                          removeGroup(index);
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
