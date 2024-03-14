import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:global_configuration/global_configuration.dart';

class ProxyPage extends StatefulWidget {
  final List<Proxy> proxies;
  final Proxy proxy;
  ProxyPage({Key key, this.proxy, this.proxies}) : super(key: key);

  @override
  _ProxyPageState createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Proxy _originalProxy;
  var _users = <User>[];
  bool _isLoadingComplete = false;

  @override
  void initState() {
    super.initState();

    _originalProxy = Proxy.fromJson(jsonDecode(jsonEncode(widget.proxy)));

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
                    .where((element) => element.isVoter)
                    .toList();
                _isLoadingComplete = true;
              })
            });
  }

  Future<bool> _save() async {
    widget.proxy.lastUpdated = DateTime.now();
    if (widget.proxy.id == 0) {
      widget.proxy.createdDate = DateTime.now();
      http
          .post(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/proxies'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.proxy.toJson()))
          .then((value) => Navigator.pop(context));
    } else {
      var proxyId = widget.proxy.id;
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/proxies/$proxyId'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.proxy.toJson()))
          .then((value) => Navigator.pop(context));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Назад',
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(widget.proxy.id == 0
              ? 'Новая доверенность'
              : 'Изменить доверенность ${_originalProxy.toString()}'),
          centerTitle: true,
          actions: <Widget>[
            Tooltip(
              message: 'Сохранить',
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                ),
                onPressed: () async {
                  await _save();
                },
                child: Icon(Icons.save),
              ),
            ),
            Container(
              width: 20,
            ),
          ],
        ),
        body: proxyForm(context),
      ),
    );
  }

  Widget proxyForm(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: getUserSelector(true, (value) {
            setState(() {
              widget.proxy.proxy = value;
            });
          }),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Активность:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.proxy.isActive,
                  onChanged: (value) => {
                        setState(() {
                          widget.proxy.isActive = value;
                        })
                      })
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.lightBlue,
          child: Row(
            children: [
              Expanded(child: Container()),
              Text(
                'Доверители',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Tooltip(
                  message: 'Добавить',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      addSubject();
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: getSubjectsTable(),
        ),
      ],
    );
  }

  Widget getSubjectsTable() {
    if (widget.proxy.subjects == null || widget.proxy.subjects.length == 0) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.white;
            }),
            headingRowHeight: 0,
            columns: [
              DataColumn(
                label: Text(
                  'Ф.И.О.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: widget.proxy.subjects
                .map(
                  ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Text(element.user.toString()),
                                ),
                                Tooltip(
                                  message: 'Удалить доверителя',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.black12),
                                      shape: MaterialStateProperty.all(
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      removeSubject(element);
                                    },
                                    child: Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> addSubject() async {
    // show select user dialog
    final formKey = GlobalKey<FormState>();
    User selectedUser;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить доверителя'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  getUserSelector(false, (value) {
                    selectedUser = value;
                  }),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                setState(() {
                  widget.proxy.subjects.add(
                      ProxyUser(proxyId: widget.proxy.id, user: selectedUser));
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeSubject(ProxyUser subject) {
    setState(() {
      widget.proxy.subjects.remove(subject);
    });
  }

  Widget getUserSelector(bool isProxy, void onChanged(User value)) {
    List<User> filteredUsers = <User>[];
    User selectedUser;

    if (isProxy) {
      selectedUser = _users.firstWhere(
          (element) => element.id == widget.proxy.proxy?.id,
          orElse: () => null);
      filteredUsers = _users
          .where((element) =>
              element.id != widget.proxy.proxy?.id &&
              !widget.proxy.subjects.any((pu) => pu.user.id == element.id))
          .toList();
    } else {
      selectedUser = null;
      filteredUsers = _users
          .where((element) =>
              element.id != widget.proxy.proxy?.id &&
              !widget.proxy.subjects.any((pu) => pu.user.id == element.id))
          .toList();
    }

    return DropdownSearch<User>(
      mode: Mode.DIALOG,
      showSearchBox: true,
      showClearButton: true,
      items: filteredUsers,
      label: isProxy ? 'Доверенное лицо' : 'Доверитель',
      popupTitle: Container(
          alignment: Alignment.center,
          color: Colors.blueAccent,
          padding: EdgeInsets.all(10),
          child: Text(
            isProxy ? 'Доверенное лицо' : 'Доверитель',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          )),
      hint: isProxy ? 'Выберите Доверенное лицо' : 'Выберите Доверителя',
      selectedItem: selectedUser,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return isProxy ? 'Выберите Доверенное лицо' : 'Выберите Доверителя';
        }
        return null;
      },
      dropdownBuilder:
          isProxy ? userDropDownItemBuilder : proxyDropDownItemBuilder,
      popupItemBuilder: userItemBuilder,
      emptyBuilder: emptyBuilder,
    );
  }

  Widget userDropDownItemBuilder(
    BuildContext context,
    User item,
    String itemDesignation,
  ) {
    return item == null
        ? Container(
            child: Text(
              'Выберите доверителя',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : userItemBuilder(context, item, true);
  }

  Widget proxyDropDownItemBuilder(
    BuildContext context,
    User item,
    String itemDesignation,
  ) {
    return item == null
        ? Container(
            child: Text(
              'Выберите доверенное лицо',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : userItemBuilder(context, item, true);
  }

  Widget userItemBuilder(BuildContext context, User item, bool isSelected) {
    var alreadyUsed = false;

    for (int index = 0; index < widget.proxies.length; index++) {
      if (widget.proxies[index].proxy.id == item.id) {
        alreadyUsed = true;
        break;
      }
      for (int j = 0; j < widget.proxies[index].subjects.length; j++) {
        if (widget.proxies[index].subjects[j].id == item.id) {
          alreadyUsed = true;
          break;
        }
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Row(
          children: [
            Text(item.toString()),
            Expanded(child: Container()),
            Container(
              width: 20,
            ),
            alreadyUsed
                ? Tooltip(
                    message: 'Уже используется',
                    child: Icon(
                      Icons.done,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget emptyBuilder(BuildContext context, String text) {
    return Center(child: Text('Нет данных'));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
