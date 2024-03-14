import 'dart:io';
import 'package:ais_model/ais_model.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class ViewDocumentPage extends StatefulWidget {
  ViewDocumentPage({Key key}) : super(key: key);

  @override
  _ViewDocumentPageState createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  QuestionFile _currentDocument;
  String _documentPageCount = '0';
  @override
  void initState() {
    super.initState();
    _currentDocument = AppState().getCurrentDocument();

    if (_currentDocument == null) {
      Provider.of<WebSocketConnection>(context, listen: false)
          .navigateToPage('viewAgenda');
    }

    String documentPath = 'file://' +
        Directory.current.path +
        '/documents/' +
        _currentDocument.relativePath +
        '/' +
        _currentDocument.fileName;

    openDocument(documentPath);
  }

  void openDocument(String documentPath) {
    // load new evince window on top of main
    try {
      var stats = Process.runSync('pdfinfo', <String>[documentPath]);
      var statsLines = stats.stdout.toString().split('\n').toList();
      for (var i = 0; i < statsLines.length; i++) {
        if (statsLines[i] != null &&
            statsLines[i].isNotEmpty &&
            statsLines[i].toLowerCase().trim().startsWith('pages:')) {
          setState(() {
            _documentPageCount =
                statsLines[i].toLowerCase().replaceAll('pages:', '').trim();
          });
          break;
        }
      }
      Process.run('evince', <String>[documentPath]);
    } catch (exc) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Expanded(
          child: viewDocumentPanel(),
        ),
      ],
    );
  }

  Widget viewDocumentPanel() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text(
                  _currentDocument.description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Text('($_documentPageCount стр.) '),
            ),
          ]),
          Expanded(
            child: Container(),
          ),
          Row(children: [
            Expanded(
              child: Container(),
            ),
            Container(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
            Container(
              width: 15,
            ),
            Text(
              'Загрузка ...',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: Container(),
            ),
          ]),
          Expanded(
            child: Container(),
          ),
          getButtonsSection(),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget getButtonsSection() {
    return StatefulBuilder(builder: (_context, _setState) {
      final connection =
          Provider.of<WebSocketConnection>(_context, listen: true);
      return Container(
        color: Colors.black12,
        child: Stack(children: <Widget>[
          Row(
            children: [
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: GestureDetector(
                  onTapDown: (TapDownDetails d) {
                    if (AppState().canUserNavigate()) {
                      AppState().setAgendaDocument(new QuestionFile());
                      AppState().setCurrentDocument(null);
                      AppState().setCurrentQuestion(null);

                      connection.navigateToPage('/viewAgenda');
                    }
                  },
                  child: TextButton(
                    onPressed: () {
                      if (AppState().canUserNavigate()) {
                        AppState().setAgendaDocument(new QuestionFile());
                        AppState().setCurrentDocument(null);
                        AppState().setCurrentQuestion(null);

                        connection.navigateToPage('/viewAgenda');
                      }
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(160, 50))),
                    child: Text('Назад к повестке'),
                  ),
                ),
              ),
              Container(width: 20),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: GestureDetector(
                  onTapDown: (TapDownDetails d) {
                    if (AppState().canUserNavigate()) {
                      AppState().setAgendaDocument(null);
                      AppState().setCurrentDocument(null);

                      connection.navigateToPage('/viewAgenda');
                    }
                  },
                  child: TextButton(
                    onPressed: () {
                      if (AppState().canUserNavigate()) {
                        AppState().setAgendaDocument(null);
                        AppState().setCurrentDocument(null);

                        connection.navigateToPage('/viewAgenda');
                      }
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(160, 50))),
                    child: Text('Назад к вопросу'),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              (connection.getClientType() != 'deputy' ||
                      !AppState().getIsRegistred())
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppState().getAskWordStatus()
                                ? Colors.white
                                : Colors.transparent,
                            width: 5,
                          ),
                        ),
                        child: TextButton(
                          autofocus: true,
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(280, 50)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          onPressed: () {
                            onAskWord(connection);
                          },
                          child: Container(
                            color: AppState().getAskWordStatus()
                                ? Color(AppState()
                                    .getSettings()
                                    .palletteSettings
                                    .askWordColor)
                                : Colors.blue,
                            height: 50,
                            width: 280,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                AppState().getAskWordStatus()
                                    ? 'ОТКАЗАТЬСЯ ОТ ВЫСТУПЛЕНИЯ'
                                    : 'ПРОШУ СЛОВА',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        AppState().getAskWordStatus() ? 15 : 20,
                                    color: Color(AppState().getAskWordStatus()
                                        ? Colors.black87.value
                                        : AppState()
                                            .getSettings()
                                            .palletteSettings
                                            .buttonTextColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              Container(
                width: 20,
              ),
            ],
          ),
        ]),
      );
    });
  }

  void onAskWord(WebSocketConnection connection) {
    if (AppState().getAskWordStatus()) {
      connection.sendMessage('ПРОШУ СЛОВА СБРОС');
    } else {
      connection.sendMessage('ПРОШУ СЛОВА');
    }
  }
}
