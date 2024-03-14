import 'package:ais_agenda/Model/entity/aisform.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/add_form_dialog.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Utilities/table_helper.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({Key? key}) : super(key: key);

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  static const int sortName = 0;
  bool isAscending = true;
  int sortType = sortName;

  final _tecSearch = TextEditingController();
  final _fnSearch = FocusNode();
  String _searchExpression = '';
  late List<AisForm> _aisforms;

  @override
  void initState() {
    super.initState();

    _aisforms = Provider.of<AppState>(context, listen: false).getForms();
    AppState().setPreviousNavPath('Формы');
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: Text(AppState().getPreviousNavPath()),
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
              await showAddFormDialog(context);
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
          _getAisFormsTable(),
        ],
      ),
    );
  }

  Widget _getAisFormsTable() {
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
        itemCount: _aisforms.length,
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
                  sortAisForms();
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
            child: Text(_aisforms[index].toString()),
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
                    _navigateAisFormPage(_aisforms[index]);
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

  void _navigateAisFormPage(AisForm aisform) {
    Provider.of<AppState>(context, listen: false)
        .navigateToPage('/form', args: aisform);
  }

  void sortAisForms() {
    sortType = sortName;
    isAscending = !isAscending;

    _aisforms.sort((a, b) {
      return a.toString().compareTo(b.toString()) * (isAscending ? 1 : -1);
    });

    processSearch(_searchExpression);

    setState(() {});
  }

  void processSearch(String value) {
    setState(() {
      _searchExpression = value;
      _aisforms = AppState()
          .getForms()
          .where((element) => element.contains(_searchExpression))
          .toList();
    });
  }

  Future<void> showAddFormDialog(BuildContext context) async {
    AisForm? agendaItem = await showDialog<AisForm>(
      context: context,
      builder: (_) => const Dialog(
        child: AddFormDialog(),
      ),
    );

    if (agendaItem != null) {
      _aisforms.add(agendaItem);
    }

    setState(() {});
  }
}
