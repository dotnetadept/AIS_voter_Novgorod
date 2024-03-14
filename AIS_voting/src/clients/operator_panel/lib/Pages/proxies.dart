import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'proxy.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../Controls/controls.dart';

class ProxiesPage extends StatefulWidget {
  ProxiesPage({Key key}) : super(key: key);

  @override
  _ProxiesPageState createState() => _ProxiesPageState();
}

class _ProxiesPageState extends State<ProxiesPage> {
  List<Proxy> _proxies = <Proxy>[];
  bool _isLoadingComplete = false;
  bool _isAscending = true;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';
  List<Proxy> _filteredProxies = <Proxy>[];

  void _navigateNewProxyPage() {
    _navigateProxyPage(-1);
  }

  void _navigateProxyPage(int index) {
    var proxy = index == -1
        ? Proxy(id: 0, subjects: <ProxyUser>[], isActive: false)
        : _filteredProxies[index];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProxyPage(
                  proxy: proxy,
                  proxies: _proxies,
                ))).then((value) {
      _tecSearch.text = '';
      loadProxies();
    });
  }

  @override
  void initState() {
    super.initState();

    loadProxies();
  }

  void loadProxies() {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/proxies"))
        .then((response) => {
              setState(() {
                _proxies = (json.decode(response.body) as List)
                    .map((data) => Proxy.fromJson(data))
                    .toList();
                processSearch('');
              })
            })
        .then((value) {
      sortProxies();
      _isLoadingComplete = true;
    });
  }

  void sortProxies() {
    _proxies.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (_isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  void removeProxy(int index) {
    var proxy = _filteredProxies[index];
    var proxyId = proxy.id;

    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/proxies/$proxyId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((value) => loadProxies());
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
          title: Text("Доверенности"),
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
                onPressed: _navigateNewProxyPage,
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
                  _getProxiesTable(),
                ],
              )
            : CommonWidgets().getLoadingStub());
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _filteredProxies = _proxies
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Widget _getProxiesTable() {
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
        itemCount: _filteredProxies.length,
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
                      (_isAscending ? '↓' : '↑') + 'Доверительное лицо', null),
                  height: 56,
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  _isAscending = !_isAscending;
                  sortProxies();
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Доверители', 2),
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
            child: Text(_filteredProxies[index].toString()),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Column(
              children: [Text("${_filteredProxies[index].subjects.length} ")],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            child: Icon(
                _filteredProxies[index].isActive ? Icons.done : Icons.close,
                color: _filteredProxies[index].isActive
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
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                Widget>[
              Expanded(
                child: Container(),
              ),
              Tooltip(
                message: 'Редактировать',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.black12),
                    shape: MaterialStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  child: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _navigateProxyPage(index);
                  },
                ),
              ),
              Tooltip(
                message: 'Удалить',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.black12),
                    shape: MaterialStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
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
                        text: 'Вы уверены, что хотите ${title.toLowerCase()}?',
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

                    removeProxy(index);
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
