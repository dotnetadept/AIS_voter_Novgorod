import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:http/http.dart' as http;
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:global_configuration/global_configuration.dart';
import '../Controls/controls.dart';

class AgendasPage extends StatefulWidget {
  final Settings settings;
  final int timeOffset;
  AgendasPage({Key key, this.settings, this.timeOffset}) : super(key: key);

  @override
  _AgendasPageState createState() => _AgendasPageState();
}

class _AgendasPageState extends State<AgendasPage> {
  List<Agenda> _agendas;
  List<Meeting> _meetings;
  bool _isLoadingComplete = false;
  var _tecNewAgendaName = TextEditingController();

  static const int sortName = 0;
  static const int sortUploadDate = 1;
  bool _isAscending = true;
  int _sortType = sortUploadDate;

  var _tecSearch = TextEditingController();
  var _fnSearch = FocusNode();
  String _searchExpression = '';
  List<Agenda> _filteredAgendas = <Agenda>[];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/agendas"))
        .then((response) => {
              setState(() {
                _agendas = (json.decode(response.body) as List)
                    .map((data) => Agenda.fromJson(data))
                    .toList();
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
        .then((value) {
      sortAgendas(_sortType);
      _isLoadingComplete = true;
    });
  }

  void sortAgendas(int sortType) {
    _sortType = sortType;
    _isAscending = !_isAscending;

    sortAgendasInternal();
  }

  void sortAgendasInternal() {
    if (_sortType == sortName) {
      _agendas.sort((a, b) {
        return a.toString().compareTo(b.toString()) * (_isAscending ? 1 : -1);
      });
    }
    if (_sortType == sortUploadDate) {
      _agendas.sort((a, b) {
        return a.createdDate.compareTo(b.createdDate) * (_isAscending ? 1 : -1);
      });
    }

    processSearch(_searchExpression);
    setState(() {});
  }

  void removeAgenda(int index) {
    var agenda = _filteredAgendas[index];
    var agendaId = agenda.id;

    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/agendas/$agendaId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((value) => loadData());
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
        title: Text('Повестки'),
        centerTitle: true,
        actions: <Widget>[],
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
                _getAgendasTable(),
              ],
            )
          : CommonWidgets().getLoadingStub(),
    );
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _filteredAgendas = _agendas
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Future<void> addNewAgenda() async {
    _tecNewAgendaName.text = '';
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Создание повестки'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    width: 500,
                    child: TextFormField(
                      controller: _tecNewAgendaName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Наименование повестки',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Введите наименование повестки';
                        }

                        //check agenda folderName
                        var agenda = Agenda(
                            name: _tecNewAgendaName.text,
                            folder: _tecNewAgendaName.text +
                                '_' +
                                DateFormat('dd.MM.yyyy').format(
                                    TimeUtil.getDateTimeNow(widget.timeOffset)),
                            createdDate:
                                TimeUtil.getDateTimeNow(widget.timeOffset),
                            lastUpdated:
                                TimeUtil.getDateTimeNow(widget.timeOffset),
                            questions: <Question>[]);

                        if (_agendas.any(
                            (element) => element.folder == agenda.folder)) {
                          return 'Директория документов ${agenda.folder} уже существует.';
                        }
                        return null;
                      },
                    ),
                  ),
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

                var agenda = Agenda(
                    name: _tecNewAgendaName.text,
                    folder: _tecNewAgendaName.text +
                        '_' +
                        DateFormat('dd.MM.yyyy')
                            .format(TimeUtil.getDateTimeNow(widget.timeOffset)),
                    createdDate: TimeUtil.getDateTimeNow(widget.timeOffset),
                    lastUpdated: TimeUtil.getDateTimeNow(widget.timeOffset),
                    questions: <Question>[]);

                http
                    .post(
                        Uri.http(
                            ServerConnection.getHttpServerUrl(
                                GlobalConfiguration()),
                            '/agendas'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(agenda.toJson()))
                    .then((response) {
                  var insertedAgenda =
                      Agenda.fromJson(json.decode(response.body));
                  setState(() {
                    _agendas.add(insertedAgenda);
                    sortAgendasInternal();
                  });

                  Navigator.of(context).pop();
                }).catchError((e) {
                  Navigator.of(context).pop();

                  Utility().showMessageOkDialog(context,
                      title: 'Ошибка',
                      message: TextSpan(
                        text:
                            'В ходе создания повестки ${agenda.name} возникла ошибка: $e',
                      ),
                      okButtonText: 'Ок');
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getAgendasTable() {
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
        itemCount: _filteredAgendas.length,
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
        height: 0,
        width: 0,
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[350],
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.fromLTRB(20, 0, 0, 0)),
                ),
                child: TableHelper().getTitleItemWidget(
                    (_sortType == sortName ? (_isAscending ? '↓' : '↑') : '') +
                        'Название',
                    null),
                onPressed: () {
                  sortAgendas(sortName);
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  overlayColor: MaterialStateProperty.all(Colors.black12),
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                ),
                child: TableHelper().getTitleItemWidget(
                    (_sortType == sortUploadDate
                            ? (_isAscending ? '↓' : '↑')
                            : '') +
                        'Дата загрузки',
                    null),
                onPressed: () {
                  sortAgendas(sortUploadDate);
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Последнее изменение', 5),
            TableHelper().getTitleItemWidget('Директория документов', 5),
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
    var dependantMeetings = _meetings
        .where((element) => element.agenda?.id == _filteredAgendas[index].id)
        .toList();
    var dependantMeetingsText = '';
    if (dependantMeetings.isNotEmpty) {
      dependantMeetingsText = 'Используется в заседаниях:';
      dependantMeetings.forEach((element) {
        dependantMeetingsText += '\r\n' + element.name;
      });
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            child: Text(_filteredAgendas[index].name),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(DateFormat('dd.MM.yyyy')
                .format(_filteredAgendas[index].createdDate)),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(DateFormat('dd.MM.yyyy HH:mm:ss')
                .format(_filteredAgendas[index].lastUpdated.toLocal())),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(_filteredAgendas[index].folder),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Container(
          width: 165,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              dependantMeetingsText.isEmpty
                  ? Tooltip(
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
                          var title = 'Удалить повестку';

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

                          removeAgenda(index);
                        },
                      ),
                    )
                  : Tooltip(
                      message: dependantMeetingsText,
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
                        child: Icon(Icons.delete, color: Colors.black54),
                        onPressed: null,
                      ),
                    ),
              Container(
                width: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tecNewAgendaName.dispose();

    super.dispose();
  }
}
