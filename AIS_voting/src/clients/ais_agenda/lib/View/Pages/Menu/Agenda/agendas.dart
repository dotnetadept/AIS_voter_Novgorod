import 'dart:convert';
import 'dart:io';

import 'package:ais_agenda/Model/agenda/agenda.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/add_agenda_dialog.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Utilities/table_helper.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';

class AgendasPage extends StatefulWidget {
  const AgendasPage({Key? key}) : super(key: key);

  @override
  State<AgendasPage> createState() => _AgendasPageState();
}

class _AgendasPageState extends State<AgendasPage> {
  static const int sortName = 0;
  bool isAscending = true;
  int sortType = sortName;

  final _tecSearch = TextEditingController();
  final _fnSearch = FocusNode();
  String _searchExpression = '';
  late List<Agenda> _agendas;

  @override
  void initState() {
    super.initState();

    _agendas = Provider.of<AppState>(context, listen: false).getAgendas();
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: const Text('Повестки'),
      actions: <Widget>[
        Tooltip(
          message: "Добавить",
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () async {
              await showAddAgendaDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        ),
        Container(
          width: 20,
        ),
        Tooltip(
          message: 'Сохранить',
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: _save,
            child: const Icon(Icons.save),
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
          _getAgendasTable(),
        ],
      ),
    );
  }

  Widget _getAgendasTable() {
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
        itemCount: _agendas.length,
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
                    'Наименование${sortType == sortName ? (isAscending ? '  ↓' : '  ↑') : ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  sortAgendas();
                },
              ),
            ),
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
            child: Text(_agendas[index].toString()),
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
                    _navigateAgendaPage(_agendas[index]);
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

  Future<void> showAddAgendaDialog(BuildContext context) async {
    Agenda? agenda = await showDialog<Agenda>(
      context: context,
      builder: (_) => const Dialog(
        child: AddAgendaDialog(),
      ),
    );

    if (agenda != null) {
      _agendas.add(agenda);
    }

    setState(() {});
  }

  void _navigateAgendaPage(Agenda agenda) {
    Provider.of<AppState>(context, listen: false)
        .navigateToPage('/agenda', args: agenda);
  }

  void sortAgendas() {
    sortType = sortName;
    isAscending = !isAscending;

    _agendas.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  bool _save() {
    File localFile = File('assets/cfg/agendas.json');
    localFile.writeAsStringSync(jsonEncode(AppState().getAgendas()));

    Provider.of<AppState>(context, listen: false).navigateToPage('/agendas');

    return true;
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _agendas = AppState()
          .getAgendas()
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }
}
